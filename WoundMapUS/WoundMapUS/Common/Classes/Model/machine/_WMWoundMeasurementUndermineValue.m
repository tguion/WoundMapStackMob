// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundMeasurementUndermineValue.m instead.

#import "_WMWoundMeasurementUndermineValue.h"

const struct WMWoundMeasurementUndermineValueAttributes WMWoundMeasurementUndermineValueAttributes = {
	.toOClockValue = @"toOClockValue",
	.wmwoundmeasurementunderminevalue_id = @"wmwoundmeasurementunderminevalue_id",
};

const struct WMWoundMeasurementUndermineValueRelationships WMWoundMeasurementUndermineValueRelationships = {
};

const struct WMWoundMeasurementUndermineValueFetchedProperties WMWoundMeasurementUndermineValueFetchedProperties = {
};

@implementation WMWoundMeasurementUndermineValueID
@end

@implementation _WMWoundMeasurementUndermineValue

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMWoundMeasurementUndermineValue" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMWoundMeasurementUndermineValue";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMWoundMeasurementUndermineValue" inManagedObjectContext:moc_];
}

- (WMWoundMeasurementUndermineValueID*)objectID {
	return (WMWoundMeasurementUndermineValueID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"toOClockValueValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"toOClockValue"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic toOClockValue;



- (int16_t)toOClockValueValue {
	NSNumber *result = [self toOClockValue];
	return [result shortValue];
}

- (void)setToOClockValueValue:(int16_t)value_ {
	[self setToOClockValue:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveToOClockValueValue {
	NSNumber *result = [self primitiveToOClockValue];
	return [result shortValue];
}

- (void)setPrimitiveToOClockValueValue:(int16_t)value_ {
	[self setPrimitiveToOClockValue:[NSNumber numberWithShort:value_]];
}





@dynamic wmwoundmeasurementunderminevalue_id;











@end
