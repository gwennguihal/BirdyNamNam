//
//  GGDetailTweetTableViewCell.m
//  BirdyNamNam
//
//  Created by Gwenn on 06/03/13.
//  Copyright (c) 2013 Free. All rights reserved.
//

#import "GGDetailTweetTableViewCell.h"

@interface UITouchesTextView ()
@property (copy) DidTapOnHashtagBlock _hashtagTapBlock;
@end

@implementation UITouchesTextView

@synthesize _hashtagTapBlock;

-(void)setHashtagTapHandler:(DidTapOnHashtagBlock)handler
{
    _hashtagTapBlock = handler;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.superview]; // superview is necessary
    
    CALayer *hitLayer = [self.layer.presentationLayer hitTest:location].modelLayer;
    
    if (hitLayer)
    {
        NSLog(@"layer %@",hitLayer);
        if (_hashtagTapBlock)
        {
            _hashtagTapBlock();
        }
    }
    
    [super touchesBegan:touches withEvent:event];
    
    
}

@end

@implementation GGDetailTweetTableViewCell

@synthesize authorImageView, authorNameLabel, authorScreenNameLabel, textView, dateLabel;

static int _TextLabelWidth = 307 - 16;
static int _CellOffsetY = 112 + 51 + 8;

+ (int)CellOffsetY
{
    return _CellOffsetY;
}

+ (int)TextLabelWidth
{
    return _TextLabelWidth;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect newFrame = [self.dateLabel frame];
    newFrame.origin.y = self.textView.frame.origin.y + self.textView.frame.size.height;
    self.dateLabel.frame = newFrame;
    
    newFrame = [self.buttonsContainer frame];
    newFrame.origin.y = self.dateLabel.frame.origin.y + self.dateLabel.frame.size.height + 5;
    self.buttonsContainer.frame = newFrame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)reply:(id)sender
{
    
}

-(void)retweet:(id)sender
{
    
}

-(void)favorite:(id)sender
{
    
}


@end
