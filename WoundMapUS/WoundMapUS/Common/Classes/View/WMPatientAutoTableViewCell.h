//
//  WMPatientAutoTableViewCell.h
//  WoundMapUS
//
//  Created by Todd Guion on 5/8/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WMPatientAutoTableViewCell;
@class WMPatient, WMPatientConsultant, WMPatientReferral;

typedef void (^WMPatientReferralCallback)(WMPatientAutoTableViewCell *cell);
typedef void (^WMPatientUnarchiveCallback)(WMPatientAutoTableViewCell *cell);

@interface WMPatientAutoTableViewCell : UITableViewCell

- (void)updateForPatient:(WMPatient *)patient
         patientReferral:(WMPatientReferral *)patientReferral
        referralCallback:(WMPatientReferralCallback)referralCallback
       unarchiveCallback:(WMPatientUnarchiveCallback)unarchiveCallback;

- (void)updateForPatientConsultant:(WMPatientConsultant *)patientConsultant;


@end
