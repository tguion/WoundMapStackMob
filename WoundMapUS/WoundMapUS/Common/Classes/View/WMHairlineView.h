//
//  WMHairlineView.h
//  iTC Mobile
//
//  Created by Jeff Watkins on 12/3/13.
//  Copyright (c) 2013 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    WMHairlineAlignmentHorizontal,
    WMHairlineAlignmentVertical
} WMHairlineAlignment;

/// A simple view that is ALWAYS a hairline thickness, either in width or height. By default the background color is a medium grey.
@interface WMHairlineView : UIView

/// A convenience for accessing the thickness of the hairline view. On retina displays this will be 0.5. For legacy displays, this will be 1.0.
@property (nonatomic, readonly) CGFloat thickness;

+ (WMHairlineView *)hairlineViewForAlignment:(WMHairlineAlignment)alignment;

@end
