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

@property (nonatomic, strong) NSString * tweetid;
@property (nonatomic, strong) NSString * json;
@property (nonatomic, strong, readonly) NSDictionary *infos;

@end
