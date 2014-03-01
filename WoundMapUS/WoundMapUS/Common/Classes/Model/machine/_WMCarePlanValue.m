// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMCarePlanValue.m instead.

#import "_WMCarePlanValue.h"

const struct WMCarePlanValueAttributes WMCarePlanValueAttributes = {
	.createddate = @"createddate",
	.dateCreated = @"dateCreated",
	.dateModified = @"dateModified",
	.flags = @"flags",
	.lastmoddate = @"lastmoddate",
	.revisedFlag = @"revisedFlag",
	.title = @"title",
	.value = @"value",
	.wmcareplanvalue_id = @"wmcareplanvalue_id",
};

const struct WMCarePlanValueRelationships WMCarePlanValueRelationships = {
	.category = @"category",
	.group = @"group",
	.item = @"item",
};

const struct WMCarePlanValueFetchedProperties WMCarePlanValueFetchedProperties = {
};

@implementation WMCarePlanValueID
@end

@implementation _WMCarePlanValue

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMCarePlanValue" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMCarePlanValue";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMCarePlanValue" inManagedObjectContext:moc_];
}

- (WMCarePlanValueID*)objectID {
	return (WMCarePlanValueID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"flagsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"flags"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"revisedFlagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"revisedFlag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic createddate;






@dynamic dateCreated;






@dynamic dateModified;






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






@dynamic revisedFlag;



- (BOOL)revisedFlagValue {
	NSNumber *result = [self revisedFlag];
	return [result boolValue];
}

- (void)setRevisedFlagValue:(BOOL)value_ {
	[self setRevisedFlag:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveRevisedFlagValue {
	NSNumber *result = [self primitiveRevisedFlag];
	return [result boolValue];
}

- (void)setPrimitiveRevisedFlagValue:(BOOL)value_ {
	[self setPrimitiveRevisedFlag:[NSNumber numberWithBool:value_]];
}





@dynamic title;






@dynamic value;






@dynamic wmcareplanvalue_id;






@dynamic category;

	

@dynamic group;

	

@dynamic item;

	






@end
