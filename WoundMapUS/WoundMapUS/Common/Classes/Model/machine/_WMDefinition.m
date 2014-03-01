// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMDefinition.m instead.

#import "_WMDefinition.h"

const struct WMDefinitionAttributes WMDefinitionAttributes = {
	.createddate = @"createddate",
	.definition = @"definition",
	.lastmoddate = @"lastmoddate",
	.scope = @"scope",
	.sortRank = @"sortRank",
	.term = @"term",
	.wmdefinition_id = @"wmdefinition_id",
};

const struct WMDefinitionRelationships WMDefinitionRelationships = {
	.keywords = @"keywords",
};

const struct WMDefinitionFetchedProperties WMDefinitionFetchedProperties = {
};

@implementation WMDefinitionID
@end

@implementation _WMDefinition

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMDefinition" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMDefinition";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMDefinition" inManagedObjectContext:moc_];
}

- (WMDefinitionID*)objectID {
	return (WMDefinitionID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"scopeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"scope"];
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






@dynamic definition;






@dynamic lastmoddate;






@dynamic scope;



- (int16_t)scopeValue {
	NSNumber *result = [self scope];
	return [result shortValue];
}

- (void)setScopeValue:(int16_t)value_ {
	[self setScope:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveScopeValue {
	NSNumber *result = [self primitiveScope];
	return [result shortValue];
}

- (void)setPrimitiveScopeValue:(int16_t)value_ {
	[self setPrimitiveScope:[NSNumber numberWithShort:value_]];
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





@dynamic term;






@dynamic wmdefinition_id;






@dynamic keywords;

	
- (NSMutableSet*)keywordsSet {
	[self willAccessValueForKey:@"keywords"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"keywords"];
  
	[self didAccessValueForKey:@"keywords"];
	return result;
}
	






@end
