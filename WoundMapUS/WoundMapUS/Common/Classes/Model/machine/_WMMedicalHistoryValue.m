// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMMedicalHistoryValue.m instead.

#import "_WMMedicalHistoryValue.h"

const struct WMMedicalHistoryValueAttributes WMMedicalHistoryValueAttributes = {
	.createdAt = @"createdAt",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.updatedAt = @"updatedAt",
	.value = @"value",
};

const struct WMMedicalHistoryValueRelationships WMMedicalHistoryValueRelationships = {
	.medicalHistoryGroup = @"medicalHistoryGroup",
	.medicalHistoryItem = @"medicalHistoryItem",
};

const struct WMMedicalHistoryValueFetchedProperties WMMedicalHistoryValueFetchedProperties = {
};

@implementation WMMedicalHistoryValueID
@end

@implementation _WMMedicalHistoryValue

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMMedicalHistoryValue" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMMedicalHistoryValue";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMMedicalHistoryValue" inManagedObjectContext:moc_];
}

- (WMMedicalHistoryValueID*)objectID {
	return (WMMedicalHistoryValueID*)[super objectID];
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






@dynamic value;






@dynamic medicalHistoryGroup;

	

@dynamic medicalHistoryItem;

	






@end
