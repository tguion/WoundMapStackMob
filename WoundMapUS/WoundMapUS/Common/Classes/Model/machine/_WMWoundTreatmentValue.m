// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundTreatmentValue.m instead.

#import "_WMWoundTreatmentValue.h"

const struct WMWoundTreatmentValueAttributes WMWoundTreatmentValueAttributes = {
	.createddate = @"createddate",
	.flags = @"flags",
	.lastmoddate = @"lastmoddate",
	.revisedFlag = @"revisedFlag",
	.title = @"title",
	.value = @"value",
	.wmwoundtreatmentvalue_id = @"wmwoundtreatmentvalue_id",
};

const struct WMWoundTreatmentValueRelationships WMWoundTreatmentValueRelationships = {
	.group = @"group",
	.woundTreatment = @"woundTreatment",
};

const struct WMWoundTreatmentValueFetchedProperties WMWoundTreatmentValueFetchedProperties = {
};

@implementation WMWoundTreatmentValueID
@end

@implementation _WMWoundTreatmentValue

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMWoundTreatmentValue" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMWoundTreatmentValue";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMWoundTreatmentValue" inManagedObjectContext:moc_];
}

- (WMWoundTreatmentValueID*)objectID {
	return (WMWoundTreatmentValueID*)[super objectID];
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






@dynamic wmwoundtreatmentvalue_id;






@dynamic group;

	

@dynamic woundTreatment;

	






@end
