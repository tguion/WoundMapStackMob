// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMPsychoSocialValue.m instead.

#import "_WMPsychoSocialValue.h"

const struct WMPsychoSocialValueAttributes WMPsychoSocialValueAttributes = {
	.createdAt = @"createdAt",
	.datePushed = @"datePushed",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.revisedFlag = @"revisedFlag",
	.title = @"title",
	.updatedAt = @"updatedAt",
	.value = @"value",
};

const struct WMPsychoSocialValueRelationships WMPsychoSocialValueRelationships = {
	.group = @"group",
	.psychoSocialItem = @"psychoSocialItem",
};

const struct WMPsychoSocialValueFetchedProperties WMPsychoSocialValueFetchedProperties = {
};

@implementation WMPsychoSocialValueID
@end

@implementation _WMPsychoSocialValue

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMPsychoSocialValue" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMPsychoSocialValue";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMPsychoSocialValue" inManagedObjectContext:moc_];
}

- (WMPsychoSocialValueID*)objectID {
	return (WMPsychoSocialValueID*)[super objectID];
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




@dynamic createdAt;






@dynamic datePushed;






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






@dynamic updatedAt;






@dynamic value;






@dynamic group;

	

@dynamic psychoSocialItem;

	






@end
