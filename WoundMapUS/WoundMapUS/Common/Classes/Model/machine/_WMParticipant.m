// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMParticipant.m instead.

#import "_WMParticipant.h"

const struct WMParticipantAttributes WMParticipantAttributes = {
	.bio = @"bio",
	.createdAt = @"createdAt",
	.dateAddedToTeam = @"dateAddedToTeam",
	.dateLastSignin = @"dateLastSignin",
	.dateTeamSubscriptionExpires = @"dateTeamSubscriptionExpires",
	.email = @"email",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.guid = @"guid",
	.lastTokenCreditPurchaseDate = @"lastTokenCreditPurchaseDate",
	.name = @"name",
	.permissions = @"permissions",
	.reportTokenCount = @"reportTokenCount",
	.thumbnail = @"thumbnail",
	.updatedAt = @"updatedAt",
	.userName = @"userName",
};

const struct WMParticipantRelationships WMParticipantRelationships = {
	.acquiredConsults = @"acquiredConsults",
	.interventionEvents = @"interventionEvents",
	.organization = @"organization",
	.participantType = @"participantType",
	.patients = @"patients",
	.person = @"person",
	.sourceReferrals = @"sourceReferrals",
	.targetReferrals = @"targetReferrals",
	.team = @"team",
	.teamInvitation = @"teamInvitation",
};

const struct WMParticipantFetchedProperties WMParticipantFetchedProperties = {
};

@implementation WMParticipantID
@end

@implementation _WMParticipant

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMParticipant" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMParticipant";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMParticipant" inManagedObjectContext:moc_];
}

- (WMParticipantID*)objectID {
	return (WMParticipantID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"flagsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"flags"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"permissionsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"permissions"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"reportTokenCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"reportTokenCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic bio;






@dynamic createdAt;






@dynamic dateAddedToTeam;






@dynamic dateLastSignin;






@dynamic dateTeamSubscriptionExpires;






@dynamic email;






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





@dynamic guid;






@dynamic lastTokenCreditPurchaseDate;






@dynamic name;






@dynamic permissions;



- (int32_t)permissionsValue {
	NSNumber *result = [self permissions];
	return [result intValue];
}

- (void)setPermissionsValue:(int32_t)value_ {
	[self setPermissions:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitivePermissionsValue {
	NSNumber *result = [self primitivePermissions];
	return [result intValue];
}

- (void)setPrimitivePermissionsValue:(int32_t)value_ {
	[self setPrimitivePermissions:[NSNumber numberWithInt:value_]];
}





@dynamic reportTokenCount;



- (int16_t)reportTokenCountValue {
	NSNumber *result = [self reportTokenCount];
	return [result shortValue];
}

- (void)setReportTokenCountValue:(int16_t)value_ {
	[self setReportTokenCount:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveReportTokenCountValue {
	NSNumber *result = [self primitiveReportTokenCount];
	return [result shortValue];
}

- (void)setPrimitiveReportTokenCountValue:(int16_t)value_ {
	[self setPrimitiveReportTokenCount:[NSNumber numberWithShort:value_]];
}





@dynamic thumbnail;






@dynamic updatedAt;






@dynamic userName;






@dynamic acquiredConsults;

	
- (NSMutableSet*)acquiredConsultsSet {
	[self willAccessValueForKey:@"acquiredConsults"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"acquiredConsults"];
  
	[self didAccessValueForKey:@"acquiredConsults"];
	return result;
}
	

@dynamic interventionEvents;

	
- (NSMutableSet*)interventionEventsSet {
	[self willAccessValueForKey:@"interventionEvents"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"interventionEvents"];
  
	[self didAccessValueForKey:@"interventionEvents"];
	return result;
}
	

@dynamic organization;

	

@dynamic participantType;

	

@dynamic patients;

	
- (NSMutableSet*)patientsSet {
	[self willAccessValueForKey:@"patients"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"patients"];
  
	[self didAccessValueForKey:@"patients"];
	return result;
}
	

@dynamic person;

	

@dynamic sourceReferrals;

	
- (NSMutableSet*)sourceReferralsSet {
	[self willAccessValueForKey:@"sourceReferrals"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"sourceReferrals"];
  
	[self didAccessValueForKey:@"sourceReferrals"];
	return result;
}
	

@dynamic targetReferrals;

	
- (NSMutableSet*)targetReferralsSet {
	[self willAccessValueForKey:@"targetReferrals"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"targetReferrals"];
  
	[self didAccessValueForKey:@"targetReferrals"];
	return result;
}
	

@dynamic team;

	

@dynamic teamInvitation;

	






@end
