// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMCarePlanItem.m instead.

#import "_WMCarePlanItem.h"

const struct WMCarePlanItemAttributes WMCarePlanItemAttributes = {
	.createddate = @"createddate",
	.definition = @"definition",
	.flags = @"flags",
	.keyboardType = @"keyboardType",
	.label = @"label",
	.lastmoddate = @"lastmoddate",
	.loincCode = @"loincCode",
	.options = @"options",
	.placeHolder = @"placeHolder",
	.snomedCID = @"snomedCID",
	.snomedFSN = @"snomedFSN",
	.sortRank = @"sortRank",
	.title = @"title",
	.valueTypeCode = @"valueTypeCode",
	.wmcareplanitem_id = @"wmcareplanitem_id",
};

const struct WMCarePlanItemRelationships WMCarePlanItemRelationships = {
	.category = @"category",
	.values = @"values",
};

const struct WMCarePlanItemFetchedProperties WMCarePlanItemFetchedProperties = {
};

@implementation WMCarePlanItemID
@end

@implementation _WMCarePlanItem

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMCarePlanItem" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMCarePlanItem";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMCarePlanItem" inManagedObjectContext:moc_];
}

- (WMCarePlanItemID*)objectID {
	return (WMCarePlanItemID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"flagsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"flags"];
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
	if ([key isEqualToString:@"valueTypeCodeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"valueTypeCode"];
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






@dynamic lastmoddate;






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





@dynamic wmcareplanitem_id;






@dynamic category;

	

@dynamic values;

	
- (NSMutableSet*)valuesSet {
	[self willAccessValueForKey:@"values"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"values"];
  
	[self didAccessValueForKey:@"values"];
	return result;
}
	






@end
