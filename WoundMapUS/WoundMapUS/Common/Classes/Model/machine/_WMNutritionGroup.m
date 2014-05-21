// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMNutritionGroup.m instead.

#import "_WMNutritionGroup.h"

const struct WMNutritionGroupAttributes WMNutritionGroupAttributes = {
	.closedFlag = @"closedFlag",
	.continueCount = @"continueCount",
	.createdAt = @"createdAt",
	.datePushed = @"datePushed",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.loincCode = @"loincCode",
	.snomedCID = @"snomedCID",
	.snomedFSN = @"snomedFSN",
	.updatedAt = @"updatedAt",
};

const struct WMNutritionGroupRelationships WMNutritionGroupRelationships = {
	.interventionEvents = @"interventionEvents",
	.patient = @"patient",
	.status = @"status",
	.values = @"values",
};

const struct WMNutritionGroupFetchedProperties WMNutritionGroupFetchedProperties = {
};

@implementation WMNutritionGroupID
@end

@implementation _WMNutritionGroup

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMNutritionGroup" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMNutritionGroup";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMNutritionGroup" inManagedObjectContext:moc_];
}

- (WMNutritionGroupID*)objectID {
	return (WMNutritionGroupID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"closedFlagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"closedFlag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"continueCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"continueCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
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

	return keyPaths;
}




@dynamic closedFlag;



- (BOOL)closedFlagValue {
	NSNumber *result = [self closedFlag];
	return [result boolValue];
}

- (void)setClosedFlagValue:(BOOL)value_ {
	[self setClosedFlag:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveClosedFlagValue {
	NSNumber *result = [self primitiveClosedFlag];
	return [result boolValue];
}

- (void)setPrimitiveClosedFlagValue:(BOOL)value_ {
	[self setPrimitiveClosedFlag:[NSNumber numberWithBool:value_]];
}





@dynamic continueCount;



- (int16_t)continueCountValue {
	NSNumber *result = [self continueCount];
	return [result shortValue];
}

- (void)setContinueCountValue:(int16_t)value_ {
	[self setContinueCount:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveContinueCountValue {
	NSNumber *result = [self primitiveContinueCount];
	return [result shortValue];
}

- (void)setPrimitiveContinueCountValue:(int16_t)value_ {
	[self setPrimitiveContinueCount:[NSNumber numberWithShort:value_]];
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





@dynamic loincCode;






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






@dynamic updatedAt;






@dynamic interventionEvents;

	
- (NSMutableSet*)interventionEventsSet {
	[self willAccessValueForKey:@"interventionEvents"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"interventionEvents"];
  
	[self didAccessValueForKey:@"interventionEvents"];
	return result;
}
	

@dynamic patient;

	

@dynamic status;

	

@dynamic values;

	
- (NSMutableSet*)valuesSet {
	[self willAccessValueForKey:@"values"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"values"];
  
	[self didAccessValueForKey:@"values"];
	return result;
}
	






@end
