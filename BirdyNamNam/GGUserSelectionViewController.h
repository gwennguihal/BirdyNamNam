//
//  GGUserSelectionViewController.h
//  BirdyNamNam
//
//  Created by Gwenn on 13/03/13.
//  Copyright (c) 2013 Free. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DidSelectFriendBlock)(NSString *friendScreenName);

@interface GGUserSelectionViewController : UITableViewController

@property (strong, nonatomic) NSManagedObjectContext *moc;
@property (strong, nonatomic) NSMutableArray* friends;

- (id)initWithStyle:(UITableViewStyle)style andManagedObjectContext:(NSManagedObjectContext*) managedObjectContext;
- (BOOL) searchWithName:(NSString*) name;
- (void) setYPosition:(int) y;
- (void) setSelectionFriendHandler:(DidSelectFriendBlock)handler;

@end
