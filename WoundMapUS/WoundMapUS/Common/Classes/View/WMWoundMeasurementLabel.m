//
//  WMWoundMeasurementLabel.m
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 9/27/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import "WMWoundMeasurementLabel.h"
#import "WMDesignUtilities.h"
#import <QuartzCore/QuartzCore.h>

@interface WMWoundMeasurementLabel (PrivateMethods)
- (void)initialize;
@end

@implementation WMWoundMeasurementLabel (PrivateMethods)

- (void)initialize
{
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = 4.0;
    self.layer.backgroundColor = [WMDesignUtilities semiTransparentMeasurementLabelBackgroundColor].CGColor;
    self.textAlignment = NSTextAlignmentCenter;
    self.textColor = [UIColor whiteColor];
    self.font = [UIFont systemFontOfSize:13.0];
}


@end

@implementation WMWoundMeasurementLabel

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initialize];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

@end
