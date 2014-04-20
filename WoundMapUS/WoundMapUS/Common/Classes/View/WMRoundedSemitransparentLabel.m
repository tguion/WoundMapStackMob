//
//  WMRoundedSemitransparentLabel.m
//  WoundCare
//
//  Created by Todd Guion on 7/31/11.
//  Copyright 2011 etreasure consulting LLC. All rights reserved.
//

#import "WMRoundedSemitransparentLabel.h"
#import "WMDesignUtilities.h"
#import <QuartzCore/QuartzCore.h>

@implementation WMRoundedSemitransparentLabel

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.layer.cornerRadius = 6.0;
    self.layer.backgroundColor = [WMDesignUtilities semiTransparentDateLabelBackgroundColor].CGColor;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.layer.cornerRadius = 6.0;
        self.layer.backgroundColor = [WMDesignUtilities semiTransparentDateLabelBackgroundColor].CGColor;
    }
    return self;
}

@end
