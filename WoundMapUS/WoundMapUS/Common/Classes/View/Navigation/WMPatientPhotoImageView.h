//
//  WMPatientPhotoImageView.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/12/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

@class WMPatient;

@interface WMPatientPhotoImageView : UIImageView

- (void)updateForPatient:(WMPatient *)patient;

@end
