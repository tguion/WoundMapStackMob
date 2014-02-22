// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundPhoto.m instead.

#import "_WMWoundPhoto.h"

const struct WMWoundPhotoAttributes WMWoundPhotoAttributes = {
	.comments = @"comments",
	.dateCreated = @"dateCreated",
	.dateModified = @"dateModified",
	.flags = @"flags",
	.imageHeight = @"imageHeight",
	.imageOrientation = @"imageOrientation",
	.imageWidth = @"imageWidth",
	.metadata = @"metadata",
	.thumbnail = @"thumbnail",
	.thumbnailLarge = @"thumbnailLarge",
	.thumbnailMini = @"thumbnailMini",
	.transformAsString = @"transformAsString",
	.transformRotation = @"transformRotation",
	.transformScale = @"transformScale",
	.transformSizeAsString = @"transformSizeAsString",
	.transformTranslationX = @"transformTranslationX",
	.transformTranslationY = @"transformTranslationY",
};

const struct WMWoundPhotoRelationships WMWoundPhotoRelationships = {
	.photos = @"photos",
	.wound = @"wound",
};

const struct WMWoundPhotoFetchedProperties WMWoundPhotoFetchedProperties = {
};

@implementation WMWoundPhotoID
@end

@implementation _WMWoundPhoto

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMWoundPhoto" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMWoundPhoto";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMWoundPhoto" inManagedObjectContext:moc_];
}

- (WMWoundPhotoID*)objectID {
	return (WMWoundPhotoID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"flagsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"flags"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"imageHeightValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"imageHeight"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"imageOrientationValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"imageOrientation"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"imageWidthValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"imageWidth"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"transformRotationValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"transformRotation"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"transformScaleValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"transformScale"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"transformTranslationXValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"transformTranslationX"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"transformTranslationYValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"transformTranslationY"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic comments;






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





@dynamic imageHeight;



- (float)imageHeightValue {
	NSNumber *result = [self imageHeight];
	return [result floatValue];
}

- (void)setImageHeightValue:(float)value_ {
	[self setImageHeight:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveImageHeightValue {
	NSNumber *result = [self primitiveImageHeight];
	return [result floatValue];
}

- (void)setPrimitiveImageHeightValue:(float)value_ {
	[self setPrimitiveImageHeight:[NSNumber numberWithFloat:value_]];
}





@dynamic imageOrientation;



- (int16_t)imageOrientationValue {
	NSNumber *result = [self imageOrientation];
	return [result shortValue];
}

- (void)setImageOrientationValue:(int16_t)value_ {
	[self setImageOrientation:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveImageOrientationValue {
	NSNumber *result = [self primitiveImageOrientation];
	return [result shortValue];
}

- (void)setPrimitiveImageOrientationValue:(int16_t)value_ {
	[self setPrimitiveImageOrientation:[NSNumber numberWithShort:value_]];
}





@dynamic imageWidth;



- (float)imageWidthValue {
	NSNumber *result = [self imageWidth];
	return [result floatValue];
}

- (void)setImageWidthValue:(float)value_ {
	[self setImageWidth:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveImageWidthValue {
	NSNumber *result = [self primitiveImageWidth];
	return [result floatValue];
}

- (void)setPrimitiveImageWidthValue:(float)value_ {
	[self setPrimitiveImageWidth:[NSNumber numberWithFloat:value_]];
}





@dynamic metadata;






@dynamic thumbnail;






@dynamic thumbnailLarge;






@dynamic thumbnailMini;






@dynamic transformAsString;






@dynamic transformRotation;



- (float)transformRotationValue {
	NSNumber *result = [self transformRotation];
	return [result floatValue];
}

- (void)setTransformRotationValue:(float)value_ {
	[self setTransformRotation:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveTransformRotationValue {
	NSNumber *result = [self primitiveTransformRotation];
	return [result floatValue];
}

- (void)setPrimitiveTransformRotationValue:(float)value_ {
	[self setPrimitiveTransformRotation:[NSNumber numberWithFloat:value_]];
}





@dynamic transformScale;



- (float)transformScaleValue {
	NSNumber *result = [self transformScale];
	return [result floatValue];
}

- (void)setTransformScaleValue:(float)value_ {
	[self setTransformScale:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveTransformScaleValue {
	NSNumber *result = [self primitiveTransformScale];
	return [result floatValue];
}

- (void)setPrimitiveTransformScaleValue:(float)value_ {
	[self setPrimitiveTransformScale:[NSNumber numberWithFloat:value_]];
}





@dynamic transformSizeAsString;






@dynamic transformTranslationX;



- (float)transformTranslationXValue {
	NSNumber *result = [self transformTranslationX];
	return [result floatValue];
}

- (void)setTransformTranslationXValue:(float)value_ {
	[self setTransformTranslationX:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveTransformTranslationXValue {
	NSNumber *result = [self primitiveTransformTranslationX];
	return [result floatValue];
}

- (void)setPrimitiveTransformTranslationXValue:(float)value_ {
	[self setPrimitiveTransformTranslationX:[NSNumber numberWithFloat:value_]];
}





@dynamic transformTranslationY;



- (float)transformTranslationYValue {
	NSNumber *result = [self transformTranslationY];
	return [result floatValue];
}

- (void)setTransformTranslationYValue:(float)value_ {
	[self setTransformTranslationY:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveTransformTranslationYValue {
	NSNumber *result = [self primitiveTransformTranslationY];
	return [result floatValue];
}

- (void)setPrimitiveTransformTranslationYValue:(float)value_ {
	[self setPrimitiveTransformTranslationY:[NSNumber numberWithFloat:value_]];
}





@dynamic photos;

	
- (NSMutableSet*)photosSet {
	[self willAccessValueForKey:@"photos"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"photos"];
  
	[self didAccessValueForKey:@"photos"];
	return result;
}
	

@dynamic wound;

	






@end
