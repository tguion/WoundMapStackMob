// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMDefinitionKeyword.m instead.

#import "_WMDefinitionKeyword.h"

const struct WMDefinitionKeywordAttributes WMDefinitionKeywordAttributes = {
	.createddate = @"createddate",
	.keyword = @"keyword",
	.lastmoddate = @"lastmoddate",
	.scope = @"scope",
	.wmdefinitionkeyword_id = @"wmdefinitionkeyword_id",
};

const struct WMDefinitionKeywordRelationships WMDefinitionKeywordRelationships = {
	.definition = @"definition",
};

const struct WMDefinitionKeywordFetchedProperties WMDefinitionKeywordFetchedProperties = {
};

@implementation WMDefinitionKeywordID
@end

@implementation _WMDefinitionKeyword

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMDefinitionKeyword" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMDefinitionKeyword";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMDefinitionKeyword" inManagedObjectContext:moc_];
}

- (WMDefinitionKeywordID*)objectID {
	return (WMDefinitionKeywordID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"scopeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"scope"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic createddate;






@dynamic keyword;






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





@dynamic wmdefinitionkeyword_id;






@dynamic definition;

	






@end
