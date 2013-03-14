//
//  GGReplyViewController.m
//  BirdyNamNam
//
//  Created by Gwenn on 11/03/13.
//  Copyright (c) 2013 Free. All rights reserved.
//

#import "GGReplyViewController.h"
#import "GGUserSelectionViewController.h"

@interface GGReplyViewController ()

@property UIView *shadowView;
@property UIImageView *imageVIew;

@end

@implementation GGReplyViewController

@synthesize shadowView, imageVIew, moc, friendSelector;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self _customize];
    
    //[self putView:self.textField insideShadowWithColor:[UIColor grayColor] andRadius:8.0 andOffset:CGSizeMake(2.0, 2.0) andOpacity:0.8];
    
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
    
    shadowView = [[UIView alloc] initWithFrame:self.textField.frame];
    shadowView.layer.masksToBounds = YES;
    shadowView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    shadowView.layer.borderWidth =1.5f;
    shadowView.layer.cornerRadius = 8.0;
    shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    shadowView.layer.shadowOpacity = 0.7;
    shadowView.layer.shadowOffset = CGSizeMake(2.0, 2.0);
    shadowView.layer.shadowRadius = 3.0;
    shadowView.userInteractionEnabled = NO;
    
    [self.view insertSubview:shadowView aboveSubview:self.textField];
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
            newFrame = self.shadowView.frame;
            newFrame.size.height = [[object valueForKeyPath:keyPath] CGRectValue].size.height;
            self.shadowView.frame = newFrame;
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
    //double duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect newControlBarFrame = self.controlBar.frame;
    newControlBarFrame.origin.y = self.view.frame.size.height - kbSize.height - self.controlBar.frame.size.height;
    self.controlBar.frame = newControlBarFrame;
    
    /*[UIView animateWithDuration:duration animations:^{
        self.controlBar.frame = newControlBarFrame;
    }];*/
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    
    CGRect newTextFieldFrame = self.textField.frame;
    newTextFieldFrame.size.height = self.view.frame.size.height - self.navBar.frame.size.height - kbSize.height - self.controlBar.frame.size.height - 10;
    self.textField.frame = newTextFieldFrame;
    
    /*UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-kbSize.height);
        [scrollView setContentOffset:scrollPoint animated:YES];
    }*/
}

- (void)textViewDidChange:(UITextView *)textView
{
    int count = 160 - self.textField.text.length;
    self.charactersCountLabel.text = [NSString stringWithFormat:@"%d",count];
    
    self.validBtn.enabled = count > 0;
    
    NSRange range = textView.selectedRange;
    range.location -= 1;
    range.length = 1;
    NSString *lastCharacter = [textView.text substringWithRange:range];
    if ([lastCharacter isEqualToString:@"@"])
    {
        GGUserSelectionViewController *userSelectionViewController = [[GGUserSelectionViewController alloc] initWithStyle:UITableViewStylePlain andManagedObjectContext:self.moc];
        [self.view addSubview: userSelectionViewController.tableView];
        [userSelectionViewController searchWithName:@"fe"];
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)addArobase:(id)sender
{
    //[self.textField.text str
    [self insertString:@"@" intoTextView:self.textField];
    /*friendSelector = [[GGUserSelectionViewController alloc] initWithStyle:UITableViewStylePlain andManagedObjectContext:self.moc];
    [self.view addSubview: friendSelector.tableView];
    //[self.view bringSubviewToFront:friendSelector.tableView];
    [friendSelector searchWithName:@"fe"];*/
    CGPoint cursorPosition = [self.textField caretRectForPosition:self.textField.selectedTextRange.start].origin;
    [self.textField setContentOffset:CGPointMake(0, cursorPosition.y) animated:YES];
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
