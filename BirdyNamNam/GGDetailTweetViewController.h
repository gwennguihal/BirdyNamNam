//
//  GGDetailTweetViewController.h
//  BirdyNamNam
//
//  Created by Gwenn on 06/03/13.
//  Copyright (c) 2013 Free. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FHSTwitterEngine.h"

@interface GGDetailTweetViewController : UITableViewController

@property (strong, nonatomic) NSManagedObjectID *managedObjectId;
@property (strong, nonatomic) NSManagedObjectContext *moc;
@property (strong, nonatomic) NSCache *imageCache;
@property (strong, nonatomic) FHSTwitterEngine *twitterEngine;

@property (strong, nonatomic) NSMutableArray *ascendantTweets;
@property (strong, nonatomic) NSMutableArray *descendantTweets;

@end
