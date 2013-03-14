//
//  GGFriendsListViewController.h
//  BirdyNamNam
//
//  Created by Gwenn on 14/03/13.
//  Copyright (c) 2013 Free. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GGFriendsListViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *moc;
@property (strong, nonatomic) FHSTwitterEngine *twitterEngine;
@property (strong, nonatomic) NSCache *imageCache;
@property (strong, nonatomic) NSFetchedResultsController *fetcher;

@end
