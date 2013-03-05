//
//  Tweet.h
//  BirdyNamNam
//
//  Created by Gwenn on 04/03/13.
//  Copyright (c) 2013 Free. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Tweet : NSManagedObject

@property (nonatomic, retain) NSString * tweetid;
@property (nonatomic, retain) NSString * json;
@property (nonatomic, strong, readonly) NSDictionary *infos;

@end
