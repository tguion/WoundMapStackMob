// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundMeasurementValue.m instead.

#import "_WMWoundMeasurementValue.h"

const struct WMWoundMeasurementValueAttributes WMWoundMeasurementValueAttributes = {
	.createdAt = @"createdAt",
	.datePushed = @"datePushed",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.fromOClockValue = @"fromOClockValue",
	.revisedFlag = @"revisedFlag",
	.sectionTitle = @"sectionTitle",
	.sortRank = @"sortRank",
	.title = @"title",
	.toOClockValue = @"toOClockValue",
	.updatedAt = @"updatedAt",
	.value = @"value",
	.woundMeasurementValueType = @"woundMeasurementValueType",
};

const struct WMWoundMeasurementValueRelationships WMWoundMeasurementValueRelationships = {
	.amountQualifier = @"amountQualifier",
	.group = @"group",
	.odor = @"odor",
	.woundMeasurement = @"woundMeasurement",
};

const struct WMWoundMeasurementValueFetchedProperties WMWoundMeasurementValueFetchedProperties = {
};

@implementation WMWoundMeasurementValueID
@end

@implementation _WMWoundMeasurementValue

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMWoundMeasurementValue" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMWoundMeasurementValue";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMWoundMeasurementValue" inManagedObjectContext:moc_];
}

- (WMWoundMeasurementValueID*)objectID {
	return (WMWoundMeasurementValueID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"flagsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"flags"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"fromOClockValueValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"fromOClockValue"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"revisedFlagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"revisedFlag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"sortRankValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sortRank"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"toOClockValueValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"toOClockValue"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"woundMeasurementValueTypeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"woundMeasurementValueType"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic createdAt;






@dynamic datePushed;






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





@dynamic fromOClockValue;



- (int16_t)fromOClockValueValue {
	NSNumber *result = [self fromOClockValue];
	return [result shortValue];
}

- (void)setFromOClockValueValue:(int16_t)value_ {
	[self setFromOClockValue:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveFromOClockValueValue {
	NSNumber *result = [self primitiveFromOClockValue];
	return [result shortValue];
}

- (void)setPrimitiveFromOClockValueValue:(int16_t)value_ {
	[self setPrimitiveFromOClockValue:[NSNumber numberWithShort:value_]];
}





@dynamic revisedFlag;



- (BOOL)revisedFlagValue {
	NSNumber *result = [self revisedFlag];
	return [result boolValue];
}

- (void)setRevisedFlagValue:(BOOL)value_ {
	[self setRevisedFlag:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveRevisedFlagValue {
	NSNumber *result = [self primitiveRevisedFlag];
	return [result boolValue];
}

- (void)setPrimitiveRevisedFlagValue:(BOOL)value_ {
	[self setPrimitiveRevisedFlag:[NSNumber numberWithBool:value_]];
}





@dynamic sectionTitle;






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






@dynamic toOClockValue;



- (int16_t)toOClockValueValue {
	NSNumber *result = [self toOClockValue];
	return [result shortValue];
}

- (void)setToOClockValueValue:(int16_t)value_ {
	[self setToOClockValue:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveToOClockValueValue {
	NSNumber *result = [self primitiveToOClockValue];
	return [result shortValue];
}

- (void)setPrimitiveToOClockValueValue:(int16_t)value_ {
	[self setPrimitiveToOClockValue:[NSNumber numberWithShort:value_]];
}





@dynamic updatedAt;






@dynamic value;






@dynamic woundMeasurementValueType;



- (int16_t)woundMeasurementValueTypeValue {
	NSNumber *result = [self woundMeasurementValueType];
	return [result shortValue];
}

- (void)setWoundMeasurementValueTypeValue:(int16_t)value_ {
	[self setWoundMeasurementValueType:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveWoundMeasurementValueTypeValue {
	NSNumber *result = [self primitiveWoundMeasurementValueType];
	return [result shortValue];
}

- (void)setPrimitiveWoundMeasurementValueTypeValue:(int16_t)value_ {
	[self setPrimitiveWoundMeasurementValueType:[NSNumber numberWithShort:value_]];
}





@dynamic amountQualifier;

	

@dynamic group;

	

@dynamic odor;

	

@dynamic woundMeasurement;

	






@end
