//
//  WMNavigationTrackTableViewCell.h
//  WoundPUMP
//
//  Created by Todd Guion on 7/12/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "APTableViewCell.h"

@class WMNavigationTrack;

@interface WMNavigationTrackTableViewCell : APTableViewCell

@property (strong, nonatomic) WMNavigationTrack *navigationTrack;

+ (CGFloat)heightTheFitsForTrack:(WMNavigationTrack *)navigationTrack width:(CGFloat)width;

@end
