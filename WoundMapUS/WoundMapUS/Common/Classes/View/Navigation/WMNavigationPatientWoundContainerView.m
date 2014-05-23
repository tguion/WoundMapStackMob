//
//  WMNavigationPatientWoundContainerView.m
//  WoundPUMP
//
//  Created by Todd Guion on 8/17/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMNavigationPatientWoundContainerView.h"
#import "WMNavigationPatientWoundView.h"
#import "WMNavigationNodeButton.h"
#import "WMPatient.h"
#import "WMWound.h"
#import "WMNavigationStage.h"
#import "CoreDataHelper.h"
#import "WMNavigationCoordinator.h"
#import "WCAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

typedef enum {
    ViewTranslationIdentity,
    ViewTranslationPatient,
} ViewTranslationState;

@interface WMNavigationPatientWoundContainerView ()

@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (readonly, nonatomic) WMPatient *patient;
@property (readonly, nonatomic) WMWound *wound;

@property (nonatomic) ViewTranslationState viewTranslationState;
@property (readonly, nonatomic) BOOL isTransitionStateIdentity;
@property (readonly, nonatomic) BOOL isTransitionStatePatient;
@property (nonatomic) CGPoint viewTranslationValue;
@property (nonatomic) CGAffineTransform showPatientTransform;

// views to manage Patient/Wound views "behind" view
@property (weak, nonatomic) IBOutlet WMNavigationPatientWoundView *nameContainerView;           // subview to draw patient & wound identifiers
@property (weak, nonatomic) IBOutlet UIView *patientContainerView;                              // subview to show patient nodes (edit, select, add)
@property (weak, nonatomic) IBOutlet UIButton *showPatientButton;
@property (readonly, nonatomic) CGFloat patientWoundContainerViewWidth;

- (IBAction)handleShowPatientWoundStageGesture:(UIPanGestureRecognizer *)gestureRecognizer;     // pan gesture to show Patient/Wound/Stage nodes
- (IBAction)handlePatientSwipeGesture:(UISwipeGestureRecognizer *)gestureRecognizer;            // dismiss the patient view
- (IBAction)patientAction:(id)sender;

@end

@interface WMNavigationPatientWoundContainerView (PrivateMethods)

- (void)translateNameViewToCurrentState;

@end

@implementation WMNavigationPatientWoundContainerView (PrivateMethods)

- (void)translateNameViewToCurrentState
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (self.viewTranslationState) {
        case ViewTranslationIdentity:
            // nothing more
            break;
        case ViewTranslationPatient:
            transform = self.showPatientTransform;
            self.patientContainerView.hidden = NO;
            break;
    }
    __weak __typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.nameContainerView.transform = transform;
    } completion:^(BOOL finished) {
        // nothing
    }];
}

@end

@implementation WMNavigationPatientWoundContainerView

@dynamic patientWoundContainerViewWidth;

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (WMPatient *)patient
{
    return self.appDelegate.navigationCoordinator.patient;
}

- (WMWound *)wound
{
    return self.appDelegate.navigationCoordinator.wound;
}

- (CGFloat)patientWoundContainerViewWidth
{
    return CGRectGetWidth(self.bounds) - CGRectGetWidth(self.showPatientButton.frame);
}

- (CGAffineTransform)showPatientTransform
{
    if (CGAffineTransformIsIdentity(_showPatientTransform)) {
        _showPatientTransform = CGAffineTransformMakeTranslation(self.patientWoundContainerViewWidth, 0.0);
    }
    return _showPatientTransform;
}

- (BOOL)isTransitionStateIdentity
{
    return self.viewTranslationState == ViewTranslationIdentity;
}

- (BOOL)isTransitionStatePatient
{
    return self.viewTranslationState == ViewTranslationPatient;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // shadow
    self.layer.shadowRadius = 5.0;
    self.layer.shadowOffset = CGSizeMake(3.0, 3.0);
    self.layer.shadowOpacity = 0.55;
    // state
    _showPatientTransform = CGAffineTransformIdentity;
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    self.nameContainerView.swipeEnabled = self.swipeEnabled;
    self.nameContainerView.deltaY = self.deltaY;
    [self updateContentForPatient];
}

- (void)resetState:(BOOL)animate
{
    self.viewTranslationState = ViewTranslationIdentity;
    if (animate) {
        [self translateNameViewToCurrentState];
    } else {
        self.nameContainerView.transform = CGAffineTransformIdentity;
    }
}

- (void)updatePatientAndWoundNodes
{
    if (nil == self.patient) {
        return;
    }
    // else Add/Edit/Select patient nodes
    self.patientAddNavigationNodeButton.rotationDirection = MapBaseRotationDirection_North;
    self.patientAddNavigationNodeButton.navigationNode = self.delegate.addPatientNavigationNode;
    self.patientSelectNavigationNodeButton.rotationDirection = MapBaseRotationDirection_North;
    self.patientSelectNavigationNodeButton.navigationNode = self.delegate.selectPatientNavigationNode;
    self.patientEditNavigationNodeButton.rotationDirection = MapBaseRotationDirection_North;
    self.patientEditNavigationNodeButton.navigationNode = self.delegate.editPatientNavigationNode;
    // Add/Edit/Select wound nodes
    self.woundAddNavigationNodeButton.rotationDirection = MapBaseRotationDirection_North;
    self.woundAddNavigationNodeButton.navigationNode = self.delegate.addWoundNavigationNode;
    self.woundSelectNavigationNodeButton.rotationDirection = MapBaseRotationDirection_North;
    self.woundSelectNavigationNodeButton.navigationNode = self.delegate.selectWoundNavigationNode;
    self.woundEditNavigationNodeButton.rotationDirection = MapBaseRotationDirection_North;
    self.woundEditNavigationNodeButton.navigationNode = self.delegate.editWoundNavigationNode;
}

// we need to adjust for
//  1. No patients - controller should not allow this to happen
//  2. Patients, but patient not selected
//  3. Patient selected, but only one patient
//  4. Patient selected, 2 or more patients
- (void)updateContentForPatient
{
    if (nil == self.patient) {
        return;
    }
    // else
    [self.nameContainerView updateContentForPatient];
    NSInteger patientCount = [WMPatient patientCount:[self.patient managedObjectContext]];
    WMPatient *patient = self.patient;
    if (0 == patientCount) {
        // controller should not let this happen, or hide self
        self.viewTranslationState = ViewTranslationIdentity;
        [self translateNameViewToCurrentState];
        self.patientSelectNavigationNodeButton.enabled = NO;
        self.patientEditNavigationNodeButton.enabled = NO;
    } else if (1 == patientCount) {
        // one patient, so can't select another
        self.patientSelectNavigationNodeButton.enabled = NO;
        self.patientEditNavigationNodeButton.enabled = (nil != patient);
    } else {
        // more than one patient
        self.patientSelectNavigationNodeButton.enabled = YES;
        self.patientEditNavigationNodeButton.enabled = (nil != patient);
    }
    NSInteger woundCount = [WMWound woundCountForPatient:patient];
    WMWound *wound = self.wound;
    if (0 == woundCount) {
        self.woundSelectNavigationNodeButton.enabled = NO;
        self.woundEditNavigationNodeButton.enabled = NO;
    } else if (1 == woundCount) {
        // one wound, so can't select another
        self.woundSelectNavigationNodeButton.enabled = NO;
        self.woundEditNavigationNodeButton.enabled = (nil != wound);
    } else {
        // more than one wound
        self.woundSelectNavigationNodeButton.enabled = YES;
        self.woundEditNavigationNodeButton.enabled = (nil != wound);
    }
}

- (void)setDrawTopLine:(BOOL)drawTopLine
{
    self.nameContainerView.drawTopLine = drawTopLine;
}

- (BOOL)swipeEnabled
{
    return [self.gestureRecognizers count] > 0;
}

#pragma mark - Actions

- (IBAction)handleShowPatientWoundStageGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint translation = [gestureRecognizer translationInView:self];
    translation.y = 0.0;
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            self.viewTranslationValue = CGPointZero;
            break;
        }
        case UIGestureRecognizerStateCancelled: {
            [self translateNameViewToCurrentState];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGFloat deltaX = translation.x;
            if (deltaX < 0.0 && self.isTransitionStateIdentity) {
                return;
            }
            // else
            CGFloat deltaY = translation.y;
            switch (self.viewTranslationState) {
                case ViewTranslationIdentity: {
                    // accept
                    break;
                }
                case ViewTranslationPatient: {
                    deltaY = 0.0;
                    break;
                }
            }
            self.viewTranslationValue = CGPointMake(self.viewTranslationValue.x + deltaX, self.viewTranslationValue.y + deltaY);
            self.nameContainerView.transform = CGAffineTransformTranslate(self.nameContainerView.transform, deltaX, deltaY);
            break;
        }
        case UIGestureRecognizerStateEnded: {
            // determine the intent of the user - patient, wound, or stage
            CGFloat deltaX = self.viewTranslationValue.x;
            CGFloat deltaY = self.viewTranslationValue.y;
            switch (self.viewTranslationState) {
                case ViewTranslationIdentity: {
                    if (fabsf(deltaX) > fabsf(deltaY)) {
                        // patient or wound gesture
                        if (deltaX > 0.0 && deltaX > self.patientWoundContainerViewWidth/4.0) {
                            // patient - commit to show patient
                            self.viewTranslationState = ViewTranslationPatient;
                        }
                    }
                    break;
                }
                case ViewTranslationPatient: {
                    if (deltaX < -self.patientWoundContainerViewWidth/4.0) {
                        // identity - commit to hide patient
                        self.viewTranslationState = ViewTranslationIdentity;
                    }
                    break;
                }
            }
            [self translateNameViewToCurrentState];
            break;
        }
        default: {
            break;
        }
    }
    [gestureRecognizer setTranslation:CGPointMake(0, 0) inView:self];
}

- (IBAction)handlePatientSwipeGesture:(UISwipeGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded && gestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        self.viewTranslationState = ViewTranslationIdentity;
        [self translateNameViewToCurrentState];
    }
}

- (IBAction)patientAction:(id)sender
{
    self.viewTranslationState = (self.isTransitionStateIdentity ? ViewTranslationPatient:ViewTranslationIdentity);
    [self translateNameViewToCurrentState];
}

@end
