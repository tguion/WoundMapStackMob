// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundPosition.m instead.

#import "_WMWoundPosition.h"

const struct WMWoundPositionAttributes WMWoundPositionAttributes = {
	.commonTitle = @"commonTitle",
	.createddate = @"createddate",
	.definition = @"definition",
	.flags = @"flags",
	.lastmoddate = @"lastmoddate",
	.loincCode = @"loincCode",
	.prompt = @"prompt",
	.snomedCID = @"snomedCID",
	.snomedFSN = @"snomedFSN",
	.sortRank = @"sortRank",
	.title = @"title",
	.valueTypeCode = @"valueTypeCode",
	.wmwoundposition_id = @"wmwoundposition_id",
};

const struct WMWoundPositionRelationships WMWoundPositionRelationships = {
	.locationJoins = @"locationJoins",
	.positionValues = @"positionValues",
};

const struct WMWoundPositionFetchedProperties WMWoundPositionFetchedProperties = {
};

@implementation WMWoundPositionID
@end

@implementation _WMWoundPosition

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMWoundPosition" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMWoundPosition";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMWoundPosition" inManagedObjectContext:moc_];
}

- (WMWoundPositionID*)objectID {
	return (WMWoundPositionID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"flagsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"flags"];
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
	if ([key isEqualToString:@"valueTypeCodeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"valueTypeCode"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic commonTitle;






@dynamic createddate;






@dynamic definition;






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





@dynamic lastmoddate;






@dynamic loincCode;






@dynamic prompt;






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





@dynamic wmwoundposition_id;






@dynamic locationJoins;

	
- (NSMutableSet*)locationJoinsSet {
	[self willAccessValueForKey:@"locationJoins"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"locationJoins"];
  
	[self didAccessValueForKey:@"locationJoins"];
	return result;
}
	

@dynamic positionValues;

	
- (NSMutableSet*)positionValuesSet {
	[self willAccessValueForKey:@"positionValues"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"positionValues"];
  
	[self didAccessValueForKey:@"positionValues"];
	return result;
}
	






@end
