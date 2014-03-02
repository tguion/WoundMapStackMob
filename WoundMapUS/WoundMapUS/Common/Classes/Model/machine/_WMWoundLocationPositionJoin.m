// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundLocationPositionJoin.m instead.

#import "_WMWoundLocationPositionJoin.h"

const struct WMWoundLocationPositionJoinAttributes WMWoundLocationPositionJoinAttributes = {
	.createddate = @"createddate",
	.lastmoddate = @"lastmoddate",
	.sortRank = @"sortRank",
	.wmwoundlocationpositionjoin_id = @"wmwoundlocationpositionjoin_id",
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
	
	if ([key isEqualToString:@"sortRankValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sortRank"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic createddate;






@dynamic lastmoddate;






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





@dynamic wmwoundlocationpositionjoin_id;






@dynamic location;

	

@dynamic positions;

	
- (NSMutableSet*)positionsSet {
	[self willAccessValueForKey:@"positions"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"positions"];
  
	[self didAccessValueForKey:@"positions"];
	return result;
}
	






@end
