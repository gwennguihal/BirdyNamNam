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
    GGDetailTweetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
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
    
    // match twitter users
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([@|#]\\w+)" options:NSRegularExpressionCaseInsensitive error:&error];
    //NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"((@|#)\\w+)|(http://)" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
    //string addAttribute:<#(NSString *)#> value:<#(id)#> range:<#(NSRange)#>
    
    cell.textView.font = [UIFont systemFontOfSize:14.0];
    cell.textView.attributedText = string;
    
    [cell.textView setHashtagTapHandler:^{
        [self performSegueWithIdentifier:@"hashtagSegue" sender:self];
    }];
    
    for (NSTextCheckingResult *match in matches)
    {
        NSRange wordRange = match.range;
        [string addAttribute:NSForegroundColorAttributeName
                       value:[UIColor redColor]
                       range:wordRange];
        
        NSString *word = [text substringWithRange:wordRange];
        
        CGRect frame = [self frameOfTextRange:wordRange inTextView:cell.textView];
        
        NSLog(@"frame %@",NSStringFromCGRect(frame));
        
        // add a layer
        CALayer *tapLayer = [[CALayer alloc] init];
        tapLayer.anchorPoint = CGPointZero;
        tapLayer.frame = frame;
        tapLayer.backgroundColor = [UIColor blueColor].CGColor;
        tapLayer.opacity = 0.2f;
        
        [cell.textView.layer addSublayer:tapLayer];
    }
    cell.textView.attributedText = string;
    
    
    /*UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized:)];
    singleTap.numberOfTapsRequired = 1;
    [cell.textView addGestureRecognizer:singleTap];*/
    
    //[cell.textView becomeFirstResponder];
    
    CGRect frame = cell.textView.frame;
    frame.size.height = cell.textView.contentSize.height;
    cell.textView.frame = frame;
    
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

- (CGRect)frameOfTextRange:(NSRange)range inTextView:(UITextView *)textView
{
    UITextPosition *beginning = textView.beginningOfDocument;
    UITextPosition *start = [textView positionFromPosition:beginning offset:range.location];
    UITextPosition *end = [textView positionFromPosition:beginning offset:(range.location + range.length)];
    UITextRange *textRange = [textView textRangeFromPosition:start toPosition:end];
    return [textView firstRectForRange:textRange];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = [_tweet.infos objectForKey:@"text"];
    CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize: CGSizeMake( [GGDetailTweetTableViewCell TextLabelWidth] ,CGFLOAT_MAX )];
    
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
