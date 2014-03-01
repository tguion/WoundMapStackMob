// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundTreatmentGroup.m instead.

#import "_WMWoundTreatmentGroup.h"

const struct WMWoundTreatmentGroupAttributes WMWoundTreatmentGroupAttributes = {
	.closedFlag = @"closedFlag",
	.continueCount = @"continueCount",
	.createddate = @"createddate",
	.dateCreated = @"dateCreated",
	.dateModified = @"dateModified",
	.datePushed = @"datePushed",
	.flags = @"flags",
	.lastmoddate = @"lastmoddate",
	.wmwoundtreatmentgroup_id = @"wmwoundtreatmentgroup_id",
};

const struct WMWoundTreatmentGroupRelationships WMWoundTreatmentGroupRelationships = {
	.values = @"values",
	.wound = @"wound",
};

const struct WMWoundTreatmentGroupFetchedProperties WMWoundTreatmentGroupFetchedProperties = {
};

@implementation WMWoundTreatmentGroupID
@end

@implementation _WMWoundTreatmentGroup

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMWoundTreatmentGroup" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMWoundTreatmentGroup";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMWoundTreatmentGroup" inManagedObjectContext:moc_];
}

- (WMWoundTreatmentGroupID*)objectID {
	return (WMWoundTreatmentGroupID*)[super objectID];
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






@dynamic wmwoundtreatmentgroup_id;






@dynamic values;

	
- (NSMutableSet*)valuesSet {
	[self willAccessValueForKey:@"values"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"values"];
  
	[self didAccessValueForKey:@"values"];
	return result;
}
	

@dynamic wound;

	






@end
