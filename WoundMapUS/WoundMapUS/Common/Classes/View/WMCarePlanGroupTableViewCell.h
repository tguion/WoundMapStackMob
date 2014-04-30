//
//  WMCarePlanGroupTableViewCell.h
//  WoundPUMP
//
//  Created by Todd Guion on 6/15/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "APTableViewCell.h"

@class WMCarePlanGroup;

@interface WMCarePlanGroupTableViewCell : APTableViewCell

@property (strong, nonatomic) WMCarePlanGroup *carePlanGroup;

@end
