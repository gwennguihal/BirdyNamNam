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

@property (strong,nonatomic) IBOutlet UIButton *replyBtn;
@property (strong,nonatomic) IBOutlet UIButton *retweetBtn;
@property (strong,nonatomic) IBOutlet UIButton *favoriteBtn;

@property (strong,nonatomic) IBOutlet UIView *buttonsContainer;

-(IBAction)reply:(id)sender;
-(IBAction)retweet:(id)sender;
-(IBAction)favorite:(id)sender;

+ (int)CellOffsetY;
+ (int)TextLabelWidth;

@end
