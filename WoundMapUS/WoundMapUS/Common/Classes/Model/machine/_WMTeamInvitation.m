// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMTeamInvitation.m instead.

#import "_WMTeamInvitation.h"

const struct WMTeamInvitationAttributes WMTeamInvitationAttributes = {
	.acceptedFlag = @"acceptedFlag",
	.createdAt = @"createdAt",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.invitationMessage = @"invitationMessage",
	.inviteeUserName = @"inviteeUserName",
	.passcode = @"passcode",
	.updatedAt = @"updatedAt",
};

const struct WMTeamInvitationRelationships WMTeamInvitationRelationships = {
	.invitee = @"invitee",
	.team = @"team",
};

const struct WMTeamInvitationFetchedProperties WMTeamInvitationFetchedProperties = {
};

@implementation WMTeamInvitationID
@end

@implementation _WMTeamInvitation

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMTeamInvitation" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMTeamInvitation";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMTeamInvitation" inManagedObjectContext:moc_];
}

- (WMTeamInvitationID*)objectID {
	return (WMTeamInvitationID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"acceptedFlagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"acceptedFlag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"flagsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"flags"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"passcodeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"passcode"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic acceptedFlag;



- (BOOL)acceptedFlagValue {
	NSNumber *result = [self acceptedFlag];
	return [result boolValue];
}

- (void)setAcceptedFlagValue:(BOOL)value_ {
	[self setAcceptedFlag:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveAcceptedFlagValue {
	NSNumber *result = [self primitiveAcceptedFlag];
	return [result boolValue];
}

- (void)setPrimitiveAcceptedFlagValue:(BOOL)value_ {
	[self setPrimitiveAcceptedFlag:[NSNumber numberWithBool:value_]];
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





@dynamic invitationMessage;






@dynamic inviteeUserName;






@dynamic passcode;



- (int16_t)passcodeValue {
	NSNumber *result = [self passcode];
	return [result shortValue];
}

- (void)setPasscodeValue:(int16_t)value_ {
	[self setPasscode:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitivePasscodeValue {
	NSNumber *result = [self primitivePasscode];
	return [result shortValue];
}

- (void)setPrimitivePasscodeValue:(int16_t)value_ {
	[self setPrimitivePasscode:[NSNumber numberWithShort:value_]];
}





@dynamic updatedAt;






@dynamic invitee;

	

@dynamic team;

	






@end
