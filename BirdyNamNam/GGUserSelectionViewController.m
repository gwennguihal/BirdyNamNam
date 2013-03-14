//
//  GGUserSelectionViewController.m
//  BirdyNamNam
//
//  Created by Gwenn on 13/03/13.
//  Copyright (c) 2013 Free. All rights reserved.
//

#import "GGUserSelectionViewController.h"
#import "Friend.h"

@interface GGUserSelectionViewController ()

@end

@implementation GGUserSelectionViewController

@synthesize moc;

- (id)initWithStyle:(UITableViewStyle)style andManagedObjectContext:(NSManagedObjectContext*) managedObjectContext
{
    self = [super initWithStyle:style];
    if (self)
    {
        self.moc = managedObjectContext;
        [self.tableView registerNib:[UINib nibWithNibName:@"UserCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"UserTweetCell2"];
        
        self.tableView.frame = CGRectMake(20, 49, 320 - 20*2, 100);
        self.tableView.layer.borderColor = [UIColor blackColor].CGColor;
        self.tableView.layer.borderWidth = 1.0f;
        self.tableView.layer.cornerRadius = 8.0;
        self.tableView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.tableView.layer.shadowOpacity = 0.7;
        self.tableView.layer.shadowOffset = CGSizeMake(2.0, 2.0);
        self.tableView.layer.shadowRadius = 3.0;
        //self.tableView.layer.masksToBounds = NO;
    }
    return self;
}

- (void)searchWithName:(NSString *)name
{
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Friend"];
    request.predicate = [NSPredicate predicateWithFormat:@"(friendname CONTAINS[cd] %@) OR (friendscreenname CONTAINS[cd] %@)", name, name];
    NSArray *search = [self.moc executeFetchRequest:request error:&error];
    if (search == nil)
    {
        NSLog(@"Fetching Friend failed %@, %@", error.description, error.userInfo );
    }
    if (search.count > 0)
    {
        NSLog(@"update friend");
        self.friends = [search mutableCopy];
        [self.tableView reloadData];
    }
    else
    {
        NSLog(@"new friend");
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //static NSString *CellIdentifier = @"UserTweetCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserTweetCell2"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UserTweetCell2"];
        //[[NSBundle mainBundle] loadNibNamed:@"UserCellView" owner:self options:nil];
        //cell = (UITableViewCell *)[nibs objectAtIndex:0];
    }
    
    Friend *friend = [self.friends objectAtIndex:indexPath.row];
    
    cell.textLabel.text = friend.friendname;
    cell.detailTextLabel.text = friend.friendscreenname;
    
    /*dispatch_async(GCDBackgroundThread, ^{
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
        }});*/
    
    return cell;
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
    NSLog(@"Texte : %@",[tableView cellForRowAtIndexPath:indexPath].textLabel.text);
}

@end
