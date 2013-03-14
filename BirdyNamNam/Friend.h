//
//  Friend.h
//  BirdyNamNam
//
//  Created by Gwenn on 14/03/13.
//  Copyright (c) 2013 Free. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Friend : NSManagedObject

@property (nonatomic, retain) NSString * friendid;
@property (nonatomic, retain) NSString * friendname;
@property (nonatomic, retain) NSString * friendscreenname;
@property (nonatomic, retain) NSString * friendprofileimageurl;

@end
