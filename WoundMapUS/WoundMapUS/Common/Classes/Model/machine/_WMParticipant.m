// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMParticipant.m instead.

#import "_WMParticipant.h"

const struct WMParticipantAttributes WMParticipantAttributes = {
	.createdAt = @"createdAt",
	.dateLastSignin = @"dateLastSignin",
	.email = @"email",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.guid = @"guid",
	.name = @"name",
	.permissions = @"permissions",
	.updatedAt = @"updatedAt",
	.userName = @"userName",
};

const struct WMParticipantRelationships WMParticipantRelationships = {
	.acquiredConsults = @"acquiredConsults",
	.interventionEvents = @"interventionEvents",
	.participantType = @"participantType",
	.person = @"person",
	.team = @"team",
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

	return keyPaths;
}




@dynamic createdAt;






@dynamic dateLastSignin;






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
	

@dynamic participantType;

	

@dynamic person;

	

@dynamic team;

	






@end
