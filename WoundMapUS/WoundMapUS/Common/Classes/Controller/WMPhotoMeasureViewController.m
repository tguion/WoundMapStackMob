//
//  WMPhotoMeasureViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/23/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMPhotoMeasureViewController.h"
#import "WMWidthHeightOverlayView.h"
#import "WMDimensionView.h"
#import "WMWound.h"
#import "WMWoundPhoto.h"
#import "WMWoundMeasurementGroup.h"
#import "WMWoundMeasurementValue.h"
#import "WMFatFractal.h"
#import "WMNavigationCoordinator.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"

@interface WMPhotoMeasureViewController () <UIGestureRecognizerDelegate>

@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (readonly, nonatomic) WMWoundPhoto *woundPhoto;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet WMWidthHeightOverlayView *widthHeightOverlayView;
@property (weak, nonatomic) IBOutlet WMDimensionView *dimensionView;
@property (readonly, nonatomic) NSDecimalNumber *widthInCentimeters;
@property (readonly, nonatomic) NSDecimalNumber *lengthInCentimeters;
@property (strong, nonatomic) NSDecimalNumberHandler *roundingBehavior;
@property (nonatomic) BOOL zoomedFlag;
@property (readonly, nonatomic) CGFloat pointsPerCentimeterAdjustedForZoom;

@end

@interface WMPhotoMeasureViewController (PrivateMethods)
- (void)updateModel;
- (void)resetMeasurementViews;
@end

@implementation WMPhotoMeasureViewController (PrivateMethods)

- (void)updateModel
{
    self.woundPhoto.measurementGroup.measurementValueLength.value = [self.lengthInCentimeters stringValue];
    self.woundPhoto.measurementGroup.measurementValueWidth.value = [self.widthInCentimeters stringValue];
}

- (void)resetMeasurementViews
{
    [self.widthHeightOverlayView resetWithPointsPerCentemeter:self.pointsPerCentimeterAdjustedForZoom];
    self.dimensionView.transform = CGAffineTransformIdentity;
    self.dimensionView.frame = self.widthHeightOverlayView.frame;
    [self.dimensionView updateForRect:self.widthHeightOverlayView.woundRect pointsPerCentimeter:self.pointsPerCentimeterAdjustedForZoom transform:self.widthHeightOverlayView.transform];
    self.dimensionView.hidden = NO;
}

@end

@implementation WMPhotoMeasureViewController

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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Measure (cm)";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                           target:self
                                                                                           action:@selector(doneAction:)];
    // create pan gesture recognizer
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [panGesture setMaximumNumberOfTouches:1];
    [panGesture setDelegate:self];
    [self.view addGestureRecognizer:panGesture];
    // create rotation gesture recognizer
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotateGesture:)];
    [rotationGesture setDelegate:self];
    [self.view addGestureRecognizer:rotationGesture];
    // tap to zoom
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGestureRecognizer.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    BOOL isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    _imageView.image = (isPad ? self.woundPhoto.thumbnailLarge:self.woundPhoto.thumbnail);
    [self resetMeasurementViews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Add code to clean up any of your own resources that are no longer necessary.
    _roundingBehavior = nil;
}

#pragma mark - Orientation

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    // configure widthHeightOverlayView
    [self resetMeasurementViews];
}

#pragma mark - Core

- (CGFloat)pointsPerCentimeterAdjustedForZoom
{
    return self.zoomedFlag ? 2.0 * self.pointsPerCentimeter:self.pointsPerCentimeter;
}

- (void)setPointsPerCentimeter:(CGFloat)pointsPerCentimeter
{
    [self willChangeValueForKey:@"pointsPerCentimeter"];
    _pointsPerCentimeter = pointsPerCentimeter;
    [self didChangeValueForKey:@"pointsPerCentimeter"];
    self.widthHeightOverlayView.pointsPerCentimeter = pointsPerCentimeter;
}

- (NSDecimalNumber *)widthInCentimeters
{
    return [[[NSDecimalNumber alloc] initWithFloat:CGRectGetWidth(self.widthHeightOverlayView.woundRect)/self.pointsPerCentimeterAdjustedForZoom] decimalNumberByRoundingAccordingToBehavior:self.roundingBehavior];
}

- (NSDecimalNumber *)lengthInCentimeters
{
    return [[[NSDecimalNumber alloc] initWithFloat:CGRectGetHeight(self.widthHeightOverlayView.woundRect)/self.pointsPerCentimeterAdjustedForZoom] decimalNumberByRoundingAccordingToBehavior:self.roundingBehavior];
}

- (NSDecimalNumberHandler *)roundingBehavior
{
    if (nil == _roundingBehavior) {
        _roundingBehavior = [[NSDecimalNumberHandler alloc] initWithRoundingMode:NSRoundPlain
                                                                           scale:1
                                                                raiseOnExactness:NO
                                                                 raiseOnOverflow:NO
                                                                raiseOnUnderflow:NO
                                                             raiseOnDivideByZero:NO];
    }
    return _roundingBehavior;
}

#pragma mark - Actions

- (IBAction)doneAction:(id)sender
{
    [self updateModel];
    // update back end
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMWoundPhoto *woundPhoto = self.woundPhoto;
    WMWound *wound = woundPhoto.wound;
    WMWoundMeasurementGroup *woundMeasurementGroup = self.woundPhoto.measurementGroup;
    __block NSInteger counter = 0;
    __weak __typeof(&*self)weakSelf = self;
    dispatch_block_t block = ^{
        [weakSelf.delegate photoMeasureViewControllerDelegate:weakSelf length:weakSelf.lengthInCentimeters width:weakSelf.widthInCentimeters];
    };
    FFHttpMethodCompletion completionHandler = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        } else {
            --counter;
            if (counter == 0) {
                block();
            }
        }
    };
    FFHttpMethodCompletion createdCompletionHandler = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        } else {
            ++counter;
            [ff grabBagAddItemAtFfUrl:woundMeasurementGroup.ffUrl
                         toObjAtFfUrl:wound.ffUrl
                          grabBagName:WMWoundRelationships.measurementGroups
                           onComplete:completionHandler];
            ++counter;
            [ff grabBagAddItemAtFfUrl:woundMeasurementGroup.ffUrl
                         toObjAtFfUrl:woundPhoto.ffUrl
                          grabBagName:WMWoundPhotoRelationships.measurementGroups
                           onComplete:completionHandler];
        }
    };
    if (!woundMeasurementGroup.ffUrl) {
        [ff createObj:woundMeasurementGroup
                atUri:[NSString stringWithFormat:@"/%@", [WMWoundMeasurementGroup entityName]]
           onComplete:createdCompletionHandler
            onOffline:createdCompletionHandler];
    } else {
        block();
    }
}

#pragma mark - WidthHeightOverlayViewDelegate

- (void)widthHeightOverlayView:(WMWidthHeightOverlayView *)widthHeightOverlayView didUpdateWoundRect:(CGRect)woundRect
{
    [self.dimensionView updateForRect:woundRect pointsPerCentimeter:self.pointsPerCentimeterAdjustedForZoom transform:self.widthHeightOverlayView.transform];
}

#pragma mark - Gesture Recognizer Handlers

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)panGesture
{
    CGPoint originalTranslation = [panGesture translationInView:self.view];
    if (CGPointEqualToPoint(originalTranslation, CGPointZero)) {
        return;
    }
    // else
    CGFloat angle = [(NSNumber *)[self.widthHeightOverlayView valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    CGPoint translation = CGPointApplyAffineTransform(originalTranslation, CGAffineTransformMakeRotation(-angle));
    self.widthHeightOverlayView.transform = CGAffineTransformTranslate(self.widthHeightOverlayView.transform, translation.x, translation.y);
    [panGesture setTranslation:CGPointMake(0, 0) inView:self.view];
    self.dimensionView.transform = self.widthHeightOverlayView.transform;
}

- (IBAction)handleRotateGesture:(UIRotationGestureRecognizer *)rotationGesture
{
    CGFloat rotation = rotationGesture.rotation;
    if (rotation == 0.0) {
        return;
    }
    // else
    self.widthHeightOverlayView.transform = CGAffineTransformRotate(self.widthHeightOverlayView.transform, rotation);
    rotationGesture.rotation = 0;
    //    DLog(@"rotation: %f, accumulated: %@ transform: %@", rotation, self.woundPhoto.transformRotation, NSStringFromCGAffineTransform(self.widthHeightOverlayView.transform));
    self.dimensionView.transform = self.widthHeightOverlayView.transform;
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
    [self resetMeasurementViews];
}

#pragma mark - UIGestureRecognizerDelegate

// called when a gesture recognizer attempts to transition out of UIGestureRecognizerStatePossible. returning NO causes it to transition to UIGestureRecognizerStateFailed
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

@end
