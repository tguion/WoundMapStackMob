// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMNutritionValue.m instead.

#import "_WMNutritionValue.h"

const struct WMNutritionValueAttributes WMNutritionValueAttributes = {
	.createdAt = @"createdAt",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.title = @"title",
	.updatedAt = @"updatedAt",
	.value = @"value",
};

const struct WMNutritionValueRelationships WMNutritionValueRelationships = {
	.item = @"item",
	.nutritionGroup = @"nutritionGroup",
};

const struct WMNutritionValueFetchedProperties WMNutritionValueFetchedProperties = {
};

@implementation WMNutritionValueID
@end

@implementation _WMNutritionValue

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMNutritionValue" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMNutritionValue";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMNutritionValue" inManagedObjectContext:moc_];
}

- (WMNutritionValueID*)objectID {
	return (WMNutritionValueID*)[super objectID];
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






@dynamic item;

	

@dynamic nutritionGroup;

	






@end
