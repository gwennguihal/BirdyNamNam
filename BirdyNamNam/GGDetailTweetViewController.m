//
//  GGDetailTweetViewController.m
//  BirdyNamNam
//
//  Created by Gwenn on 06/03/13.
//  Copyright (c) 2013 Free. All rights reserved.
//

#import "GGDetailTweetViewController.h"
#import "GGAppDelegate.h"
#import "Tweet.h"
#import "GGDetailTweetTableViewCell.h"
#import "GGReplyViewController.h"

@interface GGDetailTweetViewController ()

@property (strong,nonatomic) Tweet* _tweet;

@end

@implementation GGDetailTweetViewController

@synthesize moc, managedObjectId, imageCache;
@synthesize _tweet;

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
    
    self.moc = [(GGAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    _tweet = (Tweet*)[moc objectWithID:self.managedObjectId];
    
    // get replies
    // 311097011774578688
    self.twitterEngine = [FHSTwitterEngine sharedTwitterEngine];
    
    
    /*dispatch_async(GCDBackgroundThread, ^{
        @autoreleasepool {
            
            id twitterCallBack;
            __block NSMutableArray *details = nil;
            
            twitterCallBack = [self.twitterEngine getDiscussionForTweet:@"311097011774578688"];
            
            dispatch_sync(GCDMainThread, ^{
                @autoreleasepool {
                    
                    if ([twitterCallBack isKindOfClass:[NSError class]])
                    {
                        NSError *error = twitterCallBack;
                        NSLog(@"Detais Tweets failed %@, %@", error.description, error.userInfo );
                    }
                    else
                    {
                        details = twitterCallBack;
                    }
                    
                }});
        }});*/

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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DetailTweetCell";
    GGDetailTweetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil)
    {
        cell = [[GGDetailTweetTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell cellForRowAtIndexPath:indexPath];
    
    return cell;
    
}

- (void)configureCell:(GGDetailTweetTableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = [_tweet.infos objectForKey:@"text"];
    NSString *authorName = [[_tweet.infos objectForKey:@"user"] objectForKey:@"name"];
    NSString *authorScreenName = [@"@" stringByAppendingString:[[_tweet.infos objectForKey:@"user"] objectForKey:@"screen_name"]];
    
    cell.authorNameLabel.text = authorName;
    cell.authorScreenNameLabel.text = authorScreenName;
    
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.textLabel.text = text;
    [cell.textLabel sizeToFitFixedWidth];
    
    // format from json
    // "Wed Mar 06 17:01:41 +0000 2013"
    
    NSString *dateString = [_tweet.infos objectForKey:@"created_at"];
    
    static NSDateFormatter *twitterDateFormatter = nil;
    if (twitterDateFormatter == nil)
    {
        twitterDateFormatter = [[NSDateFormatter alloc] init];
        [twitterDateFormatter setLocale: [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ];
        [twitterDateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
        [twitterDateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    }
    NSDate *date = [twitterDateFormatter dateFromString:dateString];
    
    static NSDateFormatter *displayDateFormatter = nil;
    if (displayDateFormatter == nil)
    {
        displayDateFormatter = [[NSDateFormatter alloc] init];
        [displayDateFormatter setLocale: [[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"] ];
        [displayDateFormatter setDateFormat:@"EEEE dd MMMM HH:mm"];

    }
    
    cell.dateLabel.text = [displayDateFormatter stringFromDate: date];
    
    NSString *authorID = [[_tweet.infos objectForKey:@"user"] objectForKey:@"id_str"];
    NSData *data = [imageCache objectForKey:authorID];
    if (data)
    {
        cell.authorImageView.image = [UIImage imageWithData: data ];
    }
    else
    {
        cell.authorImageView.image = [UIImage imageNamed:@"Placeholder.png"];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"widdth %d",[GGDetailTweetTableViewCell TextLabelWidth]);
    
    NSString *text = [_tweet.infos objectForKey:@"text"];
    CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize: CGSizeMake( [GGDetailTweetTableViewCell TextLabelWidth] ,CGFLOAT_MAX )];
    
    //return MAX(textSize.height + [GGDetailTweetTableViewCell CellOffsetY],tableView.rowHeight);
    return textSize.height + [GGDetailTweetTableViewCell CellOffsetY];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"replySegue"])
    {
        GGReplyViewController *replyViewController = (GGReplyViewController*)segue.destinationViewController;
        
        replyViewController.inReplyToScreenName = [[self._tweet.infos objectForKey:@"user"] objectForKey:@"screen_name"];
        replyViewController.moc = self.moc;

    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
