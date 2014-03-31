// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMOrganization.m instead.

#import "_WMOrganization.h"

const struct WMOrganizationAttributes WMOrganizationAttributes = {
	.createdAt = @"createdAt",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.name = @"name",
	.updatedAt = @"updatedAt",
};

const struct WMOrganizationRelationships WMOrganizationRelationships = {
	.addresses = @"addresses",
	.ids = @"ids",
	.participants = @"participants",
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
	
	if ([key isEqualToString:@"flagsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"flags"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic createdAt;






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
	

@dynamic participants;

	
- (NSMutableSet*)participantsSet {
	[self willAccessValueForKey:@"participants"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"participants"];
  
	[self didAccessValueForKey:@"participants"];
	return result;
}
	






@end
