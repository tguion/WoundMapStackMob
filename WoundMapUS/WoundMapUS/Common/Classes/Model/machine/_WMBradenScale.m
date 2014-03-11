// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMBradenScale.m instead.

#import "_WMBradenScale.h"

const struct WMBradenScaleAttributes WMBradenScaleAttributes = {
	.closedFlag = @"closedFlag",
	.completeFlag = @"completeFlag",
	.createdAt = @"createdAt",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.score = @"score",
	.updatedAt = @"updatedAt",
};

const struct WMBradenScaleRelationships WMBradenScaleRelationships = {
	.patient = @"patient",
	.sections = @"sections",
};

const struct WMBradenScaleFetchedProperties WMBradenScaleFetchedProperties = {
};

@implementation WMBradenScaleID
@end

@implementation _WMBradenScale

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMBradenScale" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMBradenScale";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMBradenScale" inManagedObjectContext:moc_];
}

- (WMBradenScaleID*)objectID {
	return (WMBradenScaleID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"closedFlagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"closedFlag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"completeFlagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"completeFlag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
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





@dynamic completeFlag;



- (BOOL)completeFlagValue {
	NSNumber *result = [self completeFlag];
	return [result boolValue];
}

- (void)setCompleteFlagValue:(BOOL)value_ {
	[self setCompleteFlag:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveCompleteFlagValue {
	NSNumber *result = [self primitiveCompleteFlag];
	return [result boolValue];
}

- (void)setPrimitiveCompleteFlagValue:(BOOL)value_ {
	[self setPrimitiveCompleteFlag:[NSNumber numberWithBool:value_]];
}





@dynamic createdAt;






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





@dynamic updatedAt;






@dynamic patient;

	

@dynamic sections;

	
- (NSMutableSet*)sectionsSet {
	[self willAccessValueForKey:@"sections"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"sections"];
  
	[self didAccessValueForKey:@"sections"];
	return result;
}
	






@end
