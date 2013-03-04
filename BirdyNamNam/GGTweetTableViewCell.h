//
//  GGTweetTableViewCell.h
//  BirdyNamNam
//
//  Created by Gwenn on 26/02/13.
//  Copyright (c) 2013 Free. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GGTweetTableViewCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *authorName;
@property (nonatomic,weak) IBOutlet UILabel *text;
@property (nonatomic,weak) IBOutlet UIImageView *authorImageView;


@end
