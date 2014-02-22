// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWound.m instead.

#import "_WMWound.h"

const struct WMWoundAttributes WMWoundAttributes = {
	.createddate = @"createddate",
	.dateCreated = @"dateCreated",
	.desc = @"desc",
	.flags = @"flags",
	.lastmoddate = @"lastmoddate",
	.name = @"name",
	.sortRank = @"sortRank",
	.wmwound_id = @"wmwound_id",
	.woundLocationValue = @"woundLocationValue",
	.woundTypeValue = @"woundTypeValue",
};

const struct WMWoundRelationships WMWoundRelationships = {
	.patient = @"patient",
	.photos = @"photos",
	.woundType = @"woundType",
};

const struct WMWoundFetchedProperties WMWoundFetchedProperties = {
};

@implementation WMWoundID
@end

@implementation _WMWound

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMWound" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMWound";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMWound" inManagedObjectContext:moc_];
}

- (WMWoundID*)objectID {
	return (WMWoundID*)[super objectID];
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




@dynamic createddate;






@dynamic dateCreated;






@dynamic desc;






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






@dynamic name;






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





@dynamic wmwound_id;






@dynamic woundLocationValue;






@dynamic woundTypeValue;






@dynamic patient;

	

@dynamic photos;

	
- (NSMutableSet*)photosSet {
	[self willAccessValueForKey:@"photos"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"photos"];
  
	[self didAccessValueForKey:@"photos"];
	return result;
}
	

@dynamic woundType;

	






@end
