// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundType.m instead.

#import "_WMWoundType.h"

const struct WMWoundTypeAttributes WMWoundTypeAttributes = {
	.createddate = @"createddate",
	.definition = @"definition",
	.flags = @"flags",
	.label = @"label",
	.lastmoddate = @"lastmoddate",
	.loincCode = @"loincCode",
	.options = @"options",
	.placeHolder = @"placeHolder",
	.sectionTitle = @"sectionTitle",
	.snomedCID = @"snomedCID",
	.snomedFSN = @"snomedFSN",
	.sortRank = @"sortRank",
	.title = @"title",
	.valueTypeCode = @"valueTypeCode",
	.wmwoundtype_id = @"wmwoundtype_id",
	.woundTypeCode = @"woundTypeCode",
};

const struct WMWoundTypeRelationships WMWoundTypeRelationships = {
	.children = @"children",
	.parent = @"parent",
	.wounds = @"wounds",
};

const struct WMWoundTypeFetchedProperties WMWoundTypeFetchedProperties = {
};

@implementation WMWoundTypeID
@end

@implementation _WMWoundType

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMWoundType" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMWoundType";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMWoundType" inManagedObjectContext:moc_];
}

- (WMWoundTypeID*)objectID {
	return (WMWoundTypeID*)[super objectID];
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
	if ([key isEqualToString:@"woundTypeCodeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"woundTypeCode"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




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





@dynamic label;






@dynamic lastmoddate;






@dynamic loincCode;






@dynamic options;






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





@dynamic wmwoundtype_id;






@dynamic woundTypeCode;



- (int16_t)woundTypeCodeValue {
	NSNumber *result = [self woundTypeCode];
	return [result shortValue];
}

- (void)setWoundTypeCodeValue:(int16_t)value_ {
	[self setWoundTypeCode:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveWoundTypeCodeValue {
	NSNumber *result = [self primitiveWoundTypeCode];
	return [result shortValue];
}

- (void)setPrimitiveWoundTypeCodeValue:(int16_t)value_ {
	[self setPrimitiveWoundTypeCode:[NSNumber numberWithShort:value_]];
}





@dynamic children;

	
- (NSMutableSet*)childrenSet {
	[self willAccessValueForKey:@"children"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"children"];
  
	[self didAccessValueForKey:@"children"];
	return result;
}
	

@dynamic parent;

	

@dynamic wounds;

	
- (NSMutableSet*)woundsSet {
	[self willAccessValueForKey:@"wounds"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"wounds"];
  
	[self didAccessValueForKey:@"wounds"];
	return result;
}
	






@end
