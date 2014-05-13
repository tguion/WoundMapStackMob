// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMTeamPolicy.m instead.

#import "_WMTeamPolicy.h"

const struct WMTeamPolicyAttributes WMTeamPolicyAttributes = {
	.createdAt = @"createdAt",
	.deletePhotoBlobs = @"deletePhotoBlobs",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.numberOfMonthsToDeletePhotoBlobs = @"numberOfMonthsToDeletePhotoBlobs",
	.updatedAt = @"updatedAt",
};

const struct WMTeamPolicyRelationships WMTeamPolicyRelationships = {
	.team = @"team",
};

const struct WMTeamPolicyFetchedProperties WMTeamPolicyFetchedProperties = {
};

@implementation WMTeamPolicyID
@end

@implementation _WMTeamPolicy

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMTeamPolicy" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMTeamPolicy";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMTeamPolicy" inManagedObjectContext:moc_];
}

- (WMTeamPolicyID*)objectID {
	return (WMTeamPolicyID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"deletePhotoBlobsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"deletePhotoBlobs"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"flagsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"flags"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"numberOfMonthsToDeletePhotoBlobsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"numberOfMonthsToDeletePhotoBlobs"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic createdAt;






@dynamic deletePhotoBlobs;



- (BOOL)deletePhotoBlobsValue {
	NSNumber *result = [self deletePhotoBlobs];
	return [result boolValue];
}

- (void)setDeletePhotoBlobsValue:(BOOL)value_ {
	[self setDeletePhotoBlobs:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveDeletePhotoBlobsValue {
	NSNumber *result = [self primitiveDeletePhotoBlobs];
	return [result boolValue];
}

- (void)setPrimitiveDeletePhotoBlobsValue:(BOOL)value_ {
	[self setPrimitiveDeletePhotoBlobs:[NSNumber numberWithBool:value_]];
}





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





@dynamic numberOfMonthsToDeletePhotoBlobs;



- (int16_t)numberOfMonthsToDeletePhotoBlobsValue {
	NSNumber *result = [self numberOfMonthsToDeletePhotoBlobs];
	return [result shortValue];
}

- (void)setNumberOfMonthsToDeletePhotoBlobsValue:(int16_t)value_ {
	[self setNumberOfMonthsToDeletePhotoBlobs:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveNumberOfMonthsToDeletePhotoBlobsValue {
	NSNumber *result = [self primitiveNumberOfMonthsToDeletePhotoBlobs];
	return [result shortValue];
}

- (void)setPrimitiveNumberOfMonthsToDeletePhotoBlobsValue:(int16_t)value_ {
	[self setPrimitiveNumberOfMonthsToDeletePhotoBlobs:[NSNumber numberWithShort:value_]];
}





@dynamic updatedAt;






@dynamic team;

	






@end
