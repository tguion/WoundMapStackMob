// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundLocationPositionJoin.m instead.

#import "_WMWoundLocationPositionJoin.h"

const struct WMWoundLocationPositionJoinAttributes WMWoundLocationPositionJoinAttributes = {
	.createdAt = @"createdAt",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.sortRank = @"sortRank",
	.updatedAt = @"updatedAt",
};

const struct WMWoundLocationPositionJoinRelationships WMWoundLocationPositionJoinRelationships = {
	.location = @"location",
	.positions = @"positions",
};

const struct WMWoundLocationPositionJoinFetchedProperties WMWoundLocationPositionJoinFetchedProperties = {
};

@implementation WMWoundLocationPositionJoinID
@end

@implementation _WMWoundLocationPositionJoin

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMWoundLocationPositionJoin" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMWoundLocationPositionJoin";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMWoundLocationPositionJoin" inManagedObjectContext:moc_];
}

- (WMWoundLocationPositionJoinID*)objectID {
	return (WMWoundLocationPositionJoinID*)[super objectID];
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

	

@dynamic positions;

	
- (NSMutableSet*)positionsSet {
	[self willAccessValueForKey:@"positions"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"positions"];
  
	[self didAccessValueForKey:@"positions"];
	return result;
}
	






@end
