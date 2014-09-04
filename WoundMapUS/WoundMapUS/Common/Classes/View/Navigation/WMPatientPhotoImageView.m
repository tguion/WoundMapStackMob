//
//  WMPatientPhotoImageView.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/12/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMPatientPhotoImageView.h"
#import "WMPatient.h"
#import "WMFatFractal.h"
#import "WMUtilities.h"

@implementation WMPatientPhotoImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (nil == self) {
        return nil;
    }
    // else
    [self installClippingPath];
    return self;
}

- (void)updateForPatient:(WMPatient *)patient
{
    if (nil == patient) {
        self.image = [WMPatient missingThumbnailImage];
    }
    UIImage *thumbnail = patient.thumbnail;
    if (nil == thumbnail) {
        // attempt to read from back end
        if (patient.facePhotoTaken) {
            NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
            UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            activityIndicatorView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
            [self addSubview:activityIndicatorView];
            [activityIndicatorView startAnimating];
            WMFatFractal *ff = [WMFatFractal sharedInstance];
            __weak __typeof(&*self)weakSelf = self;
            [ff loadBlobsForObj:patient onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                if (error) {
                    [WMUtilities logError:error];
                }
                [activityIndicatorView removeFromSuperview];
                // image will be NSData, must convert to image
                if ([patient.thumbnail isKindOfClass:[NSData class]]) {
                    NSData *data = patient.thumbnail;
                    patient.thumbnail = [UIImage imageWithData:data];
                    [managedObjectContext MR_saveToPersistentStoreAndWait];
                }
                weakSelf.image = patient.thumbnail;
                [weakSelf setNeedsDisplay];
            }];
        } else {
            thumbnail = [WMPatient missingThumbnailImage];
            self.image = thumbnail;
        }
    } else {
        self.image = thumbnail;
    }
}

- (void)flashReturnToPreviousLevelView
{
//    [self addSubview:_returnToPreviousLevelView];
//    [UIView animateWithDuration:4.0
//                     animations:^{
//                         _returnToPreviousLevelView.alpha = 0.0;
//                     } completion:^(BOOL finished) {
//                         [_returnToPreviousLevelView removeFromSuperview];
//                         _returnToPreviousLevelView.alpha = 1.0;
//                     }];
}


- (void)installClippingPath
{
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    CAShapeLayer *borderMaskLayer = [CAShapeLayer layer];
    [borderMaskLayer setFrame:self.bounds];
    borderMaskLayer.path = [clipPath CGPath];
    self.layer.mask = borderMaskLayer;
    [self.layer setMasksToBounds:YES];
}

@end
