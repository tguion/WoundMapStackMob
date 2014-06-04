// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMTeam.m instead.

#import "_WMTeam.h"

const struct WMTeamAttributes WMTeamAttributes = {
	.createdAt = @"createdAt",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.iapTeamMemberSuccessCount = @"iapTeamMemberSuccessCount",
	.name = @"name",
	.purchasedPatientCount = @"purchasedPatientCount",
	.updatedAt = @"updatedAt",
};

const struct WMTeamRelationships WMTeamRelationships = {
	.consultingGroup = @"consultingGroup",
	.invitations = @"invitations",
	.navigationTracks = @"navigationTracks",
	.participants = @"participants",
	.patients = @"patients",
	.teamPolicy = @"teamPolicy",
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
	if ([key isEqualToString:@"iapTeamMemberSuccessCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"iapTeamMemberSuccessCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"purchasedPatientCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"purchasedPatientCount"];
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





@dynamic iapTeamMemberSuccessCount;



- (int16_t)iapTeamMemberSuccessCountValue {
	NSNumber *result = [self iapTeamMemberSuccessCount];
	return [result shortValue];
}

- (void)setIapTeamMemberSuccessCountValue:(int16_t)value_ {
	[self setIapTeamMemberSuccessCount:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveIapTeamMemberSuccessCountValue {
	NSNumber *result = [self primitiveIapTeamMemberSuccessCount];
	return [result shortValue];
}

- (void)setPrimitiveIapTeamMemberSuccessCountValue:(int16_t)value_ {
	[self setPrimitiveIapTeamMemberSuccessCount:[NSNumber numberWithShort:value_]];
}





@dynamic name;






@dynamic purchasedPatientCount;



- (int32_t)purchasedPatientCountValue {
	NSNumber *result = [self purchasedPatientCount];
	return [result intValue];
}

- (void)setPurchasedPatientCountValue:(int32_t)value_ {
	[self setPurchasedPatientCount:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitivePurchasedPatientCountValue {
	NSNumber *result = [self primitivePurchasedPatientCount];
	return [result intValue];
}

- (void)setPrimitivePurchasedPatientCountValue:(int32_t)value_ {
	[self setPrimitivePurchasedPatientCount:[NSNumber numberWithInt:value_]];
}





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
	

@dynamic teamPolicy;

	






@end
