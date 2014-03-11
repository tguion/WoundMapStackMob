// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMSkinAssessmentValue.m instead.

#import "_WMSkinAssessmentValue.h"

const struct WMSkinAssessmentValueAttributes WMSkinAssessmentValueAttributes = {
	.createdAt = @"createdAt",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.title = @"title",
	.updatedAt = @"updatedAt",
	.value = @"value",
};

const struct WMSkinAssessmentValueRelationships WMSkinAssessmentValueRelationships = {
	.group = @"group",
	.skinAssessment = @"skinAssessment",
};

const struct WMSkinAssessmentValueFetchedProperties WMSkinAssessmentValueFetchedProperties = {
};

@implementation WMSkinAssessmentValueID
@end

@implementation _WMSkinAssessmentValue

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMSkinAssessmentValue" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMSkinAssessmentValue";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMSkinAssessmentValue" inManagedObjectContext:moc_];
}

- (WMSkinAssessmentValueID*)objectID {
	return (WMSkinAssessmentValueID*)[super objectID];
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





@dynamic title;






@dynamic updatedAt;






@dynamic value;






@dynamic group;

	

@dynamic skinAssessment;

	






@end
