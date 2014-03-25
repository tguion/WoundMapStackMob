//
//  WMTelecom+CoreText.m
//  WoundMapUS
//
//  Created by Todd Guion on 3/16/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMTelecom+CoreText.h"
#import "WCModelTextKitAtrributes.h"

@implementation WMTelecom (CoreText)

#pragma mark - WCCoreTextDataSource

- (NSMutableAttributedString *)descriptionAsMutableAttributedStringWithBaseFontSize:(CGFloat)fontSize
{
    WCModelTextKitAtrributes *modelTextKitAtrributes = [WCModelTextKitAtrributes sharedInstance];
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
    NSString *string = self.stringValue;
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:[modelTextKitAtrributes valueTitleAttributesForFontSize:fontSize indentLevel:0]];
    [mutableAttributedString appendAttributedString:attributedString];
    return mutableAttributedString;
}

@end
