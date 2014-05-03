//
//  WMPatientTableViewCell.h
//  WoundCarePhoto
//
//  Created by Todd Guion on 5/30/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import "APTableViewCell.h"

@class WMPatient, WMPatientConsultant, WMPatientReferral;

@protocol PatientTableViewCellDelegate <NSObject>

- (void)patientTableViewCellPatientReferralSelected:(WMPatientReferral *)patientReferral;

@end

@interface WMPatientTableViewCell : APTableViewCell

@property (weak, nonatomic) id<PatientTableViewCellDelegate> delegate;

@property (strong, nonatomic) WMPatient *patient;
@property (strong, nonatomic) WMPatientConsultant *patientConsultant;

@end
