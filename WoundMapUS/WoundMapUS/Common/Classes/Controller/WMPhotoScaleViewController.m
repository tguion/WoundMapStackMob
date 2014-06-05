//
//  WMPhotoScaleViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/23/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMPhotoScaleViewController.h"
#import "WMScalingRulerView.h"
#import "WMWoundPhoto.h"
#import "ConstraintPack.h"
#import "WMNavigationCoordinator.h"
#import "WCAppDelegate.h"

CGFloat kRetartSetScaleTranlationFactor = 2.0;
CGFloat kRetartSetScaleFactor = 2.0;
CGFloat kRetartSetScaleUpFactor = 1.1;
CGFloat kRetartSetScaleDownFactor = 0.9;

@interface WMPhotoScaleViewController () <UIGestureRecognizerDelegate>

@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (readonly, nonatomic) WMWoundPhoto *woundPhoto;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet WMScalingRulerView *scalingRulerView;
@property (nonatomic) BOOL zoomedFlag;
@property (nonatomic) CGPoint retartedTranslation;                          // accumulate translations to slow the translation on view
@property (nonatomic) CGFloat retartedScaleFactor;                          // accumulated scale from pinch to slow scaling on view

@end

@interface WMPhotoScaleViewController (PrivateMethods)
- (CGPoint)retartedTranslationForTranlation:(CGPoint)translation;
- (CGFloat)retartedScaleForFactor:(CGFloat)factor;
@end

@implementation WMPhotoScaleViewController (PrivateMethods)

- (CGPoint)retartedTranslationForTranlation:(CGPoint)translation
{
    CGPoint point = CGPointZero;
    CGFloat x = self.retartedTranslation.x + translation.x;
    CGFloat y = self.retartedTranslation.y + translation.y;
    if (ABS(x) >= kRetartSetScaleTranlationFactor || ABS(y) >= kRetartSetScaleTranlationFactor) {
        NSInteger ix = x/kRetartSetScaleTranlationFactor;
        NSInteger iy = y/kRetartSetScaleTranlationFactor;
        point = CGPointMake(ix, iy);
        self.retartedTranslation = CGPointMake(x - ix * kRetartSetScaleTranlationFactor, y - iy * kRetartSetScaleTranlationFactor);
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
        if (factor * self.retartedScaleFactor <= kRetartSetScaleDownFactor) {
            retartedFactor = 1.0 - (1.0 - factor)/kRetartSetScaleFactor;
            self.retartedScaleFactor = 1.0;
        } else {
            self.retartedScaleFactor *= factor;
        }
    } else {
        // scaling up
        if (factor * self.retartedScaleFactor >= kRetartSetScaleUpFactor) {
            retartedFactor = 1.0 - (1.0 - factor)/kRetartSetScaleFactor;
            self.retartedScaleFactor = 1.0;
        } else {
            self.retartedScaleFactor *= factor;
        }
    }
    return retartedFactor;
}

@end

@implementation WMPhotoScaleViewController

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (WMWoundPhoto *)woundPhoto
{
    return self.appDelegate.navigationCoordinator.woundPhoto;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Set Scale";
    if (self == [self.navigationController.viewControllers objectAtIndex:0]) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                              target:self
                                                                                              action:@selector(cancelAction:)];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                           target:self
                                                                                           action:@selector(doneAction:)];
    // configure scalingRulerView
    self.pointsPerCentimeter = self.scalingRulerView.pointsPerCentimeter;
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
    // tap to zoom
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGestureRecognizer.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    // add constraints
    ConstrainToSuperview(_imageView, 1000);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    BOOL isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    _imageView.image = (isPad ? self.woundPhoto.thumbnailLarge:self.woundPhoto.thumbnail);
    [self.navigationController setToolbarHidden:YES animated:YES];
    self.retartedTranslation = CGPointZero;
    self.retartedScaleFactor = 1.0;
    [self.scalingRulerView reset];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Add code to clean up any of your own resources that are no longer necessary.
}

#pragma mark - Orientation

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.scalingRulerView reset];
    [self.scalingRulerView setNeedsDisplay];
}

#pragma mark - Actions

- (IBAction)doneAction:(id)sender
{
    [self.delegate photoScaleViewController:self didSetPointsPerCentimeter:(self.zoomedFlag ? self.pointsPerCentimeter/2.0:self.pointsPerCentimeter)];
}

- (IBAction)cancelAction:(id)sender
{
    [self.delegate photoScaleViewControllerDidCancel:self];
}

#pragma mark - Gesture Recognizer Handlers

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)panGesture
{
    CGPoint originalTranslation = [panGesture translationInView:self.view];
    if (CGPointEqualToPoint(originalTranslation, CGPointZero)) {
        return;
    }
    // else
    originalTranslation = [self retartedTranslationForTranlation:originalTranslation];
    CGFloat angle = [(NSNumber *)[self.scalingRulerView valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    CGPoint translation = CGPointApplyAffineTransform(originalTranslation, CGAffineTransformMakeRotation(-angle));
    self.scalingRulerView.transform = CGAffineTransformTranslate(self.scalingRulerView.transform, translation.x, translation.y);
    [panGesture setTranslation:CGPointMake(0, 0) inView:self.view];
}

- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)pinchGesture
{
    CGFloat factor = [pinchGesture scale];
    factor = [self retartedScaleForFactor:factor];
    self.scalingRulerView.scaleFactor *= factor;
    self.pointsPerCentimeter = self.scalingRulerView.pointsPerCentimeter;
    pinchGesture.scale = 1;
}

- (IBAction)handleRotateGesture:(UIRotationGestureRecognizer *)rotationGesture
{
    CGFloat rotation = rotationGesture.rotation;
    if (rotation == 0.0) {
        return;
    }
    // else
    self.scalingRulerView.transform = CGAffineTransformRotate(self.scalingRulerView.transform, rotation);
    rotationGesture.rotation = 0;
    //DLog(@"rotation: %f, accumulated: %@ transform: %@", rotation, self.woundPhoto.transformRotation, NSStringFromCGAffineTransform(self.scalingRulerView.transform));
}

- (IBAction)handleTapGesture:(UITapGestureRecognizer *)tapGesture
{
    self.zoomedFlag = !self.zoomedFlag;
    if (self.zoomedFlag) {
        // determine amount to translate the imageView to center the tap
        CGPoint locationInView = [tapGesture locationInView:self.view];
        CGPoint centerPointInView = CGPointMake(CGRectGetWidth(self.view.bounds)/2.0, CGRectGetHeight(self.view.bounds)/2.0);
        CGFloat tx = centerPointInView.x - locationInView.x;
        CGFloat ty = centerPointInView.y - locationInView.y;
        CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformMakeScale(2.0, 2.0), CGAffineTransformMakeTranslation(tx, ty));
        self.imageView.transform = transform;
    } else {
        self.imageView.transform = CGAffineTransformIdentity;
    }
}

#pragma mark - UIGestureRecognizerDelegate

// called when a gesture recognizer attempts to transition out of UIGestureRecognizerStatePossible. returning NO causes it to transition to UIGestureRecognizerStateFailed
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

@end
