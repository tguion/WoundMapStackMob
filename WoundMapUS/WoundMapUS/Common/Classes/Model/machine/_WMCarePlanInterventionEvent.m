// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMCarePlanInterventionEvent.m instead.

#import "_WMCarePlanInterventionEvent.h"

const struct WMCarePlanInterventionEventAttributes WMCarePlanInterventionEventAttributes = {
	.wmcareplaninterventionevent_id = @"wmcareplaninterventionevent_id",
};

const struct WMCarePlanInterventionEventRelationships WMCarePlanInterventionEventRelationships = {
	.carePlanGroup = @"carePlanGroup",
};

const struct WMCarePlanInterventionEventFetchedProperties WMCarePlanInterventionEventFetchedProperties = {
};

@implementation WMCarePlanInterventionEventID
@end

@implementation _WMCarePlanInterventionEvent

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMCarePlanInterventionEvent" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMCarePlanInterventionEvent";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMCarePlanInterventionEvent" inManagedObjectContext:moc_];
}

- (WMCarePlanInterventionEventID*)objectID {
	return (WMCarePlanInterventionEventID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic wmcareplaninterventionevent_id;






@dynamic carePlanGroup;

	






@end
