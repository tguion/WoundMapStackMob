//
//  WMAddress+CoreText.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/20/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMAddress+CoreText.h"
#import "WCModelTextKitAtrributes.h"

@implementation WMAddress (CoreText)

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
