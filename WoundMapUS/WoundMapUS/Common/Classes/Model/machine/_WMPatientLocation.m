// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMPatientLocation.m instead.

#import "_WMPatientLocation.h"

const struct WMPatientLocationAttributes WMPatientLocationAttributes = {
	.facility = @"facility",
	.location = @"location",
	.room = @"room",
	.unit = @"unit",
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
	

	return keyPaths;
}




@dynamic facility;






@dynamic location;






@dynamic room;






@dynamic unit;






@dynamic patient;

	






@end
