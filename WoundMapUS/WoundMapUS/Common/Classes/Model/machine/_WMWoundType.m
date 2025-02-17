// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundType.m instead.

#import "_WMWoundType.h"

const struct WMWoundTypeAttributes WMWoundTypeAttributes = {
	.createdAt = @"createdAt",
	.definition = @"definition",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.label = @"label",
	.loincCode = @"loincCode",
	.options = @"options",
	.placeHolder = @"placeHolder",
	.sectionTitle = @"sectionTitle",
	.snomedCID = @"snomedCID",
	.snomedFSN = @"snomedFSN",
	.sortRank = @"sortRank",
	.title = @"title",
	.updatedAt = @"updatedAt",
	.valueTypeCode = @"valueTypeCode",
	.woundTypeCode = @"woundTypeCode",
};

const struct WMWoundTypeRelationships WMWoundTypeRelationships = {
	.carePlanCategories = @"carePlanCategories",
	.children = @"children",
	.deviceCategories = @"deviceCategories",
	.iapProducts = @"iapProducts",
	.medicationCategories = @"medicationCategories",
	.parent = @"parent",
	.psychosocialItems = @"psychosocialItems",
	.skinAssessmentCategories = @"skinAssessmentCategories",
	.woundMeasurements = @"woundMeasurements",
	.woundTreatments = @"woundTreatments",
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





@dynamic carePlanCategories;

	
- (NSMutableSet*)carePlanCategoriesSet {
	[self willAccessValueForKey:@"carePlanCategories"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"carePlanCategories"];
  
	[self didAccessValueForKey:@"carePlanCategories"];
	return result;
}
	

@dynamic children;

	
- (NSMutableSet*)childrenSet {
	[self willAccessValueForKey:@"children"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"children"];
  
	[self didAccessValueForKey:@"children"];
	return result;
}
	

@dynamic deviceCategories;

	
- (NSMutableSet*)deviceCategoriesSet {
	[self willAccessValueForKey:@"deviceCategories"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"deviceCategories"];
  
	[self didAccessValueForKey:@"deviceCategories"];
	return result;
}
	

@dynamic iapProducts;

	
- (NSMutableSet*)iapProductsSet {
	[self willAccessValueForKey:@"iapProducts"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"iapProducts"];
  
	[self didAccessValueForKey:@"iapProducts"];
	return result;
}
	

@dynamic medicationCategories;

	
- (NSMutableSet*)medicationCategoriesSet {
	[self willAccessValueForKey:@"medicationCategories"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"medicationCategories"];
  
	[self didAccessValueForKey:@"medicationCategories"];
	return result;
}
	

@dynamic parent;

	

@dynamic psychosocialItems;

	
- (NSMutableSet*)psychosocialItemsSet {
	[self willAccessValueForKey:@"psychosocialItems"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"psychosocialItems"];
  
	[self didAccessValueForKey:@"psychosocialItems"];
	return result;
}
	

@dynamic skinAssessmentCategories;

	
- (NSMutableSet*)skinAssessmentCategoriesSet {
	[self willAccessValueForKey:@"skinAssessmentCategories"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"skinAssessmentCategories"];
  
	[self didAccessValueForKey:@"skinAssessmentCategories"];
	return result;
}
	

@dynamic woundMeasurements;

	
- (NSMutableSet*)woundMeasurementsSet {
	[self willAccessValueForKey:@"woundMeasurements"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"woundMeasurements"];
  
	[self didAccessValueForKey:@"woundMeasurements"];
	return result;
}
	

@dynamic woundTreatments;

	
- (NSMutableSet*)woundTreatmentsSet {
	[self willAccessValueForKey:@"woundTreatments"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"woundTreatments"];
  
	[self didAccessValueForKey:@"woundTreatments"];
	return result;
}
	

@dynamic wounds;

	
- (NSMutableSet*)woundsSet {
	[self willAccessValueForKey:@"wounds"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"wounds"];
  
	[self didAccessValueForKey:@"wounds"];
	return result;
}
	






@end
