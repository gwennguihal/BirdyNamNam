//
//  GGDetailTweetTableViewCell.h
//  BirdyNamNam
//
//  Created by Gwenn on 06/03/13.
//  Copyright (c) 2013 Free. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GGDetailTweetTableViewCell : UITableViewCell

@property (strong,nonatomic) IBOutlet UILabel *authorNameLabel;
@property (strong,nonatomic) IBOutlet UILabel *authorScreenNameLabel;
@property (strong,nonatomic) IBOutlet UILabel *textLabel;
@property (strong,nonatomic) IBOutlet UILabel *dateLabel;
@property (strong,nonatomic) IBOutlet UIImageView *authorImageView;

+ (int)CellOffsetY;
+ (int)TextLabelWidth;

@end
