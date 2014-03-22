//
//  WMBradenSectionHeaderView.h
//  WoundCare
//
//  Created by Todd Guion on 8/3/11.
//  Copyright 2011 etreasure consulting LLC. All rights reserved.
//

#import "WMBradenSection.h"

@interface WMBradenSectionHeaderView : UIView

+ (CGFloat)heightForBradenCell:(WMBradenSection *)bradenSection width:(CGFloat)width;

- (void)updateWithBradenSection:(WMBradenSection *)bradenSection;

@end
