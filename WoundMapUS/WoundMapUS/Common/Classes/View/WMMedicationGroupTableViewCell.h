//
//  WMMedicationGroupTableViewCell.h
//  WoundPUMP
//
//  Created by Todd Guion on 6/11/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "APTableViewCell.h"

@class WMMedicationGroup;

@interface WMMedicationGroupTableViewCell : APTableViewCell

@property (strong, nonatomic) WMMedicationGroup *medicationGroup;

@end
