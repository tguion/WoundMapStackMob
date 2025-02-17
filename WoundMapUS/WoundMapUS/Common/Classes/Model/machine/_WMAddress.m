// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMAddress.m instead.

#import "_WMAddress.h"

const struct WMAddressAttributes WMAddressAttributes = {
	.city = @"city",
	.country = @"country",
	.createdAt = @"createdAt",
	.ffUrl = @"ffUrl",
	.postalCode = @"postalCode",
	.state = @"state",
	.streetAddressLine = @"streetAddressLine",
	.streetAddressLine1 = @"streetAddressLine1",
	.updatedAt = @"updatedAt",
};

const struct WMAddressRelationships WMAddressRelationships = {
	.organization = @"organization",
	.person = @"person",
};

const struct WMAddressFetchedProperties WMAddressFetchedProperties = {
};

@implementation WMAddressID
@end

@implementation _WMAddress

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMAddress" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMAddress";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMAddress" inManagedObjectContext:moc_];
}

- (WMAddressID*)objectID {
	return (WMAddressID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic city;






@dynamic country;






@dynamic createdAt;






@dynamic ffUrl;






@dynamic postalCode;






@dynamic state;






@dynamic streetAddressLine;






@dynamic streetAddressLine1;






@dynamic updatedAt;






@dynamic organization;

	

@dynamic person;

	






@end
