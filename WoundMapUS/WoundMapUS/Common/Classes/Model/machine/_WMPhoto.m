// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMPhoto.m instead.

#import "_WMPhoto.h"

const struct WMPhotoAttributes WMPhotoAttributes = {
	.createddate = @"createddate",
	.flags = @"flags",
	.lastmoddate = @"lastmoddate",
	.originalFlag = @"originalFlag",
	.photo = @"photo",
	.scale = @"scale",
	.sortRank = @"sortRank",
	.wmphoto_id = @"wmphoto_id",
};

const struct WMPhotoRelationships WMPhotoRelationships = {
	.woundPhoto = @"woundPhoto",
};

const struct WMPhotoFetchedProperties WMPhotoFetchedProperties = {
};

@implementation WMPhotoID
@end

@implementation _WMPhoto

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMPhoto" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMPhoto";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMPhoto" inManagedObjectContext:moc_];
}

- (WMPhotoID*)objectID {
	return (WMPhotoID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"flagsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"flags"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"originalFlagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"originalFlag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"scaleValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"scale"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"sortRankValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sortRank"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic createddate;






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






@dynamic originalFlag;



- (BOOL)originalFlagValue {
	NSNumber *result = [self originalFlag];
	return [result boolValue];
}

- (void)setOriginalFlagValue:(BOOL)value_ {
	[self setOriginalFlag:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveOriginalFlagValue {
	NSNumber *result = [self primitiveOriginalFlag];
	return [result boolValue];
}

- (void)setPrimitiveOriginalFlagValue:(BOOL)value_ {
	[self setPrimitiveOriginalFlag:[NSNumber numberWithBool:value_]];
}





@dynamic photo;






@dynamic scale;



- (int16_t)scaleValue {
	NSNumber *result = [self scale];
	return [result shortValue];
}

- (void)setScaleValue:(int16_t)value_ {
	[self setScale:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveScaleValue {
	NSNumber *result = [self primitiveScale];
	return [result shortValue];
}

- (void)setPrimitiveScaleValue:(int16_t)value_ {
	[self setPrimitiveScale:[NSNumber numberWithShort:value_]];
}





@dynamic sortRank;



- (int16_t)sortRankValue {
	NSNumber *result = [self sortRank];
	return [result shortValue];
}

- (void)setSortRankValue:(int16_t)value_ {
	[self setSortRank:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveSortRankValue {
	NSNumber *result = [self primitiveSortRank];
	return [result shortValue];
}

- (void)setPrimitiveSortRankValue:(int16_t)value_ {
	[self setPrimitiveSortRank:[NSNumber numberWithShort:value_]];
}





@dynamic wmphoto_id;






@dynamic woundPhoto;

	






@end
