// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundMeasurementTunnelValue.m instead.

#import "_WMWoundMeasurementTunnelValue.h"

const struct WMWoundMeasurementTunnelValueAttributes WMWoundMeasurementTunnelValueAttributes = {
	.fromOClockValue = @"fromOClockValue",
	.sectionTitle = @"sectionTitle",
	.sortRank = @"sortRank",
};

const struct WMWoundMeasurementTunnelValueRelationships WMWoundMeasurementTunnelValueRelationships = {
};

const struct WMWoundMeasurementTunnelValueFetchedProperties WMWoundMeasurementTunnelValueFetchedProperties = {
};

@implementation WMWoundMeasurementTunnelValueID
@end

@implementation _WMWoundMeasurementTunnelValue

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMWoundMeasurementTunnelValue" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMWoundMeasurementTunnelValue";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMWoundMeasurementTunnelValue" inManagedObjectContext:moc_];
}

- (WMWoundMeasurementTunnelValueID*)objectID {
	return (WMWoundMeasurementTunnelValueID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"fromOClockValueValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"fromOClockValue"];
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




@dynamic fromOClockValue;



- (int16_t)fromOClockValueValue {
	NSNumber *result = [self fromOClockValue];
	return [result shortValue];
}

- (void)setFromOClockValueValue:(int16_t)value_ {
	[self setFromOClockValue:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveFromOClockValueValue {
	NSNumber *result = [self primitiveFromOClockValue];
	return [result shortValue];
}

- (void)setPrimitiveFromOClockValueValue:(int16_t)value_ {
	[self setPrimitiveFromOClockValue:[NSNumber numberWithShort:value_]];
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










@end
