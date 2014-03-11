// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMId.m instead.

#import "_WMId.h"

const struct WMIdAttributes WMIdAttributes = {
	.createdAt = @"createdAt",
	.extension = @"extension",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.root = @"root",
	.updatedAt = @"updatedAt",
};

const struct WMIdRelationships WMIdRelationships = {
	.organization = @"organization",
	.patient = @"patient",
};

const struct WMIdFetchedProperties WMIdFetchedProperties = {
};

@implementation WMIdID
@end

@implementation _WMId

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMId" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMId";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMId" inManagedObjectContext:moc_];
}

- (WMIdID*)objectID {
	return (WMIdID*)[super objectID];
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






@dynamic extension;






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





@dynamic root;






@dynamic updatedAt;






@dynamic organization;

	

@dynamic patient;

	






@end
