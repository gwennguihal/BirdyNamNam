//
//  GGFriendsListViewController.m
//  BirdyNamNam
//
//  Created by Gwenn on 14/03/13.
//  Copyright (c) 2013 Free. All rights reserved.
//

#import "GGFriendsListViewController.h"
#import "GGAppDelegate.h"
#import "SVProgressHUD.h"
#import "Friend.h"

@interface GGFriendsListViewController ()
{
}

@property BOOL _isFetchingFriends;
@property UIView *_refreshHeaderView;
@property UILabel *_refreshLabel;
@property UIActivityIndicatorView *_spinner;

@end

#define REFRESH_HEADER_HEIGHT 52.0f

@implementation GGFriendsListViewController

@synthesize twitterEngine, imageCache, moc, fetcher = _fetcher;
@synthesize _refreshHeaderView, _refreshLabel, _spinner;

// getter fetcher
- (NSFetchedResultsController*) fetcher
{
    if (_fetcher != nil)
    {
        return _fetcher;
    }
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Friend"];
    request.fetchBatchSize = 100;
    request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"friendname" ascending:YES] ];
    
    
    _fetcher = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.moc sectionNameKeyPath:nil cacheName:@"tweetFriendCache"];
    self.fetcher = _fetcher;
    
    _fetcher.delegate = self;
    
    return _fetcher;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // coredata
    self.moc = [(GGAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    [self _addPullToRefreshHeader];
    
    self.title = @"My Friends";
    
    imageCache = [[NSCache alloc] init];
    
    self.twitterEngine = [FHSTwitterEngine sharedTwitterEngine];
    
    NSError *error;
    if ( ![self.fetcher performFetch:&error] )
    {
        NSLog(@"Error fetching results %@, %@",error,error.userInfo);
    }
    else
    {
        if (self.fetcher.fetchedObjects.count == 0)
        {
            [self _fetchFriends];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self _loadAuthorImageForVisibleRows];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.fetcher.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetcher.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    static NSString *CellIdentifier = @"TweetUserCell";
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell cellForRowAtIndexPath:indexPath];
    
    return cell;
    
}

- (void)configureCell:(UITableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.fetcher.fetchedObjects.count == 0)
    {
        return;
    }
    
    Friend *friend = [self.fetcher objectAtIndexPath:indexPath];
    
    cell.textLabel.text = friend.friendname;
    cell.detailTextLabel.text = friend.friendscreenname;
        
    dispatch_async(GCDBackgroundThread, ^{
        @autoreleasepool {
            NSData *data = [imageCache objectForKey:friend.friendid];
            
            dispatch_sync(GCDMainThread, ^{
                @autoreleasepool
                {
                    if (data)
                    {
                        cell.imageView.image = [UIImage imageWithData: data ];
                    }
                    else
                    {
                        cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
                    }
                }});
        }});
}

- (void)_updateCoreData:(NSArray*)newFriends
{
    NSError *error;
    
    // save in core data
    for (NSDictionary *newFriend in newFriends)
    {
        Friend *friend = nil;
        
        // test if friend exists
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Friend"];
        request.fetchLimit = 1;
        request.predicate = [NSPredicate predicateWithFormat:@"friendid = %@", [newFriend objectForKey:@"id_str"]];
        NSArray *friends = [self.moc executeFetchRequest:request error:&error];
        if (friends == nil)
        {
            NSLog(@"Fetching Friend failed %@, %@", error.description, error.userInfo );
        }
        if (friends.count > 0)
        {
            friend = [friends objectAtIndex:0];
            NSLog(@"update friend");
        }
        else
        {
            friend = [NSEntityDescription insertNewObjectForEntityForName:@"Friend" inManagedObjectContext:moc];
            NSLog(@"new friend");
        }
        
        friend.friendid = [newFriend objectForKey:@"id_str"];
        friend.friendname = [newFriend objectForKey:@"name"];
        friend.friendscreenname = [newFriend objectForKey:@"screen_name"];
        friend.friendprofileimageurl = [newFriend objectForKey:@"profile_image_url"];
        
        
    }

    // save
    if (![moc save:&error])
    {
        NSLog(@"Error saving Tweet %@ , %@",error,error.userInfo);
    }
    
    
}

- (void)_fetchFriends
{
    self._isFetchingFriends = YES;
    
    [SVProgressHUD show];
    
    dispatch_async(GCDBackgroundThread, ^{
        @autoreleasepool {
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            
            NSArray *newFriends = [self.twitterEngine getFriends];
            
            dispatch_sync(GCDMainThread, ^{
                @autoreleasepool
                {
                    
                    [self _updateCoreData: newFriends];
                    
                    [self _loadAuthorImageForVisibleRows];
                    
                    [SVProgressHUD showSuccessWithStatus:@"Done !"];
                    
                    self._isFetchingFriends = NO;
                    UIApplication.sharedApplication.networkActivityIndicatorVisible = NO;
                    self.tableView.contentInset = UIEdgeInsetsZero;
                    [_spinner stopAnimating];
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
    if (self.fetcher.fetchedObjects.count > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        
        for (NSIndexPath *indexPath in visiblePaths)
        {
            if (indexPath.row >= self.fetcher.fetchedObjects.count) return;
            
            Friend *friend = [self.fetcher objectAtIndexPath:indexPath];
            
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            NSString *imageUrl = friend.friendprofileimageurl;
            if (imageUrl != nil)
            {
                NSString *extension = [@"." stringByAppendingString:[imageUrl pathExtension]];
                NSString *authorID = friend.friendid;
                NSString *path = [[NSTemporaryDirectory() stringByAppendingPathComponent:authorID] stringByAppendingString:extension];
                
                // ram
                NSData *data = [imageCache objectForKey:authorID];
                if (data != nil)
                {
                    cell.imageView.image = [UIImage imageWithData:data];
                    continue;
                }
                
                // disk
                if ( [[NSFileManager defaultManager] fileExistsAtPath: path] )
                {
                    // put in nscache
                    NSData *data = [NSData dataWithContentsOfFile:path];
                    [imageCache setObject:data forKey:authorID];
                    // add image
                    cell.imageView.image = [UIImage imageWithData:data];
                    continue;
                }
                
                // load
                dispatch_async(GCDBackgroundThread, ^{
                    @autoreleasepool
                    {
                        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
                        
                        dispatch_sync(GCDMainThread, ^{
                            @autoreleasepool
                            {
                                // disk + cache image
                                if (data != nil)
                                {
                                    [data writeToFile:path atomically:NO];
                                    
                                    [imageCache setObject:data forKey:authorID];
                                    // add image
                                    cell.imageView.image = [UIImage imageWithData:data];
                                }
                            }
                        });
                    }
                });
            }
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /*if ([segue.identifier isEqualToString:@"showDetailTweetSegue"])
    {
        GGDetailTweetViewController *detailTweetViewController = (GGDetailTweetViewController*)segue.destinationViewController;
        
        UITableViewCell *cell = (UITableViewCell*)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        Tweet *tweet = [self.fetcher objectAtIndexPath:indexPath];
        
        detailTweetViewController.managedObjectId = tweet.objectID;
        detailTweetViewController.imageCache = self.imageCache;
    }*/
}

#pragma mark - UI ScrollVIew delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = self.tableView.contentOffset.y;
    
    // pull to refresh
    if (self._isFetchingFriends == NO)
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
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // pull to refresh
    CGFloat offsetY = self.tableView.contentOffset.y;
    if (offsetY < -REFRESH_HEADER_HEIGHT && self._isFetchingFriends == NO)
    {
        self.tableView.contentInset = UIEdgeInsetsMake(-offsetY, 0, 0, 0);
        [_spinner startAnimating];
        [self _fetchFriends];
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

#pragma mark - NsFetchedResultsController delegate

/*
 NSFetchedResultsController delegate methods to respond to additions, removals and so on.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    //self.tableView.scrollEnabled = NO;
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] cellForRowAtIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
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

- (void)viewWillAppear
{
    //[self.tableView reloadData];
}


- (void)viewDidUnload
{
    self.fetcher = nil;
}



@end
