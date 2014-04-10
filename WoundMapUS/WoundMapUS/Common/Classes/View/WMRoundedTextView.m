//
//  WMRoundedTextView.m
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 1/29/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//

#import "WMRoundedTextView.h"
#import <QuartzCore/QuartzCore.h>

@interface WMRoundedTextView (PrivateMethods)
- (void)initialize;
@end

@implementation WMRoundedTextView (PrivateMethods)

- (void)initialize
{
    self.layer.cornerRadius = 6.0;
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
}

@end

@implementation WMRoundedTextView

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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
