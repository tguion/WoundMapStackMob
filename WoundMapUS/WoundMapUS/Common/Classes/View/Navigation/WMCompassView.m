    //
//  WMCompassView.m
//  WoundPUMP
//
//  Created by Todd Guion on 7/13/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMCompassView.h"
#import "WMNavigationNodeButton.h"
#import "WMPatientPhotoImageView.h"
#import "WMPatient.h"
#import "WMWound.h"
#import "WMNavigationPatientPhotoButton.h"
#import "WMNavigationCoordinator.h"
#import "WMPolicyManager.h"
#import "WMDesignUtilities.h"
#import "WCAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

CGAffineTransform CompassTransformWest;
CGAffineTransform CompassTransformNorth;
CGAffineTransform CompassTransformEast;
CGAffineTransform CompassTransformSouth;

CGFloat const kNavigationNodeButtonEdgeInset = 4.0;

@interface WMCompassView ()

@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (readonly, nonatomic) WMPatient *patient;
@property (readonly, nonatomic) WMWound *wound;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) WMPolicyManager *policyManager;
@property (strong, nonatomic) NSArray *previousNavigationNodeControls;
@property (assign, nonatomic) BOOL navigationNodeControlsActiveFlag;            // YES is nav controls are in active position
@property (weak, nonatomic) WMPatientPhotoImageView *patientImageView;
@property (weak, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) IBOutlet UILabel *returnToPreviousLevelView;

@property (nonatomic) CGRect compassImageViewFrame;                             // acquire before transforms
@property (nonatomic) CGRect clippingRect;

@end

@implementation WMCompassView

@synthesize rotationState=_rotationState;
@dynamic hasNavigationNodeControls;
@synthesize navigationNodeControls=_navigationNodeControls, previousNavigationNodeControls=_previousNavigationNodeControls;

+ (void)initialize
{
    if (self == [WMCompassView class]) {
        CompassTransformWest = CGAffineTransformMakeRotation(M_PI);
        CompassTransformNorth = CGAffineTransformMakeRotation(-M_PI_2);
        CompassTransformEast = CGAffineTransformIdentity;
        CompassTransformSouth = CGAffineTransformMakeRotation(M_PI_2);
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.rotationState = MapBaseRotationDirection_East;
    WMPatientPhotoImageView *patientImageView = [[WMPatientPhotoImageView alloc] initWithFrame:CGRectInset(self.patientPhotoView.frame, 10.0, 10.0)];
    [self insertSubview:patientImageView belowSubview:self.patientPhotoView];
    _patientImageView = patientImageView;
    _returnToPreviousLevelView.textColor = [UIColor whiteColor];
    _patientImageView.returnToPreviousLevelView = _returnToPreviousLevelView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.rotationState = MapBaseRotationDirection_East;
    }
    return self;
}

#pragma mark - Core

- (void)recalculateDimensions
{
    self.compassImageViewFrame = self.compassNeedleImage.frame;
    CGFloat delta = MIN(CGRectGetWidth(self.compassNeedleImage.frame), CGRectGetHeight(self.compassNeedleImage.frame));
    CGFloat midX = CGRectGetMidX(self.bounds);
    CGFloat midY = CGRectGetMidY(self.bounds);
    self.clippingRect = CGRectMake(midX - delta/2.0, midY - delta/2.0, delta, delta);
}

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (NSManagedObjectContext *)managedObjectContext
{
    return self.patient.managedObjectContext;
}

- (WMPolicyManager *)policyManager
{
    return [WMPolicyManager sharedInstance];;
}

- (WMPatient *)patient
{
    return self.appDelegate.navigationCoordinator.patient;
}

- (WMWound *)wound
{
    return self.appDelegate.navigationCoordinator.wound;
}

- (BOOL)hasNavigationNodeControls
{
    return [self.navigationNodeControls count] > 0;
}

- (void)updateForPatient:(WMPatient *)patient
{
    [self.patientImageView updateForPatient:patient];
    [self.patientPhotoView updateForPatient:patient];
}

- (void)updateForPatientPhotoProcessing
{
    if (nil != _activityIndicatorView.superview) {
        return;
    }
    // else
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicatorView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [self addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
    _activityIndicatorView = activityIndicatorView;
}

- (void)updateForPatientPhotoProcessed
{
    [_activityIndicatorView removeFromSuperview];
    _activityIndicatorView = nil;
}

// animate in controls
- (void)setNavigationNodeControls:(NSArray *)navigationNodeControls
{
    if ([_navigationNodeControls isEqualToArray:navigationNodeControls]) {
        return;
    }
    if (nil == navigationNodeControls) {
        // remove the old controls
        [_navigationNodeControls makeObjectsPerformSelector:@selector(removeFromSuperview)];
        _navigationNodeControls = nil;
        return;
    }
    // else add controls under needle image
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    for (UIView *view in navigationNodeControls) {
        view.center = center;
        [self insertSubview:view belowSubview:self.patientPhotoView];
    }
    // save current controls
    _previousNavigationNodeControls = [_navigationNodeControls copy];
    // update navigationNodeControls ivar
    [self willChangeValueForKey:@"navigationNodeControls"];
    _navigationNodeControls = navigationNodeControls;
    [self didChangeValueForKey:@"navigationNodeControls"];
    self.navigationNodeControlsActiveFlag = NO;
    // hide the new controls until animated in
    [_navigationNodeControls makeObjectsPerformSelector:@selector(setAlpha:) withObject:[NSNumber numberWithFloat:0.0]];
}

- (void)recenterNavigationControls
{
    self.navigationNodeControlsActiveFlag = NO;
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    for (UIView *view in self.navigationNodeControls) {
        view.center = center;
    }
    // recalculate
    [self recalculateDimensions];
}

- (void)animateNodesIntoActivePosition
{
    if (self.navigationNodeControlsActiveFlag) {
        return;
    }
    // else animate into active positions
    self.navigationNodeControlsActiveFlag = YES;
    CGFloat minViewX = self.compassPanelMinX;
    CGFloat maxViewX = self.compassPanelMaxX;
    CGFloat minViewY = CGRectGetMinY(self.bounds);
    CGFloat maxViewY = CGRectGetMaxY(self.bounds);
    CGFloat compassWidth = CGRectGetWidth(self.compassImageViewFrame);
    CGFloat compassHeight = CGRectGetHeight(self.compassImageViewFrame);
    CGFloat deltaY = (compassWidth - compassHeight)/2.0;
    CGFloat minX = CGRectGetMinX(self.compassImageViewFrame);
    CGFloat midX = CGRectGetMidX(self.compassImageViewFrame);
    CGFloat maxX = CGRectGetMaxX(self.compassImageViewFrame);
    CGFloat minY = CGRectGetMinY(self.compassImageViewFrame) - deltaY;
    CGFloat midY = CGRectGetMidY(self.compassImageViewFrame);
    CGFloat maxY = CGRectGetMaxY(self.compassImageViewFrame) + deltaY;
    // calculate the desired radius to plant the node buttons
    CGFloat radiusW = CGRectGetWidth(self.bounds);
    CGFloat radiusH = CGRectGetHeight(self.bounds);
    MapBaseRotationDirection direction = MapBaseRotationDirection_West;
    for (UIView *view in self.navigationNodeControls) {
        CGFloat width = CGRectGetWidth(view.frame);
        CGFloat height = CGRectGetHeight(view.frame);
        CGFloat r = 0.0;
        switch (direction) {
            case MapBaseRotationDirection_West: {
                r = roundf((minX - minViewX - width)/2.0 + width/2.0);
                radiusW = fminf(radiusW, r);
                break;
            }
            case MapBaseRotationDirection_North: {
                r = roundf((minY - minViewY - height)/2.0 + height/2.0);
                radiusH = fminf(radiusH, r);
                break;
            }
            case MapBaseRotationDirection_East: {
                r = roundf((maxViewX - maxX - width)/2.0 + width/2.0);
                radiusW = fminf(radiusW, r);
                break;
            }
            case MapBaseRotationDirection_South: {
                r = roundf((maxViewY - maxY - height)/2.0 + height/2.0);
                radiusH = fminf(radiusH, r);
                break;
            }
        }
        ++direction;
    }
    __weak __typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:1.0 animations:^{
        MapBaseRotationDirection direction = MapBaseRotationDirection_West;
        for (UIView *view in weakSelf.navigationNodeControls) {
            CGPoint center = CGPointZero;
            switch (direction) {
                case MapBaseRotationDirection_West: {
                    center = CGPointMake(minX - radiusW, midY);
                    break;
                }
                case MapBaseRotationDirection_North: {
                    center = CGPointMake(midX, minY - radiusH);
                    break;
                }
                case MapBaseRotationDirection_East: {
                    center = CGPointMake(maxX + radiusW, midY);
                    break;
                }
                case MapBaseRotationDirection_South: {
                    center = CGPointMake(midX, maxY + radiusH);
                    break;
                }
            }
            view.center = center;
            view.alpha = 1.0;
            view.hidden = NO;
            ++direction;
        }
        // dim the current controls
        [_previousNavigationNodeControls makeObjectsPerformSelector:@selector(setAlpha:) withObject:[NSNumber numberWithFloat:0.0]];
    } completion:^(BOOL finished) {
        // remove older controls from view
        [_previousNavigationNodeControls makeObjectsPerformSelector:@selector(removeFromSuperview)];
        _previousNavigationNodeControls = nil;
        // update button status
        [weakSelf.policyManager updateRegisteredButtonsInArray:weakSelf.navigationNodeControls];
    }];
}

- (void)setActionState:(CompassViewActionState)actionState
{
    if (_actionState == actionState) {
        return;
    }
    // else
    [self willChangeValueForKey:@"actionState"];
    _actionState = actionState;
    [self didChangeValueForKey:@"actionState"];
    self.patientPhotoView.actionState = actionState;
    if (actionState > CompassViewActionStateHome) {
        [_patientImageView performSelector:@selector(flashReturnToPreviousLevelView) withObject:nil afterDelay:1.0];
    }
}

#pragma mark - Actions

- (IBAction)rotateToWestAction:(id)sender
{
    __weak __typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:1.0 animations:^{
        weakSelf.compassNeedleImage.transform = CompassTransformWest;
    } completion:^(BOOL finished) {
        weakSelf.rotationState = MapBaseRotationDirection_West;
        [self setNeedsDisplay];
    }];
}

- (IBAction)rotateToNorthAction:(id)sender
{
    __weak __typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:1.0 animations:^{
        weakSelf.compassNeedleImage.transform = CompassTransformNorth;
    } completion:^(BOOL finished) {
        weakSelf.rotationState = MapBaseRotationDirection_North;
        [weakSelf setNeedsDisplay];
    }];
}

- (IBAction)rotateToEastAction:(id)sender
{
    __weak __typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:1.0 animations:^{
        weakSelf.compassNeedleImage.transform = CompassTransformEast;
    } completion:^(BOOL finished) {
        weakSelf.rotationState = MapBaseRotationDirection_East;
        [weakSelf setNeedsDisplay];
    }];
}

- (IBAction)rotateToSouthAction:(id)sender
{
    __weak __typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:1.0 animations:^{
        weakSelf.compassNeedleImage.transform = CompassTransformSouth;
    } completion:^(BOOL finished) {
        weakSelf.rotationState = MapBaseRotationDirection_South;
        [weakSelf setNeedsDisplay];
    }];
}

#pragma mark - Geometry

- (CGFloat)compassPanelMinX
{
    return CGRectGetMinX(self.bounds);
}

- (CGFloat)compassPanelMaxX
{
    return CGRectGetMaxX(self.bounds);
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _compassNeedleImage.center = center;
    _patientPhotoView.center = center;
    _patientImageView.center = center;
    [self recalculateDimensions];
}

#pragma mark - Drawing

- (UIColor *)backgroundColor
{
    return UIColorFromRGB(0xFAFDFF);
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    // clear background
    CGContextSetFillColorWithColor(context, [self.backgroundColor CGColor]);
    CGContextFillRect(context, rect);
    // add clip
    CGFloat midX = CGRectGetMidX(rect);
    CGFloat midY = CGRectGetMidY(rect);
    CGContextSaveGState(context);
    CGContextAddRect(context, rect);
    CGContextAddEllipseInRect(context, self.clippingRect);
    CGContextEOClip(context);
    // draw all lines for quadrants
    CGContextSetLineWidth(context, 0.5);
    CGContextSetStrokeColorWithColor(context, [UIColorFromRGB(0xd1d4da) CGColor]);
    CGFloat minX = self.compassPanelMinX;
    CGFloat minY = CGRectGetMinY(rect);
    CGFloat maxX = self.compassPanelMaxX;
    CGFloat maxY = CGRectGetMaxY(rect);
    CGPoint corner0 = CGPointZero;
    for (int i = MapBaseRotationDirection_West; i <= MapBaseRotationDirection_South; ++i) {
        // draw shading for selected quadrant
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, midX, midY);
        switch (i) {
            case MapBaseRotationDirection_West: {
                corner0 = CGPointMake(minX, maxY);
                break;
            }
            case MapBaseRotationDirection_North: {
                corner0 = CGPointMake(minX, minY);
                break;
            }
            case MapBaseRotationDirection_East: {
                corner0 = CGPointMake(maxX, minY);
                break;
            }
            case MapBaseRotationDirection_South: {
                corner0 = CGPointMake(maxX, maxY);
                break;
            }
        }
        CGContextAddLineToPoint(context, corner0.x, corner0.y);
        CGContextStrokePath(context);
    }
    CGContextRestoreGState(context);
}

@end
