//
//  WCPatientPhotoImageView.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/12/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "AsyncImageView.h"

@class WMPatient;

@interface WCPatientPhotoImageView : AsyncImageView

- (void)updateForPatient:(WMPatient *)patient;

@end
