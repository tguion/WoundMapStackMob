// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWound.m instead.

#import "_WMWound.h"

const struct WMWoundAttributes WMWoundAttributes = {
	.createdAt = @"createdAt",
	.desc = @"desc",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.history = @"history",
	.name = @"name",
	.sortRank = @"sortRank",
	.updatedAt = @"updatedAt",
	.woundLocationValue = @"woundLocationValue",
	.woundTypeValue = @"woundTypeValue",
};

const struct WMWoundRelationships WMWoundRelationships = {
	.locationValue = @"locationValue",
	.measurementGroups = @"measurementGroups",
	.patient = @"patient",
	.photos = @"photos",
	.positionValues = @"positionValues",
	.treatmentGroups = @"treatmentGroups",
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




@dynamic createdAt;






@dynamic desc;






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





@dynamic history;






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





@dynamic updatedAt;






@dynamic woundLocationValue;






@dynamic woundTypeValue;






@dynamic locationValue;

	

@dynamic measurementGroups;

	
- (NSMutableSet*)measurementGroupsSet {
	[self willAccessValueForKey:@"measurementGroups"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"measurementGroups"];
  
	[self didAccessValueForKey:@"measurementGroups"];
	return result;
}
	

@dynamic patient;

	

@dynamic photos;

	
- (NSMutableSet*)photosSet {
	[self willAccessValueForKey:@"photos"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"photos"];
  
	[self didAccessValueForKey:@"photos"];
	return result;
}
	

@dynamic positionValues;

	
- (NSMutableSet*)positionValuesSet {
	[self willAccessValueForKey:@"positionValues"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"positionValues"];
  
	[self didAccessValueForKey:@"positionValues"];
	return result;
}
	

@dynamic treatmentGroups;

	
- (NSMutableSet*)treatmentGroupsSet {
	[self willAccessValueForKey:@"treatmentGroups"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"treatmentGroups"];
  
	[self didAccessValueForKey:@"treatmentGroups"];
	return result;
}
	

@dynamic woundType;

	






@end
