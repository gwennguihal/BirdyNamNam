//
//  GGTextUtil.h
//  BirdyNamNam
//
//  Created by Gwenn on 20/03/13.
//  Copyright (c) 2013 Free. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IndexedPosition : UITextPosition
{
    NSUInteger _index;
    id <UITextInputDelegate> _inputDelegate;
}
@property (nonatomic) NSUInteger index;
+ (IndexedPosition *)positionWithIndex:(NSUInteger)index;
@end

@interface IndexedRange : UITextRange
{
    NSRange _range;
}
@property (nonatomic) NSRange range;
+ (IndexedRange *)rangeWithNSRange:(NSRange)range;
@end
