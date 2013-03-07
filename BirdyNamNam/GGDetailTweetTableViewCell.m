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

static int _TextLabelWidth;
static int _CellOffsetY;

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
    
    CGRect newFrame = self.dateLabel.frame;
    newFrame.origin.y = self.textLabel.frame.origin.y + self.textLabel.frame.size.height;
    
    self.dateLabel.frame = newFrame;
    
    _TextLabelWidth = self.textLabel.frame.size.width;
    _CellOffsetY = self.dateLabel.frame.origin.y + self.dateLabel.frame.size.height;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
