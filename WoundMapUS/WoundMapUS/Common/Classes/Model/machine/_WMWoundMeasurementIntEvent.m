// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundMeasurementIntEvent.m instead.

#import "_WMWoundMeasurementIntEvent.h"

const struct WMWoundMeasurementIntEventAttributes WMWoundMeasurementIntEventAttributes = {
	.wmwoundmeasurementinterventionevent_id = @"wmwoundmeasurementinterventionevent_id",
};

const struct WMWoundMeasurementIntEventRelationships WMWoundMeasurementIntEventRelationships = {
	.measurementGroup = @"measurementGroup",
};

const struct WMWoundMeasurementIntEventFetchedProperties WMWoundMeasurementIntEventFetchedProperties = {
};

@implementation WMWoundMeasurementIntEventID
@end

@implementation _WMWoundMeasurementIntEvent

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMWoundMeasurementIntEvent" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMWoundMeasurementIntEvent";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMWoundMeasurementIntEvent" inManagedObjectContext:moc_];
}

- (WMWoundMeasurementIntEventID*)objectID {
	return (WMWoundMeasurementIntEventID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic wmwoundmeasurementinterventionevent_id;






@dynamic measurementGroup;

	






@end
