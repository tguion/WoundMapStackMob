// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMInterventionStatus.m instead.

#import "_WMInterventionStatus.h"

const struct WMInterventionStatusAttributes WMInterventionStatusAttributes = {
	.activeFlag = @"activeFlag",
	.createddate = @"createddate",
	.definition = @"definition",
	.flags = @"flags",
	.lastmoddate = @"lastmoddate",
	.loincCode = @"loincCode",
	.snomedCID = @"snomedCID",
	.snomedFSN = @"snomedFSN",
	.sortRank = @"sortRank",
	.title = @"title",
	.wminterventionstatus_id = @"wminterventionstatus_id",
};

const struct WMInterventionStatusRelationships WMInterventionStatusRelationships = {
	.carePlanGroups = @"carePlanGroups",
	.deviceGroups = @"deviceGroups",
	.fromStatusJoins = @"fromStatusJoins",
	.measurementGroups = @"measurementGroups",
	.medicationGroups = @"medicationGroups",
	.psychoSocialGroups = @"psychoSocialGroups",
	.skinAssessmentGroups = @"skinAssessmentGroups",
	.toStatusJoins = @"toStatusJoins",
	.treatmentGroups = @"treatmentGroups",
};

const struct WMInterventionStatusFetchedProperties WMInterventionStatusFetchedProperties = {
};

@implementation WMInterventionStatusID
@end

@implementation _WMInterventionStatus

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMInterventionStatus" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMInterventionStatus";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMInterventionStatus" inManagedObjectContext:moc_];
}

- (WMInterventionStatusID*)objectID {
	return (WMInterventionStatusID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"activeFlagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"activeFlag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"flagsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"flags"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"snomedCIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"snomedCID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"sortRankValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sortRank"];
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





@dynamic createddate;






@dynamic definition;






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





@dynamic lastmoddate;






@dynamic loincCode;






@dynamic snomedCID;



- (int64_t)snomedCIDValue {
	NSNumber *result = [self snomedCID];
	return [result longLongValue];
}

- (void)setSnomedCIDValue:(int64_t)value_ {
	[self setSnomedCID:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveSnomedCIDValue {
	NSNumber *result = [self primitiveSnomedCID];
	return [result longLongValue];
}

- (void)setPrimitiveSnomedCIDValue:(int64_t)value_ {
	[self setPrimitiveSnomedCID:[NSNumber numberWithLongLong:value_]];
}





@dynamic snomedFSN;






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





@dynamic title;






@dynamic wminterventionstatus_id;






@dynamic carePlanGroups;

	
- (NSMutableSet*)carePlanGroupsSet {
	[self willAccessValueForKey:@"carePlanGroups"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"carePlanGroups"];
  
	[self didAccessValueForKey:@"carePlanGroups"];
	return result;
}
	

@dynamic deviceGroups;

	
- (NSMutableSet*)deviceGroupsSet {
	[self willAccessValueForKey:@"deviceGroups"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"deviceGroups"];
  
	[self didAccessValueForKey:@"deviceGroups"];
	return result;
}
	

@dynamic fromStatusJoins;

	
- (NSMutableSet*)fromStatusJoinsSet {
	[self willAccessValueForKey:@"fromStatusJoins"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"fromStatusJoins"];
  
	[self didAccessValueForKey:@"fromStatusJoins"];
	return result;
}
	

@dynamic measurementGroups;

	
- (NSMutableSet*)measurementGroupsSet {
	[self willAccessValueForKey:@"measurementGroups"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"measurementGroups"];
  
	[self didAccessValueForKey:@"measurementGroups"];
	return result;
}
	

@dynamic medicationGroups;

	
- (NSMutableSet*)medicationGroupsSet {
	[self willAccessValueForKey:@"medicationGroups"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"medicationGroups"];
  
	[self didAccessValueForKey:@"medicationGroups"];
	return result;
}
	

@dynamic psychoSocialGroups;

	
- (NSMutableSet*)psychoSocialGroupsSet {
	[self willAccessValueForKey:@"psychoSocialGroups"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"psychoSocialGroups"];
  
	[self didAccessValueForKey:@"psychoSocialGroups"];
	return result;
}
	

@dynamic skinAssessmentGroups;

	
- (NSMutableSet*)skinAssessmentGroupsSet {
	[self willAccessValueForKey:@"skinAssessmentGroups"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"skinAssessmentGroups"];
  
	[self didAccessValueForKey:@"skinAssessmentGroups"];
	return result;
}
	

@dynamic toStatusJoins;

	
- (NSMutableSet*)toStatusJoinsSet {
	[self willAccessValueForKey:@"toStatusJoins"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"toStatusJoins"];
  
	[self didAccessValueForKey:@"toStatusJoins"];
	return result;
}
	

@dynamic treatmentGroups;

	
- (NSMutableSet*)treatmentGroupsSet {
	[self willAccessValueForKey:@"treatmentGroups"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"treatmentGroups"];
  
	[self didAccessValueForKey:@"treatmentGroups"];
	return result;
}
	






@end
