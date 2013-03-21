//
//  GGReplyViewController.m
//  BirdyNamNam
//
//  Created by Gwenn on 11/03/13.
//  Copyright (c) 2013 Free. All rights reserved.
//

#import "GGReplyViewController.h"
#import "GGUserSelectionViewController.h"

#define kTextFieldPaddingTop 8.0f
#define kFriendSelectorMarginTop 20.0f

@interface GGReplyViewController ()
{
    BOOL _friendSelectorDisplayed;

    int _contentOffsetYBeforeFriendSelector;
}

@property CALayer *shadowLayer;
@property UIImageView *imageVIew;
@property int _arobasePosition;

@end

@implementation GGReplyViewController

@synthesize shadowLayer, imageVIew, moc, friendSelector, _arobasePosition;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _friendSelectorDisplayed = NO;
    
    [self _registerForKeyboardNotifications];

    [self.textField becomeFirstResponder];
    self.textField.delegate = self;
    self.textField.text = [@"@" stringByAppendingString: [self.inReplyToScreenName stringByAppendingString: @" "] ];
    [self textViewDidChange:self.textField];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self addObserver:self forKeyPath:@"textField.frame" options:NSKeyValueObservingOptionOld context:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self removeObserver:self forKeyPath:@"textField.frame"];
}

- (void) _customize
{
    self.textField.layer.cornerRadius = 8.0;
    
    self.shadowLayer = [[CALayer alloc] init];
    
    [CATransaction begin];
    
    self.shadowLayer.frame = self.textField.frame;
    self.shadowLayer.borderColor = [UIColor lightGrayColor].CGColor;
    self.shadowLayer.borderWidth =1.5f;
    self.shadowLayer.cornerRadius = self.textField.layer.cornerRadius;
    self.shadowLayer.shadowColor = [UIColor blackColor].CGColor;
    self.shadowLayer.shadowOpacity = 0.7;
    self.shadowLayer.shadowOffset = CGSizeMake(2.0, 2.0);
    self.shadowLayer.shadowRadius = 3.0;
    
    CALayer *maskLayer = [[CALayer alloc] init];
    maskLayer.anchorPoint = CGPointZero;
    maskLayer.bounds = self.textField.bounds;
    maskLayer.backgroundColor = [UIColor blackColor].CGColor;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.textField.bounds);
    maskLayer.cornerRadius = 8.0;
    
    [self.shadowLayer setMask:maskLayer];
    
    [CATransaction commit];
    
    [self.view.layer insertSublayer:self.shadowLayer above:self.textField.layer];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"textField.frame"])
    {
        CGRect oldFrame = CGRectNull;
        CGRect newFrame = CGRectNull;
        if([change objectForKey:@"old"] != [NSNull null])
        {
            oldFrame = [[change objectForKey:@"old"] CGRectValue];
        }
        if([object valueForKeyPath:keyPath] != [NSNull null])
        {
            newFrame = [[object valueForKeyPath:keyPath] CGRectValue];
            newFrame = self.shadowLayer.frame;
            newFrame.size.height = [[object valueForKeyPath:keyPath] CGRectValue].size.height;
            self.shadowLayer.frame = newFrame;
            self.shadowLayer.mask.bounds = self.shadowLayer.bounds;
        }
    }
}

// Call this method somewhere in your view controller setup code.
- (void)_registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBoardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
}

- (void)keyBoardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect newControlBarFrame = self.controlBar.frame;
    newControlBarFrame.origin.y = self.view.frame.size.height - kbSize.height - self.controlBar.frame.size.height;
    self.controlBar.frame = newControlBarFrame;
    
    CGRect newTextFieldFrame = self.textField.frame;
    newTextFieldFrame.size.height = self.view.frame.size.height - self.navBar.frame.size.height - kbSize.height - self.controlBar.frame.size.height - 10;
    self.textField.frame = newTextFieldFrame;
    
    [self _customize];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    /*NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect newTextFieldFrame = self.textField.frame;
    newTextFieldFrame.size.height = self.view.frame.size.height - self.navBar.frame.size.height - kbSize.height - self.controlBar.frame.size.height - 10;
    self.textField.frame = newTextFieldFrame;*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)valid:(id)sender
{
    
}

- (IBAction)addPhoto:(id)sender
{
    [self startCameraControllerFromViewController:self usingDelegate:self];
}

- (IBAction)addPhotoFromLibrary:(id)sender
{
    [self startMediaBrowserFromViewController:self usingDelegate:self];
}

- (void)textViewDidChange:(UITextView *)textView
{
    // characters count
    int count = 160 - self.textField.text.length;
    self.charactersCountLabel.text = [NSString stringWithFormat:@"%d",count];
    self.validBtn.enabled = count > 0;
    
    // arobase type
    NSRange range = textView.selectedRange;
    range.location -= 1;
    range.length = 1;
    NSString *lastCharacter = [textView.text substringWithRange:range];
    if ( [lastCharacter isEqualToString:@"@"])
    {
        [self _arobaseHandler];
    }
    
    // friend selector
    if (_friendSelectorDisplayed)
    {
        if (self._arobasePosition > textView.text.length)
        {
            [self _removeFriendSelector];
            return;
        }
        
        range = textView.selectedRange;
        range.length = range.location - self._arobasePosition;
        range.location = self._arobasePosition;
        NSString *friendCharacters = [textView.text substringWithRange:range];
        if (![friendSelector searchWithName:friendCharacters])
        {
            [self _removeFriendSelector];
        }
    }
}

- (IBAction)addArobase:(id)sender
{
    [self insertString:@"@" intoTextView:self.textField];
    [self _arobaseHandler];
}

- (void) _removeFriendSelector
{
    // kill friend selector
    [friendSelector.tableView removeFromSuperview];
    _friendSelectorDisplayed = NO;
    friendSelector = nil;
    
    // set textview good
    self.textField.scrollEnabled = YES;
    [self.textField setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void) _arobaseHandler
{
    // add friends selector
    if (friendSelector == nil)
    {
        friendSelector = [[GGUserSelectionViewController alloc] initWithStyle:UITableViewStylePlain andManagedObjectContext:self.moc];
        GGReplyViewController * __weak weakSelf = self;
        [friendSelector setSelectionFriendHandler:^(NSString *friendScreenName) {
            NSLog(@"%@ %@",friendScreenName,[weakSelf.textField.text substringFromIndex:weakSelf._arobasePosition]);
            // replace friendname with name returned by friendSelector
            NSRange range = weakSelf.textField.selectedRange;
            range.length = range.location - weakSelf._arobasePosition;
            range.location = weakSelf._arobasePosition;
            
            [weakSelf replaceString:friendScreenName intoTextView:weakSelf.textField atRange:range];
            
            [weakSelf _removeFriendSelector];
        }];
    }
    if ([friendSelector searchWithName:@""])
    {
        // scroll textview
        CGPoint cursorPosition = [self.textField caretRectForPosition:self.textField.selectedTextRange.start].origin;
        [self.textField setContentOffset:CGPointMake(0, cursorPosition.y - kTextFieldPaddingTop) animated:YES];
        
        [self.view addSubview: friendSelector.tableView];
        [self.view bringSubviewToFront:friendSelector.tableView];
        [self.friendSelector setYPosition: self.textField.frame.origin.y + kTextFieldPaddingTop + kFriendSelectorMarginTop];
        _friendSelectorDisplayed = YES;
        self._arobasePosition = self.textField.selectedRange.location;
    }
    
    CGRect frame = self.textField.frame;
    frame.size.height = kTextFieldPaddingTop + kFriendSelectorMarginTop -1;
}

- (void) insertString: (NSString *) insertingString intoTextView: (UITextView *) textView
{
    NSRange range = textView.selectedRange;
    NSString * firstHalfString = [textView.text substringToIndex:range.location];
    NSString * secondHalfString = [textView.text substringFromIndex: range.location];
    textView.scrollEnabled = NO;  // turn off scrolling or you'll get dizzy ... I promise
    
    textView.text = [NSString stringWithFormat: @"%@%@%@",
                     firstHalfString,
                     insertingString,
                     secondHalfString];
    range.location += [insertingString length];
    textView.selectedRange = range;
    textView.scrollEnabled = YES;  // turn scrolling back on.
    
}

- (void) replaceString: (NSString *) insertingString intoTextView: (UITextView *) textView atRange: (NSRange) range
{
    NSString * firstHalfString = [textView.text substringToIndex:range.location];
    NSString * secondHalfString = [textView.text substringFromIndex: range.location + range.length];
    textView.scrollEnabled = NO;  // turn off scrolling or you'll get dizzy ... I promise
    
    textView.text = [NSString stringWithFormat: @"%@%@%@",
                     firstHalfString,
                     insertingString,
                     secondHalfString];
    range.length = 0;
    range.location += [insertingString length];
    textView.selectedRange = range;
    textView.scrollEnabled = YES;  // turn scrolling back on.
}

- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller usingDelegate: (id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate
{
    
    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO || delegate == nil || controller == nil )
    {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    //NSArray *avaiblesTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    //cameraUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = YES;
    
    cameraUI.delegate = delegate;
    
    //[controller presentModalViewController: cameraUI animated: YES];
    [controller presentViewController:cameraUI animated:YES completion:nil];
    
    return YES;
}

// For responding to the user accepting a newly-captured picture or movie
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo)
    {
        
        editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        
        if (editedImage)
        {
            imageToSave = editedImage;
        }
        else
        {
            imageToSave = originalImage;
        }
        
        int side = 60;
        
        if (self.imageVIew == nil)
        {
            self.imageVIew = [[UIImageView alloc] initWithFrame:CGRectMake(320 - side - 10, 54, side, side)];
            self.imageVIew.layer.cornerRadius = 4.0;
            self.imageVIew.clipsToBounds = YES;
            [self.view addSubview:self.imageVIew];
        }
        
        self.imageVIew.alpha = 0;
        self.imageVIew.image = imageToSave;
        
        UIEdgeInsets insets = self.textField.contentInset;
        
        CGRect newFrame = self.textField.frame;
        newFrame.size.width = 320 - 10 - (side + 5);
        
        insets.right = 10;
        //self.textField.scrollIndicatorInsets = insets;
        
        //self.textField.contentInset = UIEdgeInsetsMake(0, 0, 0,-side);
        
        [UIView animateWithDuration:1.0f animations:^{
            self.imageVIew.alpha = 1.0;
            self.textField.frame = newFrame;
                    }];
        
        // Save the new image (original or edited) to the Camera Roll
        //UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller usingDelegate: (id <UIImagePickerControllerDelegate,UINavigationControllerDelegate>) delegate
{
    
    if (([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO) || (delegate == nil) || (controller == nil))
    {
        return NO;
    }
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    mediaUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = YES;
    
    mediaUI.delegate = delegate;
    
    [controller presentViewController:mediaUI animated:YES completion:nil];
    return YES;
}

@end
