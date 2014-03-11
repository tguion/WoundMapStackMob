// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundLocation.m instead.

#import "_WMWoundLocation.h"

const struct WMWoundLocationAttributes WMWoundLocationAttributes = {
	.createdAt = @"createdAt",
	.definition = @"definition",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.loincCode = @"loincCode",
	.placeHolder = @"placeHolder",
	.sectionTitle = @"sectionTitle",
	.snomedCID = @"snomedCID",
	.snomedFSN = @"snomedFSN",
	.sortRank = @"sortRank",
	.title = @"title",
	.updatedAt = @"updatedAt",
	.valueTypeCode = @"valueTypeCode",
};

const struct WMWoundLocationRelationships WMWoundLocationRelationships = {
	.positionJoins = @"positionJoins",
	.values = @"values",
};

const struct WMWoundLocationFetchedProperties WMWoundLocationFetchedProperties = {
};

@implementation WMWoundLocationID
@end

@implementation _WMWoundLocation

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMWoundLocation" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMWoundLocation";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMWoundLocation" inManagedObjectContext:moc_];
}

- (WMWoundLocationID*)objectID {
	return (WMWoundLocationID*)[super objectID];
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






@dynamic updatedAt;






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





@dynamic positionJoins;

	
- (NSMutableSet*)positionJoinsSet {
	[self willAccessValueForKey:@"positionJoins"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"positionJoins"];
  
	[self didAccessValueForKey:@"positionJoins"];
	return result;
}
	

@dynamic values;

	
- (NSMutableSet*)valuesSet {
	[self willAccessValueForKey:@"values"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"values"];
  
	[self didAccessValueForKey:@"values"];
	return result;
}
	






@end
