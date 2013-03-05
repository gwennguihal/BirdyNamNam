//
//  Tweet.m
//  BirdyNamNam
//
//  Created by Gwenn on 04/03/13.
//  Copyright (c) 2013 Free. All rights reserved.
//

#import "Tweet.h"


@implementation Tweet

//@dynamic json;
@dynamic tweetid;
@dynamic json;
@synthesize infos = _infos;

- (NSDictionary*)infos
{
    if (_infos != nil)
    {
        return _infos;
    }
    
    NSData *data = [self.json dataUsingEncoding:NSUTF8StringEncoding];
    _infos = removeNull([NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil]);
    
    return _infos;
}

@end
