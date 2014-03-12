// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMPatientConsultant.m instead.

#import "_WMPatientConsultant.h"

const struct WMPatientConsultantAttributes WMPatientConsultantAttributes = {
	.acquiredFlag = @"acquiredFlag",
	.createdAt = @"createdAt",
	.dateAquired = @"dateAquired",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.updatedAt = @"updatedAt",
};

const struct WMPatientConsultantRelationships WMPatientConsultantRelationships = {
	.participant = @"participant",
	.patient = @"patient",
};

const struct WMPatientConsultantFetchedProperties WMPatientConsultantFetchedProperties = {
};

@implementation WMPatientConsultantID
@end

@implementation _WMPatientConsultant

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMPatientConsultant" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMPatientConsultant";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMPatientConsultant" inManagedObjectContext:moc_];
}

- (WMPatientConsultantID*)objectID {
	return (WMPatientConsultantID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"acquiredFlagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"acquiredFlag"];
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




@dynamic acquiredFlag;



- (BOOL)acquiredFlagValue {
	NSNumber *result = [self acquiredFlag];
	return [result boolValue];
}

- (void)setAcquiredFlagValue:(BOOL)value_ {
	[self setAcquiredFlag:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveAcquiredFlagValue {
	NSNumber *result = [self primitiveAcquiredFlag];
	return [result boolValue];
}

- (void)setPrimitiveAcquiredFlagValue:(BOOL)value_ {
	[self setPrimitiveAcquiredFlag:[NSNumber numberWithBool:value_]];
}





@dynamic createdAt;






@dynamic dateAquired;






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





@dynamic updatedAt;






@dynamic participant;

	

@dynamic patient;

	






@end
