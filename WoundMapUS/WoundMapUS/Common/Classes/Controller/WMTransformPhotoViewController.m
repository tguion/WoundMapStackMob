//
//  WMTransformPhotoViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/23/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMTransformPhotoViewController.h"
#import "MBProgressHUD.h"
#import "WMWound.h"
#import "WMWoundPhoto.h"
#import "WMPhoto.h"
#import "WMPhotoManager.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"
#import "WMNavigationCoordinator.h"
#import "ConstraintPack.h"
#import <QuartzCore/QuartzCore.h>

CGFloat kRetartTranlationFactor = 5.0;
CGFloat kRetartScaleFactor = 5.0;
CGFloat kRetartScaleUpFactor = 1.1;
CGFloat kRetartScaleDownFactor = 0.9;
CGFloat kRetartRotationFactor = 5.0;

@interface WMTransformPhotoViewController () <UIGestureRecognizerDelegate>

@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (readonly, nonatomic) WMWound *wound;
@property (readonly, nonatomic) WMWoundPhoto *woundPhoto;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) IBOutlet UIImageView *referenceImageView;       // shows reference or template woundPhoto to conform to
@property (strong, nonatomic) IBOutlet UIImageView *normalizingImageView;   // shows woundPhoto that we are creating a transform
@property (strong, nonatomic) IBOutlet UIView *orientationSuggestionView;   // view to tell user to rotate device

@property (strong, nonatomic) WMWoundPhoto *referenceWoundPhoto;            // previous woundPhoto for wound

@property (strong, nonatomic) NSTimer *hideNavigationBarTimer;

@property (nonatomic) CGPoint retartedTranslation;                          // accumulate translations to slow the translation on view
@property (nonatomic) CGFloat retartedScaleFactor;                          // accumulated scale from pinch to slow scaling on view

@property (nonatomic) BOOL didCancel;

- (void)handleHideNavigationBarTimerAction:(NSTimer *)timer;

@end

@interface WMTransformPhotoViewController (PrivateMethods)
- (void)initializeNormalizingImageView;
- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;
- (void)hideNavigationBarAfterDelay;
- (void)showOrHideSuggestionView;
- (CGPoint)retartedTranslationForTranlation:(CGPoint)translation;
- (CGFloat)retartedScaleForFactor:(CGFloat)factor;
- (CGFloat)retartedRotationForRotation:(CGFloat)rotation;
@end

@implementation WMTransformPhotoViewController (PrivateMethods)

- (void)initializeNormalizingImageView
{
    self.normalizingImageView.frame = self.referenceImageView.frame;
    self.retartedTranslation = CGPointZero;
    self.retartedScaleFactor = 1.0;
    // apply last transform
    __weak __typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:1.0
                     animations:^{
                         if (weakSelf.woundPhoto.isTransformIdentity) {
                             weakSelf.normalizingImageView.transform = CGAffineTransformIdentity;
                         } else {
                             CGAffineTransform transform = [weakSelf.woundPhoto transformForSize:weakSelf.view.bounds.size];
                             //DLog(@"Applying transform:%@ (stored:%@) with bounds:%@", NSStringFromCGAffineTransform(transform), NSStringFromCGAffineTransform(weakSelf.woundPhoto.transform), NSStringFromCGRect(weakSelf.view.bounds));
                             weakSelf.normalizingImageView.transform = transform;
                         }
                         if (weakSelf.referenceWoundPhoto.isTransformIdentity) {
                             weakSelf.referenceImageView.transform = CGAffineTransformIdentity;
                         } else {
                             CGAffineTransform transform = [weakSelf.referenceWoundPhoto transformForSize:weakSelf.view.bounds.size];
                             //DLog(@"Applying transform:%@ (stored:%@) with bounds:%@", NSStringFromCGAffineTransform(transform), NSStringFromCGAffineTransform(weakSelf.woundPhoto.transform), NSStringFromCGRect(weakSelf.view.bounds));
                             weakSelf.referenceImageView.transform = transform;
                         }
                     } completion:^(BOOL finished) {
                         // hide progress view
                         [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:NO];
                     }];
}

// scale and rotation transforms are applied relative to the layer's anchor point
// this method moves a gesture recognizer's view's anchor point between the user's fingers
- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        //        CGPoint initialCenter = piece.center;
        piece.layer.anchorPoint = CGPointMake(locationInView.x / CGRectGetWidth(piece.bounds), locationInView.y / CGRectGetHeight(piece.bounds));
        piece.center = locationInSuperview;
        //DLog(@"adjustAnchorPointForGestureRecognizer center: %@ -> %@", NSStringFromCGPoint(initialCenter), NSStringFromCGPoint(piece.center));
    }
}

- (void)hideNavigationBarAfterDelay
{
    self.hideNavigationBarTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                                   target:self
                                                                 selector:@selector(handleHideNavigationBarTimerAction:)
                                                                 userInfo:nil
                                                                  repeats:NO];
}

- (void)showOrHideSuggestionView
{
    BOOL showSuggestionFlag = NO;
    NSString *message = nil;
    if (UIDeviceOrientationIsPortrait(self.interfaceOrientation) && self.woundPhoto.landscapeOrientation) {
        showSuggestionFlag = YES;
        message = @"Please rotate you device to landscape to match the orientation when photo was taken.";
    } else if (UIDeviceOrientationIsLandscape(self.interfaceOrientation) && !self.woundPhoto.landscapeOrientation) {
        showSuggestionFlag = YES;
        message = @"Please rotate you device to portrait to match the orientation when photo was taken.";
    }
    if (showSuggestionFlag) {
        CGPoint centerPoint = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
        self.orientationSuggestionView.center = centerPoint;
        if (nil == self.orientationSuggestionView.superview) {
            [self.view addSubview:self.orientationSuggestionView];
        }
        UILabel *aLabel = (UILabel *)[self.orientationSuggestionView viewWithTag:1000];
        aLabel.text = message;
    } else {
        [self.orientationSuggestionView removeFromSuperview];
    }
}

- (CGPoint)retartedTranslationForTranlation:(CGPoint)translation
{
    CGPoint point = CGPointZero;
    CGFloat x = self.retartedTranslation.x + translation.x;
    CGFloat y = self.retartedTranslation.y + translation.y;
    if (ABS(x) >= kRetartTranlationFactor || ABS(y) >= kRetartTranlationFactor) {
        NSInteger ix = x/kRetartTranlationFactor;
        NSInteger iy = y/kRetartTranlationFactor;
        point = CGPointMake(ix, iy);
        self.retartedTranslation = CGPointMake(x - ix * kRetartTranlationFactor, y - iy * kRetartTranlationFactor);
    } else {
        self.retartedTranslation = CGPointMake(x, y);
    }
    return point;
}

- (CGFloat)retartedScaleForFactor:(CGFloat)factor
{
    CGFloat retartedFactor = 1.0;
    if (factor < 1.0) {
        // scaling down
        if (factor * self.retartedScaleFactor <= kRetartScaleDownFactor) {
            retartedFactor = 1.0 - (1.0 - factor)/kRetartScaleFactor;
            self.retartedScaleFactor = 1.0;
        } else {
            self.retartedScaleFactor *= factor;
        }
    } else {
        // scaling up
        if (factor * self.retartedScaleFactor >= kRetartScaleUpFactor) {
            retartedFactor = 1.0 - (1.0 - factor)/kRetartScaleFactor;
            self.retartedScaleFactor = 1.0;
        } else {
            self.retartedScaleFactor *= factor;
        }
    }
    return retartedFactor;
}

- (CGFloat)retartedRotationForRotation:(CGFloat)rotation
{
    return rotation/kRetartRotationFactor;
}

@end

@implementation WMTransformPhotoViewController

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (WMWound *)wound
{
    return self.appDelegate.navigationCoordinator.wound;
}

- (WMWoundPhoto *)woundPhoto
{
    return self.appDelegate.navigationCoordinator.woundPhoto;
}

- (NSManagedObjectContext *)managedObjectContext
{
    return [self.woundPhoto managedObjectContext];
}

#pragma mark - View

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
    // configure navigation
    self.title = @"Adjust Photo";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                           target:self
                                                                                           action:@selector(doneAction:)];
    // hide toolbar
    [self.navigationController setToolbarHidden:YES animated:NO];
    // adjust view
    self.orientationSuggestionView.layer.cornerRadius = 6.0;
    // add constraints
    ConstrainToSuperview(_referenceImageView, 1000);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    BOOL isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    self.normalizingImageView.image = (isPad ? self.woundPhoto.thumbnailLarge:self.woundPhoto.thumbnail);
    self.referenceWoundPhoto = [self.wound referenceWoundPhoto:self.woundPhoto];
    self.referenceImageView.image = (isPad ? self.referenceWoundPhoto.thumbnailLarge:self.referenceWoundPhoto.thumbnail);
    [self.view addSubview:self.normalizingImageView];
    [self showOrHideSuggestionView];
    [self.managedObjectContext.undoManager beginUndoGrouping];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // tap gesture recognizer
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.view addGestureRecognizer:tapGesture];
    // create pan gesture recognizer
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [panGesture setMaximumNumberOfTouches:1];
    [panGesture setDelegate:self];
    [self.view addGestureRecognizer:panGesture];
    // create pinch gesture recognizer
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [pinchGesture setDelegate:self];
    [self.view addGestureRecognizer:pinchGesture];
    // create rotation gesture recognizer
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotateGesture:)];
    [rotationGesture setDelegate:self];
    [self.view addGestureRecognizer:rotationGesture];
    // add long press to reset
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showResetMenu:)];
    [self.view addGestureRecognizer:longPressGesture];
    // initialize after all animations have completed
    [MBProgressHUD showHUDAddedToViewController:self animated:NO];
    [self performSelector:@selector(initializeNormalizingImageView) withObject:nil afterDelay:1.0];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
        if (_didCancel && self.managedObjectContext.undoManager.canUndo) {
            [self.managedObjectContext.undoManager undoNestedGroup];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Add code to clean up any of your own resources that are no longer necessary.
    _referenceWoundPhoto = nil;
}

- (WMWoundPhoto *)referenceWoundPhoto
{
    if (nil == _referenceWoundPhoto) {
        _referenceWoundPhoto = [self.wound referenceWoundPhoto:self.woundPhoto];
    }
    return _referenceWoundPhoto;
}

#pragma mark - Orientation and Rotation

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if (self.woundPhoto.landscapeOrientation) {
        return UIInterfaceOrientationLandscapeLeft;
    }
    // else
    return UIInterfaceOrientationPortrait;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (self.woundPhoto.landscapeOrientation) {
        return UIInterfaceOrientationMaskLandscape;
    }
    // else
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self showOrHideSuggestionView];
    [self initializeNormalizingImageView];
}

#pragma mark - Actions

- (IBAction)handleTapGesture:(UITapGestureRecognizer *)tapGesture
{
    if ([tapGesture state] == UIGestureRecognizerStateEnded) {
        BOOL isNavigationBarHidden = !self.navigationController.isNavigationBarHidden;
        //        [self.navigationController setNavigationBarHidden:isNavigationBarHidden animated:YES];
        if (isNavigationBarHidden) {
            // hide after 5 secs
            [self hideNavigationBarAfterDelay];
        }
    }
}

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)panGesture
{
    CGPoint translation = [panGesture translationInView:self.view];
    translation = [self retartedTranslationForTranlation:translation];
    self.normalizingImageView.transform = CGAffineTransformTranslate(self.normalizingImageView.transform, translation.x, translation.y);
    [panGesture setTranslation:CGPointMake(0, 0) inView:self.view];
    [self.woundPhoto updateTranslation:translation];
    self.woundPhoto.transform = self.normalizingImageView.transform;
    //DLog(@"translation: %@, accumulated: %@ transform: %@", NSStringFromCGPoint(translation), NSStringFromCGPoint(self.woundPhoto.translation), NSStringFromCGAffineTransform(self.normalizingImageView.transform));
}

- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)pinchGesture
{
    CGFloat factor = [pinchGesture scale];
    factor = [self retartedScaleForFactor:factor];
    self.normalizingImageView.transform = CGAffineTransformScale(self.normalizingImageView.transform, factor, factor);
    pinchGesture.scale = 1;
    [self.woundPhoto updateScale:factor];
    self.woundPhoto.transform = self.normalizingImageView.transform;
    //DLog(@"scale: %f, accumulated: %@ transform: %@", factor, self.woundPhoto.transformScale, NSStringFromCGAffineTransform(self.normalizingImageView.transform));
}

- (IBAction)handleRotateGesture:(UIRotationGestureRecognizer *)rotationGesture
{
    [self adjustAnchorPointForGestureRecognizer:rotationGesture];
    CGFloat rotation = rotationGesture.rotation;
    rotation = [self retartedRotationForRotation:rotation];
    self.normalizingImageView.transform = CGAffineTransformRotate(self.normalizingImageView.transform, rotation);
    rotationGesture.rotation = 0;
    [self.woundPhoto updateRotation:rotation];
    self.woundPhoto.transform = self.normalizingImageView.transform;
    //DLog(@"rotation: %f, accumulated: %@ transform: %@", rotation, self.woundPhoto.transformRotation, NSStringFromCGAffineTransform(self.normalizingImageView.transform));
}

// display a menu with a single item to allow the piece's transform to be reset
- (void)showResetMenu:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        UIMenuItem *resetMenuItem = [[UIMenuItem alloc] initWithTitle:@"Reset" action:@selector(resetTransform:)];
        CGPoint location = [gestureRecognizer locationInView:[gestureRecognizer view]];
        
        [self.view becomeFirstResponder];
        [menuController setMenuItems:[NSArray arrayWithObject:resetMenuItem]];
        [menuController setTargetRect:CGRectMake(location.x, location.y, 0, 0) inView:self.normalizingImageView];
        [menuController setMenuVisible:YES animated:YES];
    }
}

// animate back to the default anchor point and transform
- (void)resetTransform:(UIMenuController *)controller
{
    [[self.normalizingImageView layer] setAnchorPoint:CGPointMake(0.5, 0.5)];
    self.normalizingImageView.transform = CGAffineTransformIdentity;
    self.normalizingImageView.frame = self.referenceImageView.frame;
    [self.woundPhoto resetTransform];
}

- (IBAction)doneAction:(id)sender
{
    // save the bounds use to translate
    self.woundPhoto.transformSizeAsString = NSStringFromCGSize(self.view.bounds.size);
    self.woundPhoto.transform = self.normalizingImageView.transform;
    [self.managedObjectContext MR_saveToPersistentStoreAndWait];
    [self.delegate tranformPhotoViewController:self didTransformPhoto:self.woundPhoto];
}

- (IBAction)cancelAction:(id)sender
{
    _didCancel = YES;
    [self.delegate tranformPhotoViewControllerDidCancel:self];
}

- (void)handleHideNavigationBarTimerAction:(NSTimer *)timer
{
    //    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [_hideNavigationBarTimer invalidate];
    _hideNavigationBarTimer = nil;
    [self.orientationSuggestionView removeFromSuperview];
}

#pragma mark - UIGestureRecognizerDelegate

// called when a gesture recognizer attempts to transition out of UIGestureRecognizerStatePossible. returning NO causes it to transition to UIGestureRecognizerStateFailed
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

// called when the recognition of one of gestureRecognizer or otherGestureRecognizer would be blocked by the other
// return YES to allow both to recognize simultaneously. the default implementation returns NO (by default no two gestures can be recognized simultaneously)
//
// note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

// called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

@end
