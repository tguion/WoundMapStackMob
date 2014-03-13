//
//  WCPatientPhotoImageView.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/12/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WCPatientPhotoImageView.h"
#import "WMPatient.h"

@implementation WCPatientPhotoImageView

- (instancetype)init
{
    self = [super init];
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
        thumbnail = [WMPatient missingThumbnailImage];
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
