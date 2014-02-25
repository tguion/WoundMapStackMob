// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundMeasurementValue.m instead.

#import "_WMWoundMeasurementValue.h"

const struct WMWoundMeasurementValueAttributes WMWoundMeasurementValueAttributes = {
	.createddate = @"createddate",
	.dateCreated = @"dateCreated",
	.dateModified = @"dateModified",
	.datePushed = @"datePushed",
	.flags = @"flags",
	.lastmoddate = @"lastmoddate",
	.revisedFlag = @"revisedFlag",
	.title = @"title",
	.value = @"value",
	.wmwoundmeasurementvalue_id = @"wmwoundmeasurementvalue_id",
};

const struct WMWoundMeasurementValueRelationships WMWoundMeasurementValueRelationships = {
	.amountQualifier = @"amountQualifier",
	.group = @"group",
	.odor = @"odor",
	.woundMeasurement = @"woundMeasurement",
};

const struct WMWoundMeasurementValueFetchedProperties WMWoundMeasurementValueFetchedProperties = {
};

@implementation WMWoundMeasurementValueID
@end

@implementation _WMWoundMeasurementValue

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMWoundMeasurementValue" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMWoundMeasurementValue";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMWoundMeasurementValue" inManagedObjectContext:moc_];
}

- (WMWoundMeasurementValueID*)objectID {
	return (WMWoundMeasurementValueID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"flagsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"flags"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"revisedFlagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"revisedFlag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
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






@dynamic revisedFlag;



- (BOOL)revisedFlagValue {
	NSNumber *result = [self revisedFlag];
	return [result boolValue];
}

- (void)setRevisedFlagValue:(BOOL)value_ {
	[self setRevisedFlag:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveRevisedFlagValue {
	NSNumber *result = [self primitiveRevisedFlag];
	return [result boolValue];
}

- (void)setPrimitiveRevisedFlagValue:(BOOL)value_ {
	[self setPrimitiveRevisedFlag:[NSNumber numberWithBool:value_]];
}





@dynamic title;






@dynamic value;






@dynamic wmwoundmeasurementvalue_id;






@dynamic amountQualifier;

	

@dynamic group;

	

@dynamic odor;

	

@dynamic woundMeasurement;

	






@end
