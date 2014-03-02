//
//  SearchUtilities.m
//  HenryScheinSales
//
//  Created by Todd Guion on 6/26/10.
//  Copyright 2010 etreasure consulting inc. All rights reserved.
//
//	Some code taken from "DerivedProperty" sample project

#import "SearchUtilities.h"

@implementation SearchUtilities

static NSPredicate *normalizedTitlePredicateTemplate;

+ (void)initialize {
    // pre-parse predicate for quick substitution in reverseTransformedValue:
    // instead of using a 'contains' operator, we simplify the predicate using a check between a high and low bound
    // this allows us to potentially use indexes
    normalizedTitlePredicateTemplate = [NSPredicate predicateWithFormat:@"normalizedTitle >= $lowBound and normalizedTitle < $highBound"];
}

+ (NSString *)normalizeString:(NSString *)unprocessedValue {
    if ([unprocessedValue length] == 0)
		return nil;
    // else
    NSMutableString *result = [NSMutableString stringWithString:unprocessedValue];
    CFStringNormalize((__bridge CFMutableStringRef)result, kCFStringNormalizationFormD);
    CFStringFold((__bridge CFMutableStringRef)result, kCFCompareCaseInsensitive | kCFCompareDiacriticInsensitive | kCFCompareWidthInsensitive, NULL);
    return result;
}

// calculates the next lexically ordered string guaranteed to be greater than text
+ (NSString *)upperBoundSearchString:(NSString*)text {
    NSUInteger length = [text length];
    NSString *baseString = nil;
    NSString *incrementedString = nil;
    
    if (length < 1) {
        return text;
    } else if (length > 1) {
        baseString = [text substringToIndex:(length-1)];
    } else {
        baseString = @"";
    }
    UniChar lastChar = [text characterAtIndex:(length-1)];
    UniChar incrementedChar;
    
    // We can't do a simple lastChar + 1 operation here without taking into account
    // unicode surrogate characters (http://unicode.org/faq/utf_bom.html#34)
    
    if ((lastChar >= 0xD800UL) && (lastChar <= 0xDBFFUL)) {         // surrogate high character
        incrementedChar = (0xDBFFUL + 1);
    } else if ((lastChar >= 0xDC00UL) && (lastChar <= 0xDFFFUL)) {  // surrogate low character
        incrementedChar = (0xDFFFUL + 1);
    } else if (lastChar == 0xFFFFUL) {
        if (length > 1 ) baseString = text;
        incrementedChar =  0x1;
    } else {
        incrementedChar = lastChar + 1;
    }
    
    incrementedString = [[NSString alloc] initWithFormat:@"%@%C", baseString, incrementedChar];
    
    return incrementedString;
}

+ (NSPredicate *)normalizedPredicate:(NSString *)searchString {
    NSString *lowBound = [self normalizeString:searchString];
    NSString *highBound = [self upperBoundSearchString:lowBound];
    NSMutableDictionary *bindVariables = [[NSMutableDictionary alloc] init];
	[bindVariables setObject:lowBound forKey:@"lowBound"];
	[bindVariables setObject:highBound forKey:@"highBound"];
    NSPredicate *result = [normalizedTitlePredicateTemplate predicateWithSubstitutionVariables:bindVariables];
    return result;
}


@end
