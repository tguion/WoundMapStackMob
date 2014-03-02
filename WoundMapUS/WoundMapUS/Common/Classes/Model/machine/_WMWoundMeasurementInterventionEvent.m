// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundMeasurementInterventionEvent.m instead.

#import "_WMWoundMeasurementInterventionEvent.h"

const struct WMWoundMeasurementInterventionEventAttributes WMWoundMeasurementInterventionEventAttributes = {
};

const struct WMWoundMeasurementInterventionEventRelationships WMWoundMeasurementInterventionEventRelationships = {
	.measurementGroup = @"measurementGroup",
};

const struct WMWoundMeasurementInterventionEventFetchedProperties WMWoundMeasurementInterventionEventFetchedProperties = {
};

@implementation WMWoundMeasurementInterventionEventID
@end

@implementation _WMWoundMeasurementInterventionEvent

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMWoundMeasurementInterventionEvent" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMWoundMeasurementInterventionEvent";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMWoundMeasurementInterventionEvent" inManagedObjectContext:moc_];
}

- (WMWoundMeasurementInterventionEventID*)objectID {
	return (WMWoundMeasurementInterventionEventID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic measurementGroup;

	






@end
