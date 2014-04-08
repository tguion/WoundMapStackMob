// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMMedicalHistoryGroup.m instead.

#import "_WMMedicalHistoryGroup.h"

const struct WMMedicalHistoryGroupAttributes WMMedicalHistoryGroupAttributes = {
	.createdAt = @"createdAt",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.updatedAt = @"updatedAt",
};

const struct WMMedicalHistoryGroupRelationships WMMedicalHistoryGroupRelationships = {
	.patient = @"patient",
	.values = @"values",
};

const struct WMMedicalHistoryGroupFetchedProperties WMMedicalHistoryGroupFetchedProperties = {
};

@implementation WMMedicalHistoryGroupID
@end

@implementation _WMMedicalHistoryGroup

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMMedicalHistoryGroup" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMMedicalHistoryGroup";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMMedicalHistoryGroup" inManagedObjectContext:moc_];
}

- (WMMedicalHistoryGroupID*)objectID {
	return (WMMedicalHistoryGroupID*)[super objectID];
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






@dynamic patient;

	

@dynamic values;

	
- (NSMutableSet*)valuesSet {
	[self willAccessValueForKey:@"values"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"values"];
  
	[self didAccessValueForKey:@"values"];
	return result;
}
	






@end
