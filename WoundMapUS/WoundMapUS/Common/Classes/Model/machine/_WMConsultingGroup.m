// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMConsultingGroup.m instead.

#import "_WMConsultingGroup.h"

const struct WMConsultingGroupAttributes WMConsultingGroupAttributes = {
	.createdAt = @"createdAt",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.name = @"name",
	.updatedAt = @"updatedAt",
};

const struct WMConsultingGroupRelationships WMConsultingGroupRelationships = {
	.team = @"team",
};

const struct WMConsultingGroupFetchedProperties WMConsultingGroupFetchedProperties = {
};

@implementation WMConsultingGroupID
@end

@implementation _WMConsultingGroup

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMConsultingGroup" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMConsultingGroup";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMConsultingGroup" inManagedObjectContext:moc_];
}

- (WMConsultingGroupID*)objectID {
	return (WMConsultingGroupID*)[super objectID];
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





@dynamic name;






@dynamic updatedAt;






@dynamic team;

	






@end
