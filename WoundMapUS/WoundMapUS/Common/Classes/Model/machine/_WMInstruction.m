// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMInstruction.m instead.

#import "_WMInstruction.h"

const struct WMInstructionAttributes WMInstructionAttributes = {
	.contentFileExtension = @"contentFileExtension",
	.contentFileName = @"contentFileName",
	.desc = @"desc",
	.flags = @"flags",
	.iconFileName = @"iconFileName",
	.sortRank = @"sortRank",
	.title = @"title",
};

const struct WMInstructionRelationships WMInstructionRelationships = {
};

const struct WMInstructionFetchedProperties WMInstructionFetchedProperties = {
};

@implementation WMInstructionID
@end

@implementation _WMInstruction

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMInstruction" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMInstruction";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMInstruction" inManagedObjectContext:moc_];
}

- (WMInstructionID*)objectID {
	return (WMInstructionID*)[super objectID];
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




@dynamic contentFileExtension;






@dynamic contentFileName;






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





@dynamic iconFileName;






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
