//
//  WMCarePlanGroup+CoreText.h
//  WoundMAP
//
//  Created by Todd Guion on 12/21/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMCarePlanGroup.h"
#import "WoundCareProtocols.h"

@class WMCarePlanCategory;

@interface WMCarePlanGroup (CoreText) <WCCoreTextDataSource>

- (void)appendToMutableAttributedString:(NSMutableAttributedString *)mutableAttributedString
              forParentCarePlanCategory:(WMCarePlanCategory *)parentCarePlanCategory
                            indentLevel:(NSUInteger)indentLevel
                       withBaseFontSize:(CGFloat)currentFontSize;

@end
