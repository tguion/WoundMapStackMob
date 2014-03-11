// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMSkinAssessmentCategory.m instead.

#import "_WMSkinAssessmentCategory.h"

const struct WMSkinAssessmentCategoryAttributes WMSkinAssessmentCategoryAttributes = {
	.createdAt = @"createdAt",
	.definition = @"definition",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.iapIdentifier = @"iapIdentifier",
	.loincCode = @"loincCode",
	.section = @"section",
	.snomedCID = @"snomedCID",
	.snomedFSN = @"snomedFSN",
	.sortRank = @"sortRank",
	.title = @"title",
	.updatedAt = @"updatedAt",
};

const struct WMSkinAssessmentCategoryRelationships WMSkinAssessmentCategoryRelationships = {
	.assessments = @"assessments",
	.woundTypes = @"woundTypes",
};

const struct WMSkinAssessmentCategoryFetchedProperties WMSkinAssessmentCategoryFetchedProperties = {
};

@implementation WMSkinAssessmentCategoryID
@end

@implementation _WMSkinAssessmentCategory

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMSkinAssessmentCategory" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMSkinAssessmentCategory";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMSkinAssessmentCategory" inManagedObjectContext:moc_];
}

- (WMSkinAssessmentCategoryID*)objectID {
	return (WMSkinAssessmentCategoryID*)[super objectID];
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






@dynamic section;






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






@dynamic assessments;

	
- (NSMutableSet*)assessmentsSet {
	[self willAccessValueForKey:@"assessments"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"assessments"];
  
	[self didAccessValueForKey:@"assessments"];
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
