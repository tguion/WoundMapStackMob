//
//  WMEventTableViewCell.h
//  WoundPUMP
//
//  Created by etreasure consulting LLC on 4/17/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "APTableViewCell.h"

@class WMInterventionEvent;

@interface WMEventTableViewCell : APTableViewCell

@property (strong, nonatomic) WMInterventionEvent *event;

@end
