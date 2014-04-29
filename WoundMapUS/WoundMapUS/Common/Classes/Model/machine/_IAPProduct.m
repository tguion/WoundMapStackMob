// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to IAPProduct.m instead.

#import "_IAPProduct.h"

const struct IAPProductAttributes IAPProductAttributes = {
	.desc = @"desc",
	.descHTML = @"descHTML",
	.flags = @"flags",
	.identifier = @"identifier",
	.price = @"price",
	.proposition = @"proposition",
	.purchasedFlag = @"purchasedFlag",
	.sortRank = @"sortRank",
	.title = @"title",
	.tokenCount = @"tokenCount",
	.viewTitle = @"viewTitle",
};

const struct IAPProductRelationships IAPProductRelationships = {
	.options = @"options",
	.parent = @"parent",
	.woundType = @"woundType",
};

const struct IAPProductFetchedProperties IAPProductFetchedProperties = {
};

@implementation IAPProductID
@end

@implementation _IAPProduct

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"IAPProduct" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"IAPProduct";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"IAPProduct" inManagedObjectContext:moc_];
}

- (IAPProductID*)objectID {
	return (IAPProductID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"flagsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"flags"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"purchasedFlagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"purchasedFlag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"sortRankValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sortRank"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"tokenCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"tokenCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic desc;






@dynamic descHTML;






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





@dynamic identifier;






@dynamic price;






@dynamic proposition;






@dynamic purchasedFlag;



- (BOOL)purchasedFlagValue {
	NSNumber *result = [self purchasedFlag];
	return [result boolValue];
}

- (void)setPurchasedFlagValue:(BOOL)value_ {
	[self setPurchasedFlag:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitivePurchasedFlagValue {
	NSNumber *result = [self primitivePurchasedFlag];
	return [result boolValue];
}

- (void)setPrimitivePurchasedFlagValue:(BOOL)value_ {
	[self setPrimitivePurchasedFlag:[NSNumber numberWithBool:value_]];
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





@dynamic title;






@dynamic tokenCount;



- (int16_t)tokenCountValue {
	NSNumber *result = [self tokenCount];
	return [result shortValue];
}

- (void)setTokenCountValue:(int16_t)value_ {
	[self setTokenCount:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveTokenCountValue {
	NSNumber *result = [self primitiveTokenCount];
	return [result shortValue];
}

- (void)setPrimitiveTokenCountValue:(int16_t)value_ {
	[self setPrimitiveTokenCount:[NSNumber numberWithShort:value_]];
}





@dynamic viewTitle;






@dynamic options;

	
- (NSMutableSet*)optionsSet {
	[self willAccessValueForKey:@"options"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"options"];
  
	[self didAccessValueForKey:@"options"];
	return result;
}
	

@dynamic parent;

	

@dynamic woundType;

	






@end
