//
//  GGDetailTweetViewController.h
//  BirdyNamNam
//
//  Created by Gwenn on 06/03/13.
//  Copyright (c) 2013 Free. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GGDetailTweetViewController : UITableViewController

@property (strong, nonatomic) NSManagedObjectID *managedObjectId;
@property (strong, nonatomic) NSManagedObjectContext *moc;
@property (strong, nonatomic) NSCache *imageCache;

@end
