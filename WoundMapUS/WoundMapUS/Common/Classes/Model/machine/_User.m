// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.m instead.

#import "_User.h"

const struct UserAttributes UserAttributes = {
	.createdate = @"createdate",
	.lastmoddate = @"lastmoddate",
	.username = @"username",
};

const struct UserRelationships UserRelationships = {
	.consultingGroup = @"consultingGroup",
	.consultingPatients = @"consultingPatients",
};

const struct UserFetchedProperties UserFetchedProperties = {
};

@implementation UserID
@end

@implementation _User

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"User";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"User" inManagedObjectContext:moc_];
}

- (UserID*)objectID {
	return (UserID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic createdate;






@dynamic lastmoddate;






@dynamic username;






@dynamic consultingGroup;

	

@dynamic consultingPatients;

	
- (NSMutableSet*)consultingPatientsSet {
	[self willAccessValueForKey:@"consultingPatients"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"consultingPatients"];
  
	[self didAccessValueForKey:@"consultingPatients"];
	return result;
}
	






@end
