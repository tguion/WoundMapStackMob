// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMTelecom.m instead.

#import "_WMTelecom.h"

const struct WMTelecomAttributes WMTelecomAttributes = {
	.createdAt = @"createdAt",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.updatedAt = @"updatedAt",
	.use = @"use",
	.value = @"value",
};

const struct WMTelecomRelationships WMTelecomRelationships = {
	.person = @"person",
	.telecomType = @"telecomType",
};

const struct WMTelecomFetchedProperties WMTelecomFetchedProperties = {
};

@implementation WMTelecomID
@end

@implementation _WMTelecom

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMTelecom" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMTelecom";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMTelecom" inManagedObjectContext:moc_];
}

- (WMTelecomID*)objectID {
	return (WMTelecomID*)[super objectID];
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





@dynamic updatedAt;






@dynamic use;






@dynamic value;






@dynamic person;

	

@dynamic telecomType;

	






@end
