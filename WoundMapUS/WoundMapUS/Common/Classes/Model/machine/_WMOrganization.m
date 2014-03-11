// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMOrganization.m instead.

#import "_WMOrganization.h"

const struct WMOrganizationAttributes WMOrganizationAttributes = {
	.createdAt = @"createdAt",
	.ffUrl = @"ffUrl",
	.name = @"name",
	.updatedAt = @"updatedAt",
};

const struct WMOrganizationRelationships WMOrganizationRelationships = {
	.addresses = @"addresses",
	.ids = @"ids",
};

const struct WMOrganizationFetchedProperties WMOrganizationFetchedProperties = {
};

@implementation WMOrganizationID
@end

@implementation _WMOrganization

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMOrganization" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMOrganization";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMOrganization" inManagedObjectContext:moc_];
}

- (WMOrganizationID*)objectID {
	return (WMOrganizationID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic createdAt;






@dynamic ffUrl;






@dynamic name;






@dynamic updatedAt;






@dynamic addresses;

	
- (NSMutableSet*)addressesSet {
	[self willAccessValueForKey:@"addresses"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"addresses"];
  
	[self didAccessValueForKey:@"addresses"];
	return result;
}
	

@dynamic ids;

	
- (NSMutableSet*)idsSet {
	[self willAccessValueForKey:@"ids"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"ids"];
  
	[self didAccessValueForKey:@"ids"];
	return result;
}
	






@end
