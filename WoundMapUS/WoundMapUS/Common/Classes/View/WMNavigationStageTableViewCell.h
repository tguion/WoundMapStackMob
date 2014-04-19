//
//  WMNavigationStageTableViewCell.h
//  WoundPUMP
//
//  Created by Todd Guion on 7/13/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "APTableViewCell.h"

@class WMNavigationStage;

@interface WMNavigationStageTableViewCell : APTableViewCell

@property (strong, nonatomic) WMNavigationStage *navigationStage;

+ (CGFloat)heightTheFitsForStage:(WMNavigationStage *)navigationStage width:(CGFloat)width;

@end
