//
//  WMPatientAutoTableViewCell.h
//  WoundMapUS
//
//  Created by Todd Guion on 5/8/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WMPatient, WMPatientConsultant, WMPatientReferral;

@interface WMPatientAutoTableViewCell : UITableViewCell

- (void)updateForPatient:(WMPatient *)patient patientReferral:(WMPatientReferral *)patientReferral;
- (void)updateForPatientConsultant:(WMPatientConsultant *)patientConsultant;


@end
