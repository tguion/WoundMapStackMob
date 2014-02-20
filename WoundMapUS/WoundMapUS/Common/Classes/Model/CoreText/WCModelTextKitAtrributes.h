//
//  WCModelTextKitAtrributes.h
//  WoundMAP
//
//  Created by Todd Guion on 12/21/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define Section_Indent_Value 8.0

@interface WCModelTextKitAtrributes : NSObject

+ (WCModelTextKitAtrributes *)sharedInstance;

- (NSAttributedString *)paragraphAttributedString;

- (NSMutableDictionary *)headingAttributesForFontSize:(CGFloat)fontSize;
- (NSMutableDictionary *)subheadingAttributesForFontSize:(CGFloat)fontSize;
- (NSMutableDictionary *)dateAttributesForFontSize:(CGFloat)fontSize;
- (NSMutableDictionary *)sectionHeadingAttributesForFontSize:(CGFloat)fontSize indentLevel:(NSUInteger)indentLevel;
- (NSMutableDictionary *)valueTitleAttributesForFontSize:(CGFloat)fontSize indentLevel:(NSUInteger)indentLevel;
- (NSMutableDictionary *)valueAttributesForFontSize:(CGFloat)fontSize indentLevel:(NSUInteger)indentLevel;

@end
