// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMPerson.m instead.

#import "_WMPerson.h"

const struct WMPersonAttributes WMPersonAttributes = {
	.createdAt = @"createdAt",
	.ffUrl = @"ffUrl",
	.nameFamily = @"nameFamily",
	.nameGiven = @"nameGiven",
	.namePrefix = @"namePrefix",
	.nameSuffix = @"nameSuffix",
	.updatedAt = @"updatedAt",
};

const struct WMPersonRelationships WMPersonRelationships = {
	.addresses = @"addresses",
	.participant = @"participant",
	.patient = @"patient",
	.telecoms = @"telecoms",
};

const struct WMPersonFetchedProperties WMPersonFetchedProperties = {
};

@implementation WMPersonID
@end

@implementation _WMPerson

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMPerson" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMPerson";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMPerson" inManagedObjectContext:moc_];
}

- (WMPersonID*)objectID {
	return (WMPersonID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic createdAt;






@dynamic ffUrl;






@dynamic nameFamily;






@dynamic nameGiven;






@dynamic namePrefix;






@dynamic nameSuffix;






@dynamic updatedAt;






@dynamic addresses;

	
- (NSMutableSet*)addressesSet {
	[self willAccessValueForKey:@"addresses"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"addresses"];
  
	[self didAccessValueForKey:@"addresses"];
	return result;
}
	

@dynamic participant;

	

@dynamic patient;

	

@dynamic telecoms;

	
- (NSMutableSet*)telecomsSet {
	[self willAccessValueForKey:@"telecoms"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"telecoms"];
  
	[self didAccessValueForKey:@"telecoms"];
	return result;
}
	






@end
