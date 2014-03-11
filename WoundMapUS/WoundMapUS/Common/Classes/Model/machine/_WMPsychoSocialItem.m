// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMPsychoSocialItem.m instead.

#import "_WMPsychoSocialItem.h"

const struct WMPsychoSocialItemAttributes WMPsychoSocialItemAttributes = {
	.createdAt = @"createdAt",
	.definition = @"definition",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.iapIdentifier = @"iapIdentifier",
	.loincCode = @"loincCode",
	.options = @"options",
	.prefixTitle = @"prefixTitle",
	.score = @"score",
	.sectionTitle = @"sectionTitle",
	.snomedCID = @"snomedCID",
	.snomedFSN = @"snomedFSN",
	.sortRank = @"sortRank",
	.subitemPrompt = @"subitemPrompt",
	.subtitle = @"subtitle",
	.title = @"title",
	.updatedAt = @"updatedAt",
	.valueTypeCode = @"valueTypeCode",
};

const struct WMPsychoSocialItemRelationships WMPsychoSocialItemRelationships = {
	.parentItem = @"parentItem",
	.subitems = @"subitems",
	.values = @"values",
	.woundTypes = @"woundTypes",
};

const struct WMPsychoSocialItemFetchedProperties WMPsychoSocialItemFetchedProperties = {
};

@implementation WMPsychoSocialItemID
@end

@implementation _WMPsychoSocialItem

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMPsychoSocialItem" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMPsychoSocialItem";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMPsychoSocialItem" inManagedObjectContext:moc_];
}

- (WMPsychoSocialItemID*)objectID {
	return (WMPsychoSocialItemID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"flagsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"flags"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"scoreValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"score"];
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





@dynamic iapIdentifier;






@dynamic loincCode;






@dynamic options;






@dynamic prefixTitle;






@dynamic score;



- (int16_t)scoreValue {
	NSNumber *result = [self score];
	return [result shortValue];
}

- (void)setScoreValue:(int16_t)value_ {
	[self setScore:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveScoreValue {
	NSNumber *result = [self primitiveScore];
	return [result shortValue];
}

- (void)setPrimitiveScoreValue:(int16_t)value_ {
	[self setPrimitiveScore:[NSNumber numberWithShort:value_]];
}





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





@dynamic subitemPrompt;






@dynamic subtitle;






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





@dynamic parentItem;

	

@dynamic subitems;

	
- (NSMutableSet*)subitemsSet {
	[self willAccessValueForKey:@"subitems"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"subitems"];
  
	[self didAccessValueForKey:@"subitems"];
	return result;
}
	

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
