// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundTreatmentInterventionEvent.m instead.

#import "_WMWoundTreatmentInterventionEvent.h"

const struct WMWoundTreatmentInterventionEventAttributes WMWoundTreatmentInterventionEventAttributes = {
	.wmwoundtreatmentinterventionevent_id = @"wmwoundtreatmentinterventionevent_id",
};

const struct WMWoundTreatmentInterventionEventRelationships WMWoundTreatmentInterventionEventRelationships = {
	.treatmentGroup = @"treatmentGroup",
};

const struct WMWoundTreatmentInterventionEventFetchedProperties WMWoundTreatmentInterventionEventFetchedProperties = {
};

@implementation WMWoundTreatmentInterventionEventID
@end

@implementation _WMWoundTreatmentInterventionEvent

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMWoundTreatmentInterventionEvent" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMWoundTreatmentInterventionEvent";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMWoundTreatmentInterventionEvent" inManagedObjectContext:moc_];
}

- (WMWoundTreatmentInterventionEventID*)objectID {
	return (WMWoundTreatmentInterventionEventID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic wmwoundtreatmentinterventionevent_id;






@dynamic treatmentGroup;

	






@end
