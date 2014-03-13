//
//  ImageToDataTransformer.m
//  MedicationCompatibility
//
//  Created by Todd Guion on 6/16/11.
//  Copyright 2011 Apple Inc. consulting LLC. All rights reserved.
//

#import "ImageToDataTransformer.h"

@implementation ImageToDataTransformer

+ (BOOL)allowsReverseTransformation {
	return YES;
}

+ (Class)transformedValueClass {
	return [NSData class];
}


- (id)transformedValue:(id)value {
	return [NSKeyedArchiver archivedDataWithRootObject:value];
}


- (id)reverseTransformedValue:(id)value {
    if (nil == value) {
        return nil;
    }
    // else
	return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}

@end
