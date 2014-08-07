// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMPatientLocation.m instead.

#import "_WMPatientLocation.h"

const struct WMPatientLocationAttributes WMPatientLocationAttributes = {
	.createdAt = @"createdAt",
	.facility = @"facility",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.location = @"location",
	.room = @"room",
	.unit = @"unit",
	.updatedAt = @"updatedAt",
};

const struct WMPatientLocationRelationships WMPatientLocationRelationships = {
	.patient = @"patient",
};

const struct WMPatientLocationFetchedProperties WMPatientLocationFetchedProperties = {
};

@implementation WMPatientLocationID
@end

@implementation _WMPatientLocation

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMPatientLocation" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMPatientLocation";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMPatientLocation" inManagedObjectContext:moc_];
}

- (WMPatientLocationID*)objectID {
	return (WMPatientLocationID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"flagsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"flags"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic createdAt;






@dynamic facility;






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





@dynamic location;






@dynamic room;






@dynamic unit;






@dynamic updatedAt;






@dynamic patient;

	






@end
