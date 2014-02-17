//
//  WMPatientTableViewCell.h
//  WoundCarePhoto
//
//  Created by Todd Guion on 5/30/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import "APTableViewCell.h"

@class WMPatient;

@interface WMPatientTableViewCell : APTableViewCell

@property (strong, nonatomic) WMPatient *patient;

@end
