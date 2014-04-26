//
//  WMWelcomeToWoundMapViewController_iPad.m
//  WoundMAP
//
//  Created by Todd Guion on 11/12/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMWelcomeToWoundMapViewController_iPad.h"
#import "ConstraintPack.h"

@interface WMWelcomeToWoundMapViewController_iPad ()

@property (strong, nonatomic) IBOutlet WMWelcomeToWoundMapViewController *welcomeViewController;      // loaded from nib
@property (strong, nonatomic) IBOutlet UIView *padLeftView;
@property (strong, nonatomic) IBOutlet UIView *padRightView;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeightConstraint;
@property (nonatomic) BOOL keyboardIsShowing;

@end

@interface WMWelcomeToWoundMapViewController_iPad (PrivateMethods)
- (void)updateViewsForRotation:(UIInterfaceOrientation)interfaceOrientation;
@end

@implementation WMWelcomeToWoundMapViewController_iPad (PrivateMethods)

- (void)updateViewsForRotation:(UIInterfaceOrientation)interfaceOrientation
{
//    CGFloat width = CGRectGetWidth(self.view.bounds);
//    CGFloat height = CGRectGetHeight(self.view.bounds);
//    if (!UIDeviceOrientationIsValidInterfaceOrientation(interfaceOrientation)) {
//        // use the width/height
//        interfaceOrientation = (width > height ? UIInterfaceOrientationLandscapeLeft:UIInterfaceOrientationPortrait);
//    }
//    CGRect frame = self.placeholderView.frame;
//    CGFloat containerWidth = CGRectGetWidth(frame);
//    frame.origin.x = roundf((width - containerWidth)/2.0);
//    self.placeholderView.frame = frame;
//    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
//        // adjust constraint
//        self.topBindingConstraint.constant = 100.0;
//    } else {
//        // adjust constraint
//        self.topBindingConstraint.constant = 36.0;
//    }
}

@end

@implementation WMWelcomeToWoundMapViewController_iPad

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
    // Do any additional setup after loading the view from its nib.
    self.title = @"Welcome to WoundMap";
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    UINavigationController *viewController = [[UINavigationController alloc] initWithRootViewController:self.welcomeViewController];
    [viewController setNavigationBarHidden:YES animated:NO];

    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
    
    UIView *childView = viewController.view;
    childView.translatesAutoresizingMaskIntoConstraints = NO;
    id topGuide = self.topLayoutGuide;
    _padLeftView = [[UIView alloc] initWithFrame:CGRectZero];
    _padLeftView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_padLeftView];
    _padRightView = [[UIView alloc] initWithFrame:CGRectZero];
    _padRightView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_padRightView];
    _bottomView = [[UIView alloc] initWithFrame:CGRectZero];
    _bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_bottomView];
    
    UIView *padLeftView = _padLeftView;
    UIView *padRightView = _padRightView;
    UIView *bottomView = _bottomView;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(topGuide, padLeftView, childView, padRightView, bottomView);

    _bottomViewHeightConstraint = [NSLayoutConstraint constraintWithItem:bottomView
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1.0
                                                                constant:120.0];
    [bottomView addConstraint:_bottomViewHeightConstraint];
    
    NSMutableArray *constraints = [NSMutableArray array];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topGuide][childView(>=420)]-(>=8)-[bottomView]|" options:NSLayoutFormatAlignAllLeading metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[padLeftView][childView(320)][padRightView(==padLeftView)]|" options:NSLayoutFormatAlignAllTop metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomView]|" options:NSLayoutFormatAlignAllBottom metrics:nil views:views]];

    [self.view addConstraints:constraints];

    [viewController didMoveToParentViewController:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(observeKeyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(observeKeyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
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
    // Dispose of any resources that can be recreated.
}

#pragma mark - Orientation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self updateViewsForRotation:toInterfaceOrientation];
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
    
    UIView *view = self.welcomeViewController.navigationController.view;
    CGRect rect = [view convertRect:view.frame toView:nil];
    
    // If the keyboard doesn't insersect the view's frame, then there's no need to adjust anything
    CGRect intersectionRect = CGRectIntersection(keyboardRect, rect);
    CGFloat height = CGRectGetHeight(intersectionRect);
    if (height == 0)
        return;
    
    // else adjust the bottom view height
    self.bottomViewHeightConstraint.constant = CGRectGetHeight(keyboardRect);
    
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
    
    _keyboardIsShowing = NO;
    
    self.bottomViewHeightConstraint.constant = 36.0;

    // Trigger a call to -viewWillLayoutSubviews inside the animation block
    [self.view setNeedsLayout];
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

@end
