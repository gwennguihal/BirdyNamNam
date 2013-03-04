//
//  GGTweetTableViewCell.m
//  BirdyNamNam
//
//  Created by Gwenn on 26/02/13.
//  Copyright (c) 2013 Free. All rights reserved.
//

#import "GGTweetTableViewCell.h"

@implementation GGTweetTableViewCell

@synthesize authorImageView,authorName,text;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        text.lineBreakMode = NSLineBreakByWordWrapping;
        text.numberOfLines = 0;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
