// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMPatientReferral.m instead.

#import "_WMPatientReferral.h"

const struct WMPatientReferralAttributes WMPatientReferralAttributes = {
	.createdAt = @"createdAt",
	.dateAccepted = @"dateAccepted",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.message = @"message",
	.updatedAt = @"updatedAt",
};

const struct WMPatientReferralRelationships WMPatientReferralRelationships = {
	.patient = @"patient",
	.referree = @"referree",
	.referrer = @"referrer",
};

const struct WMPatientReferralFetchedProperties WMPatientReferralFetchedProperties = {
};

@implementation WMPatientReferralID
@end

@implementation _WMPatientReferral

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMPatientReferral" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMPatientReferral";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMPatientReferral" inManagedObjectContext:moc_];
}

- (WMPatientReferralID*)objectID {
	return (WMPatientReferralID*)[super objectID];
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






@dynamic dateAccepted;






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





@dynamic message;






@dynamic updatedAt;






@dynamic patient;

	

@dynamic referree;

	

@dynamic referrer;

	






@end
