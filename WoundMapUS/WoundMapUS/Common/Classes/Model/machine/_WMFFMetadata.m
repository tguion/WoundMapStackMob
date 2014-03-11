// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMFFMetadata.m instead.

#import "_WMFFMetadata.h"

const struct WMFFMetadataAttributes WMFFMetadataAttributes = {
	.createdAt = @"createdAt",
	.createdBy = @"createdBy",
	.ffRL = @"ffRL",
	.ffUrl = @"ffUrl",
	.ffUserCanEdit = @"ffUserCanEdit",
	.guid = @"guid",
	.objVersion = @"objVersion",
	.updatedAt = @"updatedAt",
	.updatedBy = @"updatedBy",
};

const struct WMFFMetadataRelationships WMFFMetadataRelationships = {
};

const struct WMFFMetadataFetchedProperties WMFFMetadataFetchedProperties = {
};

@implementation WMFFMetadataID
@end

@implementation _WMFFMetadata

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMFFMetadata" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMFFMetadata";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMFFMetadata" inManagedObjectContext:moc_];
}

- (WMFFMetadataID*)objectID {
	return (WMFFMetadataID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"ffUserCanEditValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"ffUserCanEdit"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"objVersionValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"objVersion"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic createdAt;






@dynamic createdBy;






@dynamic ffRL;






@dynamic ffUrl;






@dynamic ffUserCanEdit;



- (BOOL)ffUserCanEditValue {
	NSNumber *result = [self ffUserCanEdit];
	return [result boolValue];
}

- (void)setFfUserCanEditValue:(BOOL)value_ {
	[self setFfUserCanEdit:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveFfUserCanEditValue {
	NSNumber *result = [self primitiveFfUserCanEdit];
	return [result boolValue];
}

- (void)setPrimitiveFfUserCanEditValue:(BOOL)value_ {
	[self setPrimitiveFfUserCanEdit:[NSNumber numberWithBool:value_]];
}





@dynamic guid;






@dynamic objVersion;



- (int16_t)objVersionValue {
	NSNumber *result = [self objVersion];
	return [result shortValue];
}

- (void)setObjVersionValue:(int16_t)value_ {
	[self setObjVersion:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveObjVersionValue {
	NSNumber *result = [self primitiveObjVersion];
	return [result shortValue];
}

- (void)setPrimitiveObjVersionValue:(int16_t)value_ {
	[self setPrimitiveObjVersion:[NSNumber numberWithShort:value_]];
}





@dynamic updatedAt;






@dynamic updatedBy;











@end
