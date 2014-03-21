//
//  WMDevicesGroupTableViewCell.h
//  WoundMAP
//
//  Created by Todd Guion on 12/15/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "APTableViewCell.h"

@class WMDeviceGroup;

@interface WMDevicesGroupTableViewCell : APTableViewCell

@property (strong, nonatomic) WMDeviceGroup *devicesGroup;

@end
