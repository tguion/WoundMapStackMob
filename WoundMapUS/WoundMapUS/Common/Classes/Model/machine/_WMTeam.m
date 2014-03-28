// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMTeam.m instead.

#import "_WMTeam.h"

const struct WMTeamAttributes WMTeamAttributes = {
	.createdAt = @"createdAt",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.name = @"name",
	.updatedAt = @"updatedAt",
};

const struct WMTeamRelationships WMTeamRelationships = {
	.consultingGroup = @"consultingGroup",
	.invitations = @"invitations",
	.navigationTracks = @"navigationTracks",
	.participants = @"participants",
	.patients = @"patients",
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






@dynamic consultingGroup;

	

@dynamic invitations;

	
- (NSMutableSet*)invitationsSet {
	[self willAccessValueForKey:@"invitations"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"invitations"];
  
	[self didAccessValueForKey:@"invitations"];
	return result;
}
	

@dynamic navigationTracks;

	
- (NSMutableSet*)navigationTracksSet {
	[self willAccessValueForKey:@"navigationTracks"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"navigationTracks"];
  
	[self didAccessValueForKey:@"navigationTracks"];
	return result;
}
	

@dynamic participants;

	
- (NSMutableSet*)participantsSet {
	[self willAccessValueForKey:@"participants"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"participants"];
  
	[self didAccessValueForKey:@"participants"];
	return result;
}
	

@dynamic patients;

	
- (NSMutableSet*)patientsSet {
	[self willAccessValueForKey:@"patients"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"patients"];
  
	[self didAccessValueForKey:@"patients"];
	return result;
}
	






@end
