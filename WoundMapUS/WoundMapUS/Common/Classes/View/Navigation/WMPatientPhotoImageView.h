//
//  WMPatientPhotoImageView.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/12/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

@class WMPatient;

@interface WMPatientPhotoImageView : UIImageView

@property (strong, nonatomic) UIView *returnToPreviousLevelView;

- (void)updateForPatient:(WMPatient *)patient;
- (void)flashReturnToPreviousLevelView;

@end
