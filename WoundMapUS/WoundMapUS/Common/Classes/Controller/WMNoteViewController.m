//
//  WMNoteViewController.m
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 2/22/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//

#import "WMNoteViewController.h"
#import "ConstraintPack.h"

@interface WMNoteViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

/// Amount to inset content in this view controller. By default, this value will be calculated based on whether the view for this view controller intersects the status bar,
/// navigation bar, and tab bar. The contentInsets are also updated if the keyboard is displayed and its frame intersects with the frame of this controller's view.
@property (nonatomic) UIEdgeInsets contentInsets;
@property (nonatomic) BOOL assignedContentInsets;
@property (nonatomic) BOOL calculatedContentInsets;
@property (nonatomic) UIInterfaceOrientation orientationForCalculatedInsets;
@property (nonatomic) CGRect applicationFrameForCalculatedInsets;
@property (nonatomic) BOOL keyboardIsShowing;
@property (nonatomic) UIEdgeInsets contentInsetsBeforeShowingKeyboard;

@end

@implementation WMNoteViewController

@synthesize contentInsets = _contentInsets;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = self.delegate.label;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAction:)];
    
    // load text view
    UITextView* tv = [[UITextView alloc] initWithFrame:CGRectZero];
    tv.translatesAutoresizingMaskIntoConstraints = NO;
    tv.editable = YES;
    [self.view addSubview:tv];
    _textView = tv;
    _textView.text = self.delegate.note;

    // add constraints
//    [self updateTextViewContraints];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(observeKeyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(observeKeyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    [self.textView becomeFirstResponder];
}

- (void)updateTextViewContraints
{
    RemoveConstraints(self.view.constraints);
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings (_textView);
    NSDictionary *metrics = @{@"Bottom" : @(_contentInsets.bottom)};
    NSMutableArray *constraints = [NSMutableArray array];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_textView]-Bottom-|"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:viewsDictionary]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_textView]-|" options:NSLayoutFormatAlignAllLeading metrics:nil views:viewsDictionary]];
    [self.view addConstraints:constraints];
}

// DEBUG

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self updateTextViewContraints];
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [center removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Add code to clean up any of your own resources that are no longer necessary.
}

- (UIEdgeInsets)contentInsets
{
    if (_assignedContentInsets)
        return _contentInsets;
    
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    
    // If the content insets were calculated, and the orientation is the same, return calculated value
    if (_calculatedContentInsets && _orientationForCalculatedInsets == orientation && CGRectEqualToRect(applicationFrame, _applicationFrameForCalculatedInsets))
        return _contentInsets;
    
    // grab our frame in window coordinates
    CGRect rect = [self.view convertRect:self.view.frame toView:nil];
    
    // No value has been assigned, so we need to compute it
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    UITabBar *tabBar = self.tabBarController.tabBar;
    UIApplication *application = [UIApplication sharedApplication];
    
    UIEdgeInsets insets = UIEdgeInsetsZero;
    
    if (!application.statusBarHidden) {
        // The status bar is WEIRD. It doesn't seem to adjust when rotated.
        CGFloat height = (UIInterfaceOrientationIsPortrait(orientation) ? CGRectGetHeight(application.statusBarFrame) : CGRectGetWidth(application.statusBarFrame));
        
        if (CGRectGetMinY(rect) < height)
            insets.top += 20;
    }
    
    // If the navigation bar ISN'T hidden, we'll set our top inset to the bottom of the navigation bar. This allows the system to position things correctly to account for the double height status bar.
    if (!navigationBar.hidden) {
        // During rotation, the navigation bar (and possibly tab bar) doesn't resize immediately. Force it to have it's new size.
        [navigationBar sizeToFit];
        CGRect frame = navigationBar.frame;
        if (CGRectIntersectsRect(rect, frame))
            insets.top = CGRectGetMaxY(frame);
    }
    
    if (!tabBar.hidden) {
        // During rotation, the navigation bar (and possibly tab bar) doesn't resize immediately. Force it to have it's new size.
        [tabBar sizeToFit];
        CGRect frame = tabBar.frame;
        if (CGRectIntersectsRect(rect, frame))
            insets.bottom = CGRectGetHeight(frame);
    }
    
    _calculatedContentInsets = YES;
    _orientationForCalculatedInsets = orientation;
    _applicationFrameForCalculatedInsets = applicationFrame;
    _contentInsets = insets;
    
    return insets;
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets
{
    _contentInsets = contentInsets;
    _calculatedContentInsets = NO;
    _assignedContentInsets = YES;
    
    // I hope this triggers the VCs -viewDidLayoutSubviews method, which is where view layout should occur.
    [self.view setNeedsLayout];
}

#pragma mark - Keyboard

- (void)observeKeyboardWillShowNotification:(NSNotification *)note
{
    CGFloat animationDuration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardRect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (_keyboardIsShowing)
        return;
    
    // The keyboard rect is WRONG for landscape
    if (UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        keyboardRect.origin = CGPointMake(keyboardRect.origin.y, keyboardRect.origin.x);
        keyboardRect.size = CGSizeMake(keyboardRect.size.height, keyboardRect.size.width);
    }
    
    _keyboardIsShowing = YES;
    
    UIEdgeInsets insets = self.contentInsets;
    // Remember the previous contentInsets
    _contentInsetsBeforeShowingKeyboard = insets;
    
    UIView *view = self.view;
    CGRect rect = [view convertRect:view.frame toView:nil];
    
    // If the keyboard doesn't insersect the view's frame, then there's no need to adjust anything
    if (!CGRectIntersectsRect(keyboardRect, rect))
        return;
    
    // Jam the height of the keyboard as the bottom content inset
    insets.bottom = keyboardRect.size.height;
    // update the content insets, without flipping the assigned toggle.
    _contentInsets = insets;
    
    // Trigger a call to -viewWillLayoutSubviews inside the animation block
    [self.view setNeedsLayout];
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)observeKeyboardWillHideNotification:(NSNotification *)note
{
    CGFloat animationDuration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    if (!_keyboardIsShowing)
        return;
    
    _contentInsets = _contentInsetsBeforeShowingKeyboard;
    
    _keyboardIsShowing = NO;
    
    // Trigger a call to -viewWillLayoutSubviews inside the animation block
    [self.view setNeedsLayout];
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Actions

- (IBAction)saveAction:(id)sender
{
    [self.delegate noteViewController:self didUpdateNote:self.textView.text];
}

- (IBAction)cancelAction:(id)sender
{
    [self.delegate noteViewControllerDidCancel:self withNote:self.textView.text];
}

#pragma mark - BaseViewController

- (void)updateTitle
{
    // nothing
}

@end
