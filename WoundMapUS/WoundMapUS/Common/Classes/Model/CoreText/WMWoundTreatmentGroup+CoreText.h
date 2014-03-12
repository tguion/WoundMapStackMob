//
//  WMWoundTreatmentGroup+CoreText.h
//  WoundMAP
//
//  Created by Todd Guion on 12/23/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMWoundTreatmentGroup.h"
#import "WoundCareProtocols.h"

@class WMWoundTreatment;

@interface WMWoundTreatmentGroup (CoreText) <WCCoreTextDataSource>

- (void)appendToMutableAttributedString:(NSMutableAttributedString *)mutableAttributedString
                forParentWoundTreatment:(WMWoundTreatment *)woundTreatment
                            indentLevel:(NSUInteger)indentLevel
                       withBaseFontSize:(CGFloat)currentFontSize;

@end
