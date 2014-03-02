// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMDeviceInterventionEvent.m instead.

#import "_WMDeviceInterventionEvent.h"

const struct WMDeviceInterventionEventAttributes WMDeviceInterventionEventAttributes = {
	.wmdeviceinterventionevent_id = @"wmdeviceinterventionevent_id",
};

const struct WMDeviceInterventionEventRelationships WMDeviceInterventionEventRelationships = {
	.deviceGroup = @"deviceGroup",
};

const struct WMDeviceInterventionEventFetchedProperties WMDeviceInterventionEventFetchedProperties = {
};

@implementation WMDeviceInterventionEventID
@end

@implementation _WMDeviceInterventionEvent

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMDeviceInterventionEvent" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMDeviceInterventionEvent";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMDeviceInterventionEvent" inManagedObjectContext:moc_];
}

- (WMDeviceInterventionEventID*)objectID {
	return (WMDeviceInterventionEventID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic wmdeviceinterventionevent_id;






@dynamic deviceGroup;

	






@end
