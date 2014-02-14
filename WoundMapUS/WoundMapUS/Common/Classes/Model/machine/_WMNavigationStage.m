// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMNavigationStage.m instead.

#import "_WMNavigationStage.h"

const struct WMNavigationStageAttributes WMNavigationStageAttributes = {
	.createddate = @"createddate",
	.desc = @"desc",
	.disabledFlag = @"disabledFlag",
	.displayTitle = @"displayTitle",
	.flags = @"flags",
	.icon = @"icon",
	.lastmoddate = @"lastmoddate",
	.sortRank = @"sortRank",
	.title = @"title",
	.wmnavigation_stage_id = @"wmnavigation_stage_id",
};

const struct WMNavigationStageRelationships WMNavigationStageRelationships = {
	.nodes = @"nodes",
	.patients = @"patients",
	.track = @"track",
};

const struct WMNavigationStageFetchedProperties WMNavigationStageFetchedProperties = {
};

@implementation WMNavigationStageID
@end

@implementation _WMNavigationStage

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMNavigationStage" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMNavigationStage";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMNavigationStage" inManagedObjectContext:moc_];
}

- (WMNavigationStageID*)objectID {
	return (WMNavigationStageID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"disabledFlagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"disabledFlag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
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






@dynamic desc;






@dynamic disabledFlag;



- (BOOL)disabledFlagValue {
	NSNumber *result = [self disabledFlag];
	return [result boolValue];
}

- (void)setDisabledFlagValue:(BOOL)value_ {
	[self setDisabledFlag:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveDisabledFlagValue {
	NSNumber *result = [self primitiveDisabledFlag];
	return [result boolValue];
}

- (void)setPrimitiveDisabledFlagValue:(BOOL)value_ {
	[self setPrimitiveDisabledFlag:[NSNumber numberWithBool:value_]];
}





@dynamic displayTitle;






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





@dynamic title;






@dynamic wmnavigation_stage_id;






@dynamic nodes;

	
- (NSMutableSet*)nodesSet {
	[self willAccessValueForKey:@"nodes"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"nodes"];
  
	[self didAccessValueForKey:@"nodes"];
	return result;
}
	

@dynamic patients;

	
- (NSMutableSet*)patientsSet {
	[self willAccessValueForKey:@"patients"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"patients"];
  
	[self didAccessValueForKey:@"patients"];
	return result;
}
	

@dynamic track;

	






@end
