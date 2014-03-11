// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMBradenCare.m instead.

#import "_WMBradenCare.h"

const struct WMBradenCareAttributes WMBradenCareAttributes = {
	.desc = @"desc",
	.scoreMaximum = @"scoreMaximum",
	.scoreMinimum = @"scoreMinimum",
	.sectionTitle = @"sectionTitle",
	.sortRank = @"sortRank",
	.title = @"title",
};

const struct WMBradenCareRelationships WMBradenCareRelationships = {
};

const struct WMBradenCareFetchedProperties WMBradenCareFetchedProperties = {
};

@implementation WMBradenCareID
@end

@implementation _WMBradenCare

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMBradenCare" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMBradenCare";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMBradenCare" inManagedObjectContext:moc_];
}

- (WMBradenCareID*)objectID {
	return (WMBradenCareID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"scoreMaximumValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"scoreMaximum"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"scoreMinimumValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"scoreMinimum"];
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




@dynamic desc;






@dynamic scoreMaximum;



- (int16_t)scoreMaximumValue {
	NSNumber *result = [self scoreMaximum];
	return [result shortValue];
}

- (void)setScoreMaximumValue:(int16_t)value_ {
	[self setScoreMaximum:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveScoreMaximumValue {
	NSNumber *result = [self primitiveScoreMaximum];
	return [result shortValue];
}

- (void)setPrimitiveScoreMaximumValue:(int16_t)value_ {
	[self setPrimitiveScoreMaximum:[NSNumber numberWithShort:value_]];
}





@dynamic scoreMinimum;



- (int16_t)scoreMinimumValue {
	NSNumber *result = [self scoreMinimum];
	return [result shortValue];
}

- (void)setScoreMinimumValue:(int16_t)value_ {
	[self setScoreMinimum:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveScoreMinimumValue {
	NSNumber *result = [self primitiveScoreMinimum];
	return [result shortValue];
}

- (void)setPrimitiveScoreMinimumValue:(int16_t)value_ {
	[self setPrimitiveScoreMinimum:[NSNumber numberWithShort:value_]];
}





@dynamic sectionTitle;






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











@end
