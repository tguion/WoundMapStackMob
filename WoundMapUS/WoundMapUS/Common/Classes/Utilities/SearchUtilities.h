//
//  SearchUtilities.h
//  HenryScheinSales
//
//  Created by Todd Guion on 6/26/10.
//  Copyright 2010 etreasure consulting inc. All rights reserved.
//
//	Utility class to improve string searching where the default is typically
//	'regularText contains[dc] $value'

#import <Foundation/Foundation.h>

// define the controller modes
typedef enum _HSControllerMode {
	HSControllerModeNavigate = 1,		// navigate with cell selection
	HSControllerModeSelect,				// select with cell selection
} HSControllerMode;

typedef enum _HSSearchType {
	HSBeginsWithSearchType = 1,			// BEGINSWITH The left-hand expression begins with the right-hand expression.
	HSContainsSearchType,				// CONTAINS The left-hand expression contains the right-hand expression.
	HSEndsWithSearchType,				// ENDSWITH The left-hand expression ends with the right-hand expression.
	HSMatchesSearchType,				// MATCHES The left hand expression equals the right-hand expression: 
										//	? and * are allowed as wildcard characters, where ? matches 1 character and * matches 0 or more characters. 
										//	In Mac OS X v10.4, wildcard characters do not match newline characters.
} HSSearchType;

@interface SearchUtilities : NSObject {

}

// returns a normalized string
+ (NSString *)normalizeString:(NSString *)unprocessedValue;
+ (NSString *)upperBoundSearchString:(NSString*)text;
+ (NSPredicate *)normalizedPredicate:(NSString *)searchString;

@end
