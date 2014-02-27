// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMBradenSection.m instead.

#import "_WMBradenSection.h"

const struct WMBradenSectionAttributes WMBradenSectionAttributes = {
	.createddate = @"createddate",
	.desc = @"desc",
	.lastmoddate = @"lastmoddate",
	.sortRank = @"sortRank",
	.title = @"title",
	.wmbradensection_id = @"wmbradensection_id",
};

const struct WMBradenSectionRelationships WMBradenSectionRelationships = {
	.bradenScale = @"bradenScale",
	.cells = @"cells",
};

const struct WMBradenSectionFetchedProperties WMBradenSectionFetchedProperties = {
};

@implementation WMBradenSectionID
@end

@implementation _WMBradenSection

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMBradenSection" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMBradenSection";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMBradenSection" inManagedObjectContext:moc_];
}

- (WMBradenSectionID*)objectID {
	return (WMBradenSectionID*)[super objectID];
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






@dynamic desc;






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






@dynamic wmbradensection_id;






@dynamic bradenScale;

	

@dynamic cells;

	
- (NSMutableSet*)cellsSet {
	[self willAccessValueForKey:@"cells"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"cells"];
  
	[self didAccessValueForKey:@"cells"];
	return result;
}
	






@end
