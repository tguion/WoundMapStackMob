// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundMeasurement.m instead.

#import "_WMWoundMeasurement.h"

const struct WMWoundMeasurementAttributes WMWoundMeasurementAttributes = {
	.createdAt = @"createdAt",
	.definition = @"definition",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.graphableFlag = @"graphableFlag",
	.iapIdentifier = @"iapIdentifier",
	.keyboardType = @"keyboardType",
	.label = @"label",
	.loincCode = @"loincCode",
	.placeHolder = @"placeHolder",
	.sectionTitle = @"sectionTitle",
	.snomedCID = @"snomedCID",
	.snomedFSN = @"snomedFSN",
	.sortRank = @"sortRank",
	.title = @"title",
	.unit = @"unit",
	.updatedAt = @"updatedAt",
	.valueMaximum = @"valueMaximum",
	.valueMinimum = @"valueMinimum",
	.valueTypeCode = @"valueTypeCode",
};

const struct WMWoundMeasurementRelationships WMWoundMeasurementRelationships = {
	.childrenMeasurements = @"childrenMeasurements",
	.parentMeasurement = @"parentMeasurement",
	.values = @"values",
	.woundTypes = @"woundTypes",
};

const struct WMWoundMeasurementFetchedProperties WMWoundMeasurementFetchedProperties = {
};

@implementation WMWoundMeasurementID
@end

@implementation _WMWoundMeasurement

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMWoundMeasurement" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMWoundMeasurement";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMWoundMeasurement" inManagedObjectContext:moc_];
}

- (WMWoundMeasurementID*)objectID {
	return (WMWoundMeasurementID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"flagsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"flags"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"graphableFlagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"graphableFlag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"keyboardTypeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"keyboardType"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"snomedCIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"snomedCID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"sortRankValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sortRank"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"valueMaximumValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"valueMaximum"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"valueMinimumValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"valueMinimum"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"valueTypeCodeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"valueTypeCode"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic createdAt;






@dynamic definition;






@dynamic ffUrl;






@dynamic flags;



- (int32_t)flagsValue {
	NSNumber *result = [self flags];
	return [result intValue];
}

- (void)setFlagsValue:(int32_t)value_ {
	[self setFlags:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveFlagsValue {
	NSNumber *result = [self primitiveFlags];
	return [result intValue];
}

- (void)setPrimitiveFlagsValue:(int32_t)value_ {
	[self setPrimitiveFlags:[NSNumber numberWithInt:value_]];
}





@dynamic graphableFlag;



- (BOOL)graphableFlagValue {
	NSNumber *result = [self graphableFlag];
	return [result boolValue];
}

- (void)setGraphableFlagValue:(BOOL)value_ {
	[self setGraphableFlag:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveGraphableFlagValue {
	NSNumber *result = [self primitiveGraphableFlag];
	return [result boolValue];
}

- (void)setPrimitiveGraphableFlagValue:(BOOL)value_ {
	[self setPrimitiveGraphableFlag:[NSNumber numberWithBool:value_]];
}





@dynamic iapIdentifier;






@dynamic keyboardType;



- (int16_t)keyboardTypeValue {
	NSNumber *result = [self keyboardType];
	return [result shortValue];
}

- (void)setKeyboardTypeValue:(int16_t)value_ {
	[self setKeyboardType:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveKeyboardTypeValue {
	NSNumber *result = [self primitiveKeyboardType];
	return [result shortValue];
}

- (void)setPrimitiveKeyboardTypeValue:(int16_t)value_ {
	[self setPrimitiveKeyboardType:[NSNumber numberWithShort:value_]];
}





@dynamic label;






@dynamic loincCode;






@dynamic placeHolder;






@dynamic sectionTitle;






@dynamic snomedCID;



- (int64_t)snomedCIDValue {
	NSNumber *result = [self snomedCID];
	return [result longLongValue];
}

- (void)setSnomedCIDValue:(int64_t)value_ {
	[self setSnomedCID:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveSnomedCIDValue {
	NSNumber *result = [self primitiveSnomedCID];
	return [result longLongValue];
}

- (void)setPrimitiveSnomedCIDValue:(int64_t)value_ {
	[self setPrimitiveSnomedCID:[NSNumber numberWithLongLong:value_]];
}





@dynamic snomedFSN;






@dynamic sortRank;



- (int16_t)sortRankValue {
	NSNumber *result = [self sortRank];
	return [result shortValue];
}

- (void)setSortRankValue:(int16_t)value_ {
	[self setSortRank:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveSortRankValue {
	NSNumber *result = [self primitiveSortRank];
	return [result shortValue];
}

- (void)setPrimitiveSortRankValue:(int16_t)value_ {
	[self setPrimitiveSortRank:[NSNumber numberWithShort:value_]];
}





@dynamic title;






@dynamic unit;






@dynamic updatedAt;






@dynamic valueMaximum;



- (float)valueMaximumValue {
	NSNumber *result = [self valueMaximum];
	return [result floatValue];
}

- (void)setValueMaximumValue:(float)value_ {
	[self setValueMaximum:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveValueMaximumValue {
	NSNumber *result = [self primitiveValueMaximum];
	return [result floatValue];
}

- (void)setPrimitiveValueMaximumValue:(float)value_ {
	[self setPrimitiveValueMaximum:[NSNumber numberWithFloat:value_]];
}





@dynamic valueMinimum;



- (float)valueMinimumValue {
	NSNumber *result = [self valueMinimum];
	return [result floatValue];
}

- (void)setValueMinimumValue:(float)value_ {
	[self setValueMinimum:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveValueMinimumValue {
	NSNumber *result = [self primitiveValueMinimum];
	return [result floatValue];
}

- (void)setPrimitiveValueMinimumValue:(float)value_ {
	[self setPrimitiveValueMinimum:[NSNumber numberWithFloat:value_]];
}





@dynamic valueTypeCode;



- (int16_t)valueTypeCodeValue {
	NSNumber *result = [self valueTypeCode];
	return [result shortValue];
}

- (void)setValueTypeCodeValue:(int16_t)value_ {
	[self setValueTypeCode:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveValueTypeCodeValue {
	NSNumber *result = [self primitiveValueTypeCode];
	return [result shortValue];
}

- (void)setPrimitiveValueTypeCodeValue:(int16_t)value_ {
	[self setPrimitiveValueTypeCode:[NSNumber numberWithShort:value_]];
}





@dynamic childrenMeasurements;

	
- (NSMutableSet*)childrenMeasurementsSet {
	[self willAccessValueForKey:@"childrenMeasurements"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"childrenMeasurements"];
  
	[self didAccessValueForKey:@"childrenMeasurements"];
	return result;
}
	

@dynamic parentMeasurement;

	

@dynamic values;

	
- (NSMutableSet*)valuesSet {
	[self willAccessValueForKey:@"values"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"values"];
  
	[self didAccessValueForKey:@"values"];
	return result;
}
	

@dynamic woundTypes;

	
- (NSMutableSet*)woundTypesSet {
	[self willAccessValueForKey:@"woundTypes"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"woundTypes"];
  
	[self didAccessValueForKey:@"woundTypes"];
	return result;
}
	






@end
