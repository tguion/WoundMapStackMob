// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMTeam.m instead.

#import "_WMTeam.h"

const struct WMTeamAttributes WMTeamAttributes = {
	.createdAt = @"createdAt",
	.ffUrl = @"ffUrl",
	.name = @"name",
	.updatedAt = @"updatedAt",
};

const struct WMTeamRelationships WMTeamRelationships = {
	.consultingGroup = @"consultingGroup",
	.participants = @"participants",
};

const struct WMTeamFetchedProperties WMTeamFetchedProperties = {
};

@implementation WMTeamID
@end

@implementation _WMTeam

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMTeam" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMTeam";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMTeam" inManagedObjectContext:moc_];
}

- (WMTeamID*)objectID {
	return (WMTeamID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic createdAt;






@dynamic ffUrl;






@dynamic name;






@dynamic updatedAt;






@dynamic consultingGroup;

	

@dynamic participants;

	
- (NSMutableSet*)participantsSet {
	[self willAccessValueForKey:@"participants"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"participants"];
  
	[self didAccessValueForKey:@"participants"];
	return result;
}
	






@end
