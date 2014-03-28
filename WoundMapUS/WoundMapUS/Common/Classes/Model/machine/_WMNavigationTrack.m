// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMNavigationTrack.m instead.

#import "_WMNavigationTrack.h"

const struct WMNavigationTrackAttributes WMNavigationTrackAttributes = {
	.activeFlag = @"activeFlag",
	.createdAt = @"createdAt",
	.desc = @"desc",
	.disabledFlag = @"disabledFlag",
	.displayTitle = @"displayTitle",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.icon = @"icon",
	.sortRank = @"sortRank",
	.title = @"title",
	.updatedAt = @"updatedAt",
};

const struct WMNavigationTrackRelationships WMNavigationTrackRelationships = {
	.stages = @"stages",
	.team = @"team",
};

const struct WMNavigationTrackFetchedProperties WMNavigationTrackFetchedProperties = {
};

@implementation WMNavigationTrackID
@end

@implementation _WMNavigationTrack

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMNavigationTrack" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMNavigationTrack";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMNavigationTrack" inManagedObjectContext:moc_];
}

- (WMNavigationTrackID*)objectID {
	return (WMNavigationTrackID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"activeFlagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"activeFlag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
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




@dynamic activeFlag;



- (BOOL)activeFlagValue {
	NSNumber *result = [self activeFlag];
	return [result boolValue];
}

- (void)setActiveFlagValue:(BOOL)value_ {
	[self setActiveFlag:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveActiveFlagValue {
	NSNumber *result = [self primitiveActiveFlag];
	return [result boolValue];
}

- (void)setPrimitiveActiveFlagValue:(BOOL)value_ {
	[self setPrimitiveActiveFlag:[NSNumber numberWithBool:value_]];
}





@dynamic createdAt;






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






@dynamic stages;

	
- (NSMutableSet*)stagesSet {
	[self willAccessValueForKey:@"stages"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"stages"];
  
	[self didAccessValueForKey:@"stages"];
	return result;
}
	

@dynamic team;

	






@end
