//
//  GGDetailTweetTableViewCell.m
//  BirdyNamNam
//
//  Created by Gwenn on 06/03/13.
//  Copyright (c) 2013 Free. All rights reserved.
//

#import "GGDetailTweetTableViewCell.h"

@implementation GGDetailTweetTableViewCell

@synthesize authorImageView, authorNameLabel, authorScreenNameLabel, textLabel, dateLabel;

static int _TextLabelWidth = 307;
static int _CellOffsetY = 112 + 44 + 5;

+ (int)CellOffsetY
{
    return _CellOffsetY;
}

+ (int)TextLabelWidth
{
    return _TextLabelWidth;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //NSString *text = self.textLabel.text;
    
    //CGSize textSize = [text sizeWithFont:textLabel.font constrainedToSize: CGSizeMake( cell.textLabel.frame.size.width,CGFLOAT_MAX )];
    
    CGRect newFrame = [self.dateLabel frame];
    newFrame.origin.y = self.textLabel.frame.origin.y + self.textLabel.frame.size.height;
    self.dateLabel.frame = newFrame;
    
    newFrame = [self.buttonsContainer frame];
    newFrame.origin.y = self.dateLabel.frame.origin.y + self.dateLabel.frame.size.height + 5;
    self.buttonsContainer.frame = newFrame;
    
}

/*- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}*/

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
