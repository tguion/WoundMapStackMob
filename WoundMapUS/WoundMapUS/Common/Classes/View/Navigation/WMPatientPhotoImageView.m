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
            UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [self addSubview:activityIndicatorView];
            activityIndicatorView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
            [activityIndicatorView startAnimating];
            WMFatFractal *ff = [WMFatFractal sharedInstance];
            __weak __typeof(&*self)weakSelf = self;
            [ff loadBlobsForObj:patient onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                [activityIndicatorView removeFromSuperview];
                // image will be NSData, must convert to image
                if ([patient.thumbnail isKindOfClass:[NSData class]]) {
                    NSData *data = patient.thumbnail;
                    patient.thumbnail = [UIImage imageWithData:data];
                }
                weakSelf.image = patient.thumbnail;
            }];
        } else {
            thumbnail = [WMPatient missingThumbnailImage];
        }
    }
    self.image = thumbnail;
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
