//
//  GGViewController.h
//  BirdyNamNam
//
//  Created by Gwenn on 21/02/13.
//  Copyright (c) 2013 Free. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GGViewController : UIViewController

@property (strong, nonatomic) FHSTwitterEngine *twitterEngine;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

- (IBAction)onLoginClick:(id)sender;
- (void)checkLogin;

@end
