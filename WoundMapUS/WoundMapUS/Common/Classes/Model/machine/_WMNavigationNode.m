// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMNavigationNode.m instead.

#import "_WMNavigationNode.h"

const struct WMNavigationNodeAttributes WMNavigationNodeAttributes = {
	.activeFlag = @"activeFlag",
	.closeUnit = @"closeUnit",
	.closeValue = @"closeValue",
	.createdAt = @"createdAt",
	.desc = @"desc",
	.disabledFlag = @"disabledFlag",
	.displayTitle = @"displayTitle",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.frequencyUnit = @"frequencyUnit",
	.frequencyValue = @"frequencyValue",
	.iapIdentifier = @"iapIdentifier",
	.icon = @"icon",
	.patientFlag = @"patientFlag",
	.requiresPatientFlag = @"requiresPatientFlag",
	.requiresWoundFlag = @"requiresWoundFlag",
	.requiresWoundPhotoFlag = @"requiresWoundPhotoFlag",
	.sortRank = @"sortRank",
	.taskIdentifier = @"taskIdentifier",
	.teamFlag = @"teamFlag",
	.title = @"title",
	.updatedAt = @"updatedAt",
	.userSortRank = @"userSortRank",
	.woundFlag = @"woundFlag",
	.woundTypeCodes = @"woundTypeCodes",
};

const struct WMNavigationNodeRelationships WMNavigationNodeRelationships = {
	.parentNode = @"parentNode",
	.stage = @"stage",
	.subnodes = @"subnodes",
	.team = @"team",
};

const struct WMNavigationNodeFetchedProperties WMNavigationNodeFetchedProperties = {
};

@implementation WMNavigationNodeID
@end

@implementation _WMNavigationNode

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMNavigationNode" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMNavigationNode";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMNavigationNode" inManagedObjectContext:moc_];
}

- (WMNavigationNodeID*)objectID {
	return (WMNavigationNodeID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"activeFlagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"activeFlag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"closeUnitValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"closeUnit"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"closeValueValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"closeValue"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"disabledFlagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"disabledFlag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"flagsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"flags"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"frequencyUnitValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"frequencyUnit"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"frequencyValueValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"frequencyValue"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"patientFlagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"patientFlag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"requiresPatientFlagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"requiresPatientFlag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"requiresWoundFlagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"requiresWoundFlag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"requiresWoundPhotoFlagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"requiresWoundPhotoFlag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"sortRankValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sortRank"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"taskIdentifierValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"taskIdentifier"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"teamFlagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"teamFlag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"userSortRankValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"userSortRank"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"woundFlagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"woundFlag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic activeFlag;



- (BOOL)activeFlagValue {
	NSNumber *result = [self activeFlag];
	return [result boolValue];
}

- (void)setActiveFlagValue:(BOOL)value_ {
	[self setActiveFlag:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveActiveFlagValue {
	NSNumber *result = [self primitiveActiveFlag];
	return [result boolValue];
}

- (void)setPrimitiveActiveFlagValue:(BOOL)value_ {
	[self setPrimitiveActiveFlag:[NSNumber numberWithBool:value_]];
}





@dynamic closeUnit;



- (int16_t)closeUnitValue {
	NSNumber *result = [self closeUnit];
	return [result shortValue];
}

- (void)setCloseUnitValue:(int16_t)value_ {
	[self setCloseUnit:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveCloseUnitValue {
	NSNumber *result = [self primitiveCloseUnit];
	return [result shortValue];
}

- (void)setPrimitiveCloseUnitValue:(int16_t)value_ {
	[self setPrimitiveCloseUnit:[NSNumber numberWithShort:value_]];
}





@dynamic closeValue;



- (int16_t)closeValueValue {
	NSNumber *result = [self closeValue];
	return [result shortValue];
}

- (void)setCloseValueValue:(int16_t)value_ {
	[self setCloseValue:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveCloseValueValue {
	NSNumber *result = [self primitiveCloseValue];
	return [result shortValue];
}

- (void)setPrimitiveCloseValueValue:(int16_t)value_ {
	[self setPrimitiveCloseValue:[NSNumber numberWithShort:value_]];
}





@dynamic createdAt;






@dynamic desc;






@dynamic disabledFlag;



- (BOOL)disabledFlagValue {
	NSNumber *result = [self disabledFlag];
	return [result boolValue];
}

- (void)setDisabledFlagValue:(BOOL)value_ {
	[self setDisabledFlag:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveDisabledFlagValue {
	NSNumber *result = [self primitiveDisabledFlag];
	return [result boolValue];
}

- (void)setPrimitiveDisabledFlagValue:(BOOL)value_ {
	[self setPrimitiveDisabledFlag:[NSNumber numberWithBool:value_]];
}





@dynamic displayTitle;






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





@dynamic frequencyUnit;



- (int16_t)frequencyUnitValue {
	NSNumber *result = [self frequencyUnit];
	return [result shortValue];
}

- (void)setFrequencyUnitValue:(int16_t)value_ {
	[self setFrequencyUnit:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveFrequencyUnitValue {
	NSNumber *result = [self primitiveFrequencyUnit];
	return [result shortValue];
}

- (void)setPrimitiveFrequencyUnitValue:(int16_t)value_ {
	[self setPrimitiveFrequencyUnit:[NSNumber numberWithShort:value_]];
}





@dynamic frequencyValue;



- (int16_t)frequencyValueValue {
	NSNumber *result = [self frequencyValue];
	return [result shortValue];
}

- (void)setFrequencyValueValue:(int16_t)value_ {
	[self setFrequencyValue:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveFrequencyValueValue {
	NSNumber *result = [self primitiveFrequencyValue];
	return [result shortValue];
}

- (void)setPrimitiveFrequencyValueValue:(int16_t)value_ {
	[self setPrimitiveFrequencyValue:[NSNumber numberWithShort:value_]];
}





@dynamic iapIdentifier;






@dynamic icon;






@dynamic patientFlag;



- (BOOL)patientFlagValue {
	NSNumber *result = [self patientFlag];
	return [result boolValue];
}

- (void)setPatientFlagValue:(BOOL)value_ {
	[self setPatientFlag:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitivePatientFlagValue {
	NSNumber *result = [self primitivePatientFlag];
	return [result boolValue];
}

- (void)setPrimitivePatientFlagValue:(BOOL)value_ {
	[self setPrimitivePatientFlag:[NSNumber numberWithBool:value_]];
}





@dynamic requiresPatientFlag;



- (BOOL)requiresPatientFlagValue {
	NSNumber *result = [self requiresPatientFlag];
	return [result boolValue];
}

- (void)setRequiresPatientFlagValue:(BOOL)value_ {
	[self setRequiresPatientFlag:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveRequiresPatientFlagValue {
	NSNumber *result = [self primitiveRequiresPatientFlag];
	return [result boolValue];
}

- (void)setPrimitiveRequiresPatientFlagValue:(BOOL)value_ {
	[self setPrimitiveRequiresPatientFlag:[NSNumber numberWithBool:value_]];
}





@dynamic requiresWoundFlag;



- (BOOL)requiresWoundFlagValue {
	NSNumber *result = [self requiresWoundFlag];
	return [result boolValue];
}

- (void)setRequiresWoundFlagValue:(BOOL)value_ {
	[self setRequiresWoundFlag:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveRequiresWoundFlagValue {
	NSNumber *result = [self primitiveRequiresWoundFlag];
	return [result boolValue];
}

- (void)setPrimitiveRequiresWoundFlagValue:(BOOL)value_ {
	[self setPrimitiveRequiresWoundFlag:[NSNumber numberWithBool:value_]];
}





@dynamic requiresWoundPhotoFlag;



- (BOOL)requiresWoundPhotoFlagValue {
	NSNumber *result = [self requiresWoundPhotoFlag];
	return [result boolValue];
}

- (void)setRequiresWoundPhotoFlagValue:(BOOL)value_ {
	[self setRequiresWoundPhotoFlag:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveRequiresWoundPhotoFlagValue {
	NSNumber *result = [self primitiveRequiresWoundPhotoFlag];
	return [result boolValue];
}

- (void)setPrimitiveRequiresWoundPhotoFlagValue:(BOOL)value_ {
	[self setPrimitiveRequiresWoundPhotoFlag:[NSNumber numberWithBool:value_]];
}





@dynamic sortRank;



- (int16_t)sortRankValue {
	NSNumber *result = [self sortRank];
	return [result shortValue];
}

- (void)setSortRankValue:(int16_t)value_ {
	[self setSortRank:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveSortRankValue {
	NSNumber *result = [self primitiveSortRank];
	return [result shortValue];
}

- (void)setPrimitiveSortRankValue:(int16_t)value_ {
	[self setPrimitiveSortRank:[NSNumber numberWithShort:value_]];
}





@dynamic taskIdentifier;



- (int16_t)taskIdentifierValue {
	NSNumber *result = [self taskIdentifier];
	return [result shortValue];
}

- (void)setTaskIdentifierValue:(int16_t)value_ {
	[self setTaskIdentifier:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveTaskIdentifierValue {
	NSNumber *result = [self primitiveTaskIdentifier];
	return [result shortValue];
}

- (void)setPrimitiveTaskIdentifierValue:(int16_t)value_ {
	[self setPrimitiveTaskIdentifier:[NSNumber numberWithShort:value_]];
}





@dynamic teamFlag;



- (BOOL)teamFlagValue {
	NSNumber *result = [self teamFlag];
	return [result boolValue];
}

- (void)setTeamFlagValue:(BOOL)value_ {
	[self setTeamFlag:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveTeamFlagValue {
	NSNumber *result = [self primitiveTeamFlag];
	return [result boolValue];
}

- (void)setPrimitiveTeamFlagValue:(BOOL)value_ {
	[self setPrimitiveTeamFlag:[NSNumber numberWithBool:value_]];
}





@dynamic title;






@dynamic updatedAt;






@dynamic userSortRank;



- (int16_t)userSortRankValue {
	NSNumber *result = [self userSortRank];
	return [result shortValue];
}

- (void)setUserSortRankValue:(int16_t)value_ {
	[self setUserSortRank:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveUserSortRankValue {
	NSNumber *result = [self primitiveUserSortRank];
	return [result shortValue];
}

- (void)setPrimitiveUserSortRankValue:(int16_t)value_ {
	[self setPrimitiveUserSortRank:[NSNumber numberWithShort:value_]];
}





@dynamic woundFlag;



- (BOOL)woundFlagValue {
	NSNumber *result = [self woundFlag];
	return [result boolValue];
}

- (void)setWoundFlagValue:(BOOL)value_ {
	[self setWoundFlag:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveWoundFlagValue {
	NSNumber *result = [self primitiveWoundFlag];
	return [result boolValue];
}

- (void)setPrimitiveWoundFlagValue:(BOOL)value_ {
	[self setPrimitiveWoundFlag:[NSNumber numberWithBool:value_]];
}





@dynamic woundTypeCodes;






@dynamic parentNode;

	

@dynamic stage;

	

@dynamic subnodes;

	
- (NSMutableSet*)subnodesSet {
	[self willAccessValueForKey:@"subnodes"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"subnodes"];
  
	[self didAccessValueForKey:@"subnodes"];
	return result;
}
	

@dynamic team;

	






@end
