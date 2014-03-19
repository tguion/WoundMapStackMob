//
//  WMDisclosureImageView.h
//  WoundPUMP
//
//  Created by Todd Guion on 5/17/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface WMDisclosureImageView : UIImageView {
    CALayer *disclosureLayer;
}

@property (nonatomic) NSInteger selectionCount;     // set to NSNotFound to hide image
@property (nonatomic) BOOL openFlag;

@end
