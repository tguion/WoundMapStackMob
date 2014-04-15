//
//  DictionaryToDataTransformer.m
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 1/14/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//

#import "DictionaryToDataTransformer.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"

@implementation DictionaryToDataTransformer

+ (BOOL)allowsReverseTransformation {
	return YES;
}

+ (Class)transformedValueClass {
	return [NSData class];
}


- (id)transformedValue:(id)value {
    NSString *errorString = nil;
	id data = [NSPropertyListSerialization dataFromPropertyList:value
                                                         format:NSPropertyListBinaryFormat_v1_0
                                               errorDescription:&errorString];
    if (nil != errorString) {
        DLog(@"Error saving propertyList: %@", errorString);
    }
    return data;
}


- (id)reverseTransformedValue:(id)value {
    NSError *error = nil;
	id propertyList = [NSPropertyListSerialization propertyListWithData:value
                                                     options:NSPropertyListImmutable
                                                      format:NULL
                                                       error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    return propertyList;
}

@end
