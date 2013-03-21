//
//  GGTextUtil.m
//  BirdyNamNam
//
//  Created by Gwenn on 20/03/13.
//  Copyright (c) 2013 Free. All rights reserved.
//

#import "GGTextUtil.h"

@implementation IndexedPosition
@synthesize index = _index;

+ (IndexedPosition *)positionWithIndex:(NSUInteger)index
{
    IndexedPosition *pos = [[IndexedPosition alloc] init];
    pos.index = index;
    return pos;
}

@end

@implementation IndexedRange
@synthesize range = _range;

+ (IndexedRange *)rangeWithNSRange:(NSRange)nsrange {
    if (nsrange.location == NSNotFound)
        return nil;
    IndexedRange *range = [[IndexedRange alloc] init];
    range.range = nsrange;
    return range;
}

- (UITextPosition *)start {
    return [IndexedPosition positionWithIndex:self.range.location];
}

- (UITextPosition *)end {
    return [IndexedPosition positionWithIndex:(self.range.location + self.range.length)];
}

-(BOOL)isEmpty {
    return (self.range.length == 0);
}
@end
