//
//  GGReplyViewController.h
//  BirdyNamNam
//
//  Created by Gwenn on 11/03/13.
//  Copyright (c) 2013 Free. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GGUserSelectionViewController.h"

@interface GGReplyViewController : UIViewController <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *validBtn;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIToolbar *controlBar;
@property (weak, nonatomic) IBOutlet UILabel *charactersCountLabel;

@property (strong, nonatomic) NSString *inReplyToScreenName;

@property (strong, nonatomic) NSManagedObjectContext *moc;

@property (strong, nonatomic) GGUserSelectionViewController *friendSelector;

- (IBAction)cancel:(id)sender;
- (IBAction)valid:(id)sender;
- (IBAction)addPhoto:(id)sender;
- (IBAction)addPhotoFromLibrary:(id)sender;
- (IBAction)addArobase:(id)sender;
@end
