//
//  WMPsychoSocialGroup+CoreText.h
//  WoundMAP
//
//  Created by Todd Guion on 12/23/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMPsychoSocialGroup.h"
#import "WoundCareProtocols.h"

@class WCPsychoSocialItem;

@interface WMPsychoSocialGroup (CoreText) <WCCoreTextDataSource>

- (void)appendToMutableAttributedString:(NSMutableAttributedString *)mutableAttributedString
              forParentPsychoSocialItem:(WCPsychoSocialItem *)psychoSocialItem
                            indentLevel:(NSUInteger)indentLevel
                       withBaseFontSize:(CGFloat)currentFontSize;

@end
