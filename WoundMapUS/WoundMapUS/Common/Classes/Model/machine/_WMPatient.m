// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMPatient.m instead.

#import "_WMPatient.h"

const struct WMPatientAttributes WMPatientAttributes = {
	.acquiredByConsultant = @"acquiredByConsultant",
	.archivedFlag = @"archivedFlag",
	.createddate = @"createddate",
	.dateCreated = @"dateCreated",
	.dateModified = @"dateModified",
	.dateOfBirth = @"dateOfBirth",
	.flags = @"flags",
	.gender = @"gender",
	.lastmoddate = @"lastmoddate",
	.patientStatusMessages = @"patientStatusMessages",
	.sm_owner = @"sm_owner",
	.thumbnail = @"thumbnail",
	.wmpatient_id = @"wmpatient_id",
};

const struct WMPatientRelationships WMPatientRelationships = {
	.ids = @"ids",
	.patientConsultants = @"patientConsultants",
	.person = @"person",
	.stage = @"stage",
};

const struct WMPatientFetchedProperties WMPatientFetchedProperties = {
};

@implementation WMPatientID
@end

@implementation _WMPatient

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMPatient" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMPatient";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMPatient" inManagedObjectContext:moc_];
}

- (WMPatientID*)objectID {
	return (WMPatientID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"acquiredByConsultantValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"acquiredByConsultant"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"archivedFlagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"archivedFlag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"flagsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"flags"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic acquiredByConsultant;



- (BOOL)acquiredByConsultantValue {
	NSNumber *result = [self acquiredByConsultant];
	return [result boolValue];
}

- (void)setAcquiredByConsultantValue:(BOOL)value_ {
	[self setAcquiredByConsultant:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveAcquiredByConsultantValue {
	NSNumber *result = [self primitiveAcquiredByConsultant];
	return [result boolValue];
}

- (void)setPrimitiveAcquiredByConsultantValue:(BOOL)value_ {
	[self setPrimitiveAcquiredByConsultant:[NSNumber numberWithBool:value_]];
}





@dynamic archivedFlag;



- (BOOL)archivedFlagValue {
	NSNumber *result = [self archivedFlag];
	return [result boolValue];
}

- (void)setArchivedFlagValue:(BOOL)value_ {
	[self setArchivedFlag:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveArchivedFlagValue {
	NSNumber *result = [self primitiveArchivedFlag];
	return [result boolValue];
}

- (void)setPrimitiveArchivedFlagValue:(BOOL)value_ {
	[self setPrimitiveArchivedFlag:[NSNumber numberWithBool:value_]];
}





@dynamic createddate;






@dynamic dateCreated;






@dynamic dateModified;






@dynamic dateOfBirth;






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





@dynamic gender;






@dynamic lastmoddate;






@dynamic patientStatusMessages;






@dynamic sm_owner;






@dynamic thumbnail;






@dynamic wmpatient_id;






@dynamic ids;

	
- (NSMutableSet*)idsSet {
	[self willAccessValueForKey:@"ids"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"ids"];
  
	[self didAccessValueForKey:@"ids"];
	return result;
}
	

@dynamic patientConsultants;

	
- (NSMutableSet*)patientConsultantsSet {
	[self willAccessValueForKey:@"patientConsultants"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"patientConsultants"];
  
	[self didAccessValueForKey:@"patientConsultants"];
	return result;
}
	

@dynamic person;

	

@dynamic stage;

	






@end
