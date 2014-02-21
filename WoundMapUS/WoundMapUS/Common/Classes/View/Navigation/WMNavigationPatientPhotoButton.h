//
//  WMNavigationPatientPhotoButton.h
//  WoundPUMP
//
//  Created by Todd Guion on 9/1/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMCompassView.h"

@interface WMNavigationPatientPhotoButton : UIButton

@property (assign, nonatomic) CompassViewActionState actionState;
@property (strong, nonatomic) NSString *navigationNodeTitle;
@property (strong, nonatomic) NSString *navigationNodeIconName;

- (void)updateForPatient:(WMPatient *)patient;
- (CGRect)navigationImageFrameForImageName:(NSString *)imageName title:(NSString *)title inView:(UIView *)view;

@end
