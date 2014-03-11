// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMTelecomType.m instead.

#import "_WMTelecomType.h"

const struct WMTelecomTypeAttributes WMTelecomTypeAttributes = {
	.createdAt = @"createdAt",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.icon = @"icon",
	.sortRank = @"sortRank",
	.title = @"title",
	.updatedAt = @"updatedAt",
};

const struct WMTelecomTypeRelationships WMTelecomTypeRelationships = {
	.telecoms = @"telecoms",
};

const struct WMTelecomTypeFetchedProperties WMTelecomTypeFetchedProperties = {
};

@implementation WMTelecomTypeID
@end

@implementation _WMTelecomType

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMTelecomType" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMTelecomType";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMTelecomType" inManagedObjectContext:moc_];
}

- (WMTelecomTypeID*)objectID {
	return (WMTelecomTypeID*)[super objectID];
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





@dynamic icon;






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





@dynamic title;






@dynamic updatedAt;






@dynamic telecoms;

	
- (NSMutableSet*)telecomsSet {
	[self willAccessValueForKey:@"telecoms"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"telecoms"];
  
	[self didAccessValueForKey:@"telecoms"];
	return result;
}
	






@end
