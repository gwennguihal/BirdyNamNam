//
//  GGTimeLineViewController.h
//  BirdyNamNam
//
//  Created by Gwenn on 22/02/13.
//  Copyright (c) 2013 Free. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GGTimeLineViewController : UITableViewController <UIScrollViewDelegate>

@property NSManagedObjectContext *moc;
@property FHSTwitterEngine *twitterEngine;
@property NSMutableArray *tweets;
@property NSCache *imageCache;
@property NSFetchedResultsController *fetcher;

@end
