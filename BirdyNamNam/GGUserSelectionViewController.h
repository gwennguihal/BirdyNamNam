//
//  GGUserSelectionViewController.h
//  BirdyNamNam
//
//  Created by Gwenn on 13/03/13.
//  Copyright (c) 2013 Free. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GGUserSelectionViewController : UITableViewController

@property (strong, nonatomic) NSManagedObjectContext *moc;
@property (strong, nonatomic) NSMutableArray* friends;

- (id)initWithStyle:(UITableViewStyle)style andManagedObjectContext:(NSManagedObjectContext*) managedObjectContext;
- (void) searchWithName:(NSString*) name;

@end
