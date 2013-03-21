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

@property (strong,nonatomic) NSCache *imageCache;
@property (copy) DidSelectFriendBlock _selectionFriendBlock;

@end

@implementation GGUserSelectionViewController

@synthesize moc, imageCache, _selectionFriendBlock;

- (id)initWithStyle:(UITableViewStyle)style andManagedObjectContext:(NSManagedObjectContext*) managedObjectContext
{
    self = [super initWithStyle:style];
    if (self)
    {
        self.moc = managedObjectContext;
        [self.tableView registerNib:[UINib nibWithNibName:@"UserCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"UserTweetCell2"];
        
        self.tableView.frame = CGRectMake(20, 49, 320 - 20*2, 150);
        self.tableView.backgroundColor = [UIColor whiteColor];
        self.tableView.layer.borderColor = [UIColor blackColor].CGColor;
        self.tableView.layer.borderWidth = 1.0f;
        self.tableView.layer.cornerRadius = 8.0;
        self.tableView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.tableView.layer.shadowOpacity = 0.7;
        self.tableView.layer.shadowOffset = CGSizeMake(2.0, 2.0);
        self.tableView.layer.shadowRadius = 3.0;
    }
    return self;
}

- (void)setYPosition:(int)y
{
    CGRect frame = self.tableView.frame;
    frame.origin.y = y;
    self.tableView.frame = frame;
}

- (BOOL)searchWithName:(NSString *)name
{
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Friend"];
    if (name.length > 0)
    {
        request.predicate = [NSPredicate predicateWithFormat:@"(friendname CONTAINS[cd] %@) OR (friendscreenname CONTAINS[cd] %@)", name, name];
    }
    NSArray *search = [self.moc executeFetchRequest:request error:&error];
    if (search == nil)
    {
        NSLog(@"Fetching Friend failed %@, %@", error.description, error.userInfo );
        return NO;
    }
    if (search.count > 0)
    {
        self.friends = [search mutableCopy];
        [self.tableView reloadData];
        [self _loadAuthorImageForVisibleRows];
        return YES;
    }
    else
    {
        return NO;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    imageCache = [[NSCache alloc] init];
    
    [self.tableView reloadData];
    [self _loadAuthorImageForVisibleRows];
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
    
    return cell;
}

- (void)_loadAuthorImageForVisibleRows
{
    if (self.friends.count > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        
        for (NSIndexPath *indexPath in visiblePaths)
        {
            if (indexPath.row >= self.friends.count) return;
            
            Friend *friend = [self.friends objectAtIndex:indexPath.row];
            
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

- (void)setSelectionFriendHandler:(DidSelectFriendBlock)handler
{
    self._selectionFriendBlock = handler;
}


#pragma mark - ScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self _loadAuthorImageForVisibleRows];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Friend *friend = [self.friends objectAtIndex:indexPath.row];
    if (friend)
    {
        // call back block
        self._selectionFriendBlock(friend.friendscreenname);
    }
}

@end
