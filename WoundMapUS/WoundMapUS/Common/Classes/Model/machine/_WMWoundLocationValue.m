// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundLocationValue.m instead.

#import "_WMWoundLocationValue.h"

const struct WMWoundLocationValueAttributes WMWoundLocationValueAttributes = {
	.createdAt = @"createdAt",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.sortRank = @"sortRank",
	.updatedAt = @"updatedAt",
};

const struct WMWoundLocationValueRelationships WMWoundLocationValueRelationships = {
	.location = @"location",
	.wound = @"wound",
};

const struct WMWoundLocationValueFetchedProperties WMWoundLocationValueFetchedProperties = {
};

@implementation WMWoundLocationValueID
@end

@implementation _WMWoundLocationValue

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMWoundLocationValue" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMWoundLocationValue";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMWoundLocationValue" inManagedObjectContext:moc_];
}

- (WMWoundLocationValueID*)objectID {
	return (WMWoundLocationValueID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"flagsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"flags"];
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





@dynamic updatedAt;






@dynamic location;

	

@dynamic wound;

	






@end
