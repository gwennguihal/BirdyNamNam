//
//  GGTimeLineViewController.m
//  BirdyNamNam
//
//  Created by Gwenn on 22/02/13.
//  Copyright (c) 2013 Free. All rights reserved.
//

#import "GGTimeLineViewController.h"
#import "GGAppDelegate.h"
#import "SVProgressHUD.h"
#import "Tweet.h"

@interface GGTimeLineViewController ()
{
    BOOL _hasCache;
}

@property BOOL _isFetchingTweets;
@property NSString *_firstTweetID, *_lastTweetID;
@property UIView *_refreshHeaderView;
@property UILabel *_refreshLabel;
@property UIActivityIndicatorView *_spinner;

@end

#define REFRESH_HEADER_HEIGHT 52.0f

@implementation GGTimeLineViewController

@synthesize twitterEngine, tweets, imageCache, moc, fetcher;
@synthesize _firstTweetID, _lastTweetID, _refreshHeaderView, _refreshLabel, _spinner;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _hasCache = NO;
    
    // coredata
    self.moc = [(GGAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    [self _addPullToRefreshHeader];
    
    self.title = @"My Timeline";
    
    
    imageCache = [[NSCache alloc] init];
    self.twitterEngine = [FHSTwitterEngine sharedTwitterEngine];
    
    // fetcher
    
    // get core data tweets
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
    request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"tweetid" ascending:NO] ];
    request.fetchLimit = 1;
    
    NSError *error;
    NSArray *results = [self.moc executeFetchRequest:request error:&error];
    if (results.lastObject)
    {
        _hasCache = YES;
    }
    else
    {
        _hasCache = NO;
        [self _fetchTweetsBeforeID:nil orSinceID:nil];
    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return tweets.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    
    if (indexPath.row == tweets.count)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MoreCell"];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MoreCell"];
        }
        return cell;
    }
    
    static NSString *CellIdentifier = @"TweetCell";
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    NSDictionary *tweet = [tweets objectAtIndex:indexPath.row];
    NSString *text = [tweet objectForKey:@"text"];
    NSString *authorName = [[tweet objectForKey:@"user"] objectForKey:@"name"];
    
    
    UILabel *authorNameLabel = (UILabel*)[cell viewWithTag:2];
    authorNameLabel.text = authorName;

    
    UILabel *textLabel = (UILabel*)[cell viewWithTag:3];
    textLabel.font = [UIFont systemFontOfSize:12.0];
    textLabel.text = text;
    [textLabel sizeToFitFixedWidth]; // resize label
    
    UIImageView *authorImageView = (UIImageView*)[cell viewWithTag:1];
    // image, cache or not cache ?
    NSString *imageUrl = [[tweet objectForKey:@"user"] objectForKey:@"profile_image_url"];
    NSData *data = [imageCache objectForKey:imageUrl];
    if (data)
    {
        authorImageView.image = [UIImage imageWithData: data ];
    }
    else
    {
        authorImageView.image = [UIImage imageNamed:@"Placeholder.png"];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //GGTweetTableViewCell *cell = (GGTweetTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.row == tweets.count)
    {
        return tableView.rowHeight;
    }
    
    NSDictionary *tweet = [tweets objectAtIndex:indexPath.row];
    NSString *text = [tweet objectForKey:@"text"];
    CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize: CGSizeMake( 230,CGFLOAT_MAX )];
    
    return MAX(textSize.height + 40,tableView.rowHeight);
}

- (void)_fetchTweetsBeforeID:(NSString *)beforeID orSinceID:(NSString *) sinceID
{
    self._isFetchingTweets = YES;
    
    [SVProgressHUD show];
    
    
    dispatch_async(GCDBackgroundThread, ^{
        @autoreleasepool {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            
            NSArray *beforeTweets;
            NSArray *moreTweets;
            
            if (beforeID == nil && sinceID == nil) // timeline for the first time
            {
                self.tweets = [NSMutableArray arrayWithArray:[self.twitterEngine getHomeTimelineBeforeID:beforeID count:50]];
                
                // save in core data
                for (NSDictionary *tweet in self.tweets)
                {
                    NSError *error;
                    
                    Tweet *tweetEntity = [NSEntityDescription insertNewObjectForEntityForName:@"Tweet" inManagedObjectContext:moc];
                    NSData *json = [NSJSONSerialization dataWithJSONObject:tweet options:NSJSONWritingPrettyPrinted error:&error];
                    if (json != nil)
                    {
                        tweetEntity.json = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
                        tweetEntity.tweetid = [tweet objectForKey:@"id_str"];
                        
                        // save
                        if (![moc save:&error])
                        {
                            NSLog(@"Error saving Tweet %@ , %@",error,error.userInfo);
                        }
                    }
                    else
                    {
                        NSLog(@"Error create JSON Frow Tweet %@ , %@",error,error.userInfo);
                    }
                }
                
                
            }
            else if (sinceID) // add old tweets
            {
                beforeTweets = [self.twitterEngine getHomeTimelineSinceID:sinceID count:100];
            }
            else if (beforeID) // update timeline
            {
                moreTweets = [self.twitterEngine getHomeTimelineBeforeID:beforeID count:20];
            }
            
            dispatch_sync(GCDMainThread, ^{
                @autoreleasepool
                {                    
                    if (beforeTweets && beforeTweets.count > 0)
                    {
                        [self.tableView beginUpdates];
                        NSRange range = NSMakeRange(0, beforeTweets.count);
                        NSMutableArray *rangeArray = [NSMutableArray arrayWithCapacity:range.length];
                        for (int i = range.location ; i < (range.location + range.length) ; i++)
                        {
                            [rangeArray addObject: [NSIndexPath indexPathForRow:i inSection:0] ];
                        }
                        [self.tweets insertObjects:beforeTweets atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, beforeTweets.count)]];
                        [self.tableView insertRowsAtIndexPaths:rangeArray withRowAnimation:UITableViewRowAnimationFade];
                        [self.tableView endUpdates];
                    }
                    else if (moreTweets && moreTweets.count > 0)
                    {
                        [self.tableView beginUpdates];
                        NSRange range = NSMakeRange(self.tweets.count-2, moreTweets.count - 1);
                        NSMutableArray *rangeArray = [NSMutableArray arrayWithCapacity:range.length];
                        for (int i = range.location ; i < (range.location + range.length) ; i++)
                        {
                            [rangeArray addObject: [NSIndexPath indexPathForRow:i inSection:0] ];
                        }
                        
                        [self.tweets addObjectsFromArray: [moreTweets subarrayWithRange:NSMakeRange(1, moreTweets.count-1)]];
                        [self.tableView insertRowsAtIndexPaths:  rangeArray  withRowAnimation:UITableViewRowAnimationFade];
                        [self.tableView endUpdates];
                    }
                    else
                    {
                        [self.tableView reloadData];
                    }
                    
                    [self _loadAuthorImageForVisibleRows];
                    
                    self._firstTweetID = [[self.tweets objectAtIndex:self.tweets.count - 1] objectForKey:@"id_str"];
                    self._lastTweetID = [[self.tweets objectAtIndex:0] objectForKey:@"id_str"];
                    
                    [SVProgressHUD showSuccessWithStatus:@"Done !"];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    self._isFetchingTweets = NO;
                    self.tableView.contentInset = UIEdgeInsetsZero;
                    [_spinner stopAnimating];
                    
                    //UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Complete!" message:@"Your list of followers has been fetched" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    //[av show];
                    
                }
            });
        }
    });
}

- (void)_addPullToRefreshHeader
{
    _refreshHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, self.tableView.bounds.size.width, REFRESH_HEADER_HEIGHT)];
    _refreshHeaderView.backgroundColor = [UIColor clearColor];
    
    _refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, REFRESH_HEADER_HEIGHT)];
    _refreshLabel.backgroundColor = [UIColor clearColor];
    _refreshLabel.font = [UIFont boldSystemFontOfSize:12.0];
    _refreshLabel.textAlignment = NSTextAlignmentCenter;
    _refreshLabel.text = @"Pull to Refresh";
        
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _spinner.frame = CGRectMake(floorf(floorf(REFRESH_HEADER_HEIGHT - 20) / 2), floorf((REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
    _spinner.hidesWhenStopped = YES;
    
    [_refreshHeaderView addSubview:_refreshLabel];
    [_refreshHeaderView addSubview:_spinner];
    [self.tableView addSubview:_refreshHeaderView];
}

- (void)_loadAuthorImageForVisibleRows
{
    if ([self.tweets count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        
        for (NSIndexPath *indexPath in visiblePaths)
        {
            if (indexPath.row >= self.tweets.count) return;
            
            NSDictionary *tweet = [tweets objectAtIndex:indexPath.row];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            UIImageView *authorImageView = (UIImageView*)[cell viewWithTag:1];
            
            NSString *imageUrl = [[tweet objectForKey:@"user"] objectForKey:@"profile_image_url"];
            
            if ([imageCache objectForKey:imageUrl])
            {
                continue;
            }
            
            dispatch_async(GCDBackgroundThread, ^{
                @autoreleasepool
                {
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
            
                    dispatch_sync(GCDMainThread, ^{
                        @autoreleasepool
                        {
                            // cache image
                            [imageCache setObject:data forKey:imageUrl];
                            // add image
                            authorImageView.image = [UIImage imageWithData:data];
                        }
                    });
                }
            });
        }
    }
}

#pragma mark - UI ScrollVIew delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = self.tableView.contentOffset.y;
    CGFloat contentHeight = self.tableView.contentSize.height - self.tableView.bounds.size.height;
    
    // pull to refresh
    if (self._isFetchingTweets == NO)
    {
        if (offsetY < -REFRESH_HEADER_HEIGHT)
        {
            _refreshLabel.text = @"Release to Refresh";
        }
        else
        {
            _refreshLabel.text = @"Pull to Refresh";
        }
    }    
    // load more
    if (offsetY >= contentHeight && self._isFetchingTweets == NO)
    {
        [self _fetchTweetsBeforeID:self._firstTweetID orSinceID:nil];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // pull to refresh
    CGFloat offsetY = self.tableView.contentOffset.y;
    if (offsetY < -REFRESH_HEADER_HEIGHT && self._isFetchingTweets == NO)
    {
        self.tableView.contentInset = UIEdgeInsetsMake(-offsetY, 0, 0, 0);
        [_spinner startAnimating];
        [self _fetchTweetsBeforeID:nil orSinceID:_lastTweetID];
    }
    
    if (!decelerate)
    {
        [self _loadAuthorImageForVisibleRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self _loadAuthorImageForVisibleRows];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
