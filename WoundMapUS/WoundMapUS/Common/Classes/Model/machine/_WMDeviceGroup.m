// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMDeviceGroup.m instead.

#import "_WMDeviceGroup.h"

const struct WMDeviceGroupAttributes WMDeviceGroupAttributes = {
	.closedFlag = @"closedFlag",
	.continueCount = @"continueCount",
	.createddate = @"createddate",
	.dateCreated = @"dateCreated",
	.dateModified = @"dateModified",
	.datePushed = @"datePushed",
	.flags = @"flags",
	.lastmoddate = @"lastmoddate",
	.wmdevicegroup_id = @"wmdevicegroup_id",
};

const struct WMDeviceGroupRelationships WMDeviceGroupRelationships = {
	.patient = @"patient",
	.values = @"values",
};

const struct WMDeviceGroupFetchedProperties WMDeviceGroupFetchedProperties = {
};

@implementation WMDeviceGroupID
@end

@implementation _WMDeviceGroup

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMDeviceGroup" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMDeviceGroup";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMDeviceGroup" inManagedObjectContext:moc_];
}

- (WMDeviceGroupID*)objectID {
	return (WMDeviceGroupID*)[super objectID];
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






@dynamic wmdevicegroup_id;






@dynamic patient;

	

@dynamic values;

	
- (NSMutableSet*)valuesSet {
	[self willAccessValueForKey:@"values"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"values"];
  
	[self didAccessValueForKey:@"values"];
	return result;
}
	






@end
