// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMDevice.m instead.

#import "_WMDevice.h"

const struct WMDeviceAttributes WMDeviceAttributes = {
	.createdAt = @"createdAt",
	.definition = @"definition",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.label = @"label",
	.loincCode = @"loincCode",
	.options = @"options",
	.placeHolder = @"placeHolder",
	.snomedCID = @"snomedCID",
	.snomedFSN = @"snomedFSN",
	.sortRank = @"sortRank",
	.title = @"title",
	.updatedAt = @"updatedAt",
	.valueTypeCode = @"valueTypeCode",
};

const struct WMDeviceRelationships WMDeviceRelationships = {
	.category = @"category",
	.values = @"values",
};

const struct WMDeviceFetchedProperties WMDeviceFetchedProperties = {
};

@implementation WMDeviceID
@end

@implementation _WMDevice

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMDevice" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMDevice";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMDevice" inManagedObjectContext:moc_];
}

- (WMDeviceID*)objectID {
	return (WMDeviceID*)[super objectID];
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





@dynamic label;






@dynamic loincCode;






@dynamic options;






@dynamic placeHolder;






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





@dynamic category;

	

@dynamic values;

	
- (NSMutableSet*)valuesSet {
	[self willAccessValueForKey:@"values"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"values"];
  
	[self didAccessValueForKey:@"values"];
	return result;
}
	






@end
