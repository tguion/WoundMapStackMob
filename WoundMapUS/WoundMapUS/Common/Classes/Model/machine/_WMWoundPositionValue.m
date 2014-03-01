// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundPositionValue.m instead.

#import "_WMWoundPositionValue.h"

const struct WMWoundPositionValueAttributes WMWoundPositionValueAttributes = {
	.createddate = @"createddate",
	.dateCreated = @"dateCreated",
	.dateModified = @"dateModified",
	.flags = @"flags",
	.lastmoddate = @"lastmoddate",
	.title = @"title",
	.value = @"value",
	.wmwoundpositionvalue_id = @"wmwoundpositionvalue_id",
};

const struct WMWoundPositionValueRelationships WMWoundPositionValueRelationships = {
	.wound = @"wound",
	.woundPosition = @"woundPosition",
};

const struct WMWoundPositionValueFetchedProperties WMWoundPositionValueFetchedProperties = {
};

@implementation WMWoundPositionValueID
@end

@implementation _WMWoundPositionValue

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMWoundPositionValue" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMWoundPositionValue";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMWoundPositionValue" inManagedObjectContext:moc_];
}

- (WMWoundPositionValueID*)objectID {
	return (WMWoundPositionValueID*)[super objectID];
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






@dynamic title;






@dynamic value;






@dynamic wmwoundpositionvalue_id;






@dynamic wound;

	

@dynamic woundPosition;

	






@end
