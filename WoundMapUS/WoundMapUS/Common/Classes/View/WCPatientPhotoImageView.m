//
//  WCPatientPhotoImageView.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/12/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WCPatientPhotoImageView.h"
#import "WMPatient.h"
#import "StackMob.h"

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
    NSString *picString = patient.thumbnail;
    if ([SMBinaryDataConversion stringContainsURL:picString]) {
        self.imageURL = [NSURL URLWithString:picString relativeToURL:nil];
    } else {
        UIImage *image = nil;
        if (nil == picString) {
            image = [WMPatient missingThumbnailImage];
        } else {
            image = [UIImage imageWithData:[SMBinaryDataConversion dataForString:picString]];
        }
        self.image = image;
    }
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
