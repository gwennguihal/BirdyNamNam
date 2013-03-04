//
//  GGViewController.m
//  BirdyNamNam
//
//  Created by Gwenn on 21/02/13.
//  Copyright (c) 2013 Free. All rights reserved.
//

#import "GGViewController.h"

@interface GGViewController ()

@end

@implementation GGViewController

@synthesize twitterEngine;
@synthesize spinner;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.loginButton setHidden:YES];
    
    self.twitterEngine = [[FHSTwitterEngine alloc]initWithConsumerKey: [NSString stringWithUTF8String:twiterConsumerKey] andSecret: [NSString stringWithUTF8String:twiterConsumerSecret]];
}

- (void)checkLogin
{
    [self.spinner setHidden:NO];
    
    [self.twitterEngine loadAccessToken];
    NSString *username = self.twitterEngine.loggedInUsername;
    if (username.length > 0)
    {
        NSLog(@"Logged in as %@",username);
        [self performSegueWithIdentifier:@"afterLoginSegue" sender:self.view];
        
    } else
    {
        NSLog(@"You are not logged in.");
        [self.loginButton setHidden:NO];
        [self.loginButton setAlpha:0.0f];
        
        /*[UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1.0f];
        
        [self.loginButton setAlpha:1.0f];
        self.loginButton.center = self.spinner.center;*/
        
        /*[UIView animateWithDuration:0.5
                              delay:1.0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             self.basketTop.frame = basketTopFrame;
                             self.basketBottom.frame = basketBottomFrame;
                         }
                         completion:^(BOOL finished){
                             NSLog(@"Done!");
                         }];*/
        [UIView animateWithDuration:1.0f animations:^{
            [self.loginButton setAlpha:1.0f];
            self.loginButton.center = self.spinner.center;
        }];
        
        //[UIView commitAnimations];
    }
    
    [self.spinner setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLoginClick:(id)sender
{
    if (self.twitterEngine)
    {
        [self presentViewController:[self.twitterEngine OAuthLoginWindow] animated:YES completion:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self performSelector:@selector(checkLogin)withObject:nil afterDelay:1.0];

}
@end
