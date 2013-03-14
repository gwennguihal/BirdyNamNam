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

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    /*[self willAccessValueForKey:@"json"];
    NSError *error;
    NSData *data = [self.json dataUsingEncoding:NSUTF8StringEncoding];
    self.infos = removeNull([NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error]);
    if (self.infos == nil)
    {
        NSLog(@"Error parsing json %@,%@",error.description,error.userInfo);
    }
    [self didAccessValueForKey:@"json"];*/
}

- (NSDictionary*)infos
{
    if (_infos == nil)
    {
        [self willAccessValueForKey:@"json"];
        NSData *data = [self.json dataUsingEncoding:NSUTF8StringEncoding];
        _infos = removeNull([NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil]);
        [self didAccessValueForKey:@"json"];
    }
    
    return _infos;
}

@end
