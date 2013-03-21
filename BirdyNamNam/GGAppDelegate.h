//
//  GGAppDelegate.h
//  BirdyNamNam
//
//  Created by Gwenn on 21/02/13.
//  Copyright (c) 2013 Free. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>

@interface UILabel (GGExtensions)
- (void)sizeToFitFixedWidth;
@end

@implementation UILabel (GGExtensions)

- (void)sizeToFitFixedWidth
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 0);
    //self.lineBreakMode = NSLineBreakByWordWrapping;
    //self.numberOfLines = 0;
    [self sizeToFit];
}
@end

@interface GGAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
