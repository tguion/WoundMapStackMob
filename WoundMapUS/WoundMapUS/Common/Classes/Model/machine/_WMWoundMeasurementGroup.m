// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundMeasurementGroup.m instead.

#import "_WMWoundMeasurementGroup.h"

const struct WMWoundMeasurementGroupAttributes WMWoundMeasurementGroupAttributes = {
	.closedFlag = @"closedFlag",
	.continueCount = @"continueCount",
	.createddate = @"createddate",
	.dateCreated = @"dateCreated",
	.dateModified = @"dateModified",
	.datePushed = @"datePushed",
	.flags = @"flags",
	.lastmoddate = @"lastmoddate",
	.wmwoundmeasurementgroup_id = @"wmwoundmeasurementgroup_id",
};

const struct WMWoundMeasurementGroupRelationships WMWoundMeasurementGroupRelationships = {
	.interventionEvents = @"interventionEvents",
	.status = @"status",
	.values = @"values",
	.wound = @"wound",
	.woundPhoto = @"woundPhoto",
};

const struct WMWoundMeasurementGroupFetchedProperties WMWoundMeasurementGroupFetchedProperties = {
};

@implementation WMWoundMeasurementGroupID
@end

@implementation _WMWoundMeasurementGroup

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMWoundMeasurementGroup" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMWoundMeasurementGroup";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMWoundMeasurementGroup" inManagedObjectContext:moc_];
}

- (WMWoundMeasurementGroupID*)objectID {
	return (WMWoundMeasurementGroupID*)[super objectID];
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





@dynamic createddate;






@dynamic dateCreated;






@dynamic dateModified;






@dynamic datePushed;






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






@dynamic wmwoundmeasurementgroup_id;






@dynamic interventionEvents;

	
- (NSMutableSet*)interventionEventsSet {
	[self willAccessValueForKey:@"interventionEvents"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"interventionEvents"];
  
	[self didAccessValueForKey:@"interventionEvents"];
	return result;
}
	

@dynamic status;

	

@dynamic values;

	
- (NSMutableSet*)valuesSet {
	[self willAccessValueForKey:@"values"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"values"];
  
	[self didAccessValueForKey:@"values"];
	return result;
}
	

@dynamic wound;

	

@dynamic woundPhoto;

	






@end
