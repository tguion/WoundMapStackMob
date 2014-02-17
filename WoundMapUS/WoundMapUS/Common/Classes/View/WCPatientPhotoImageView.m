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

- (void)updateForPatient:(WMPatient *)patient
{
    NSString *picString = patient.thumbnail;
    if ([SMBinaryDataConversion stringContainsURL:picString]) {
        self.imageURL = [NSURL URLWithString:picString relativeToURL:nil];
    } else {
        UIImage *image = nil;
        if (nil == picString) {
            image = patient.missingThumbnailImage;
        } else {
            image = [UIImage imageWithData:[SMBinaryDataConversion dataForString:picString]];
        }
        self.image = image;
    }
}

@end
