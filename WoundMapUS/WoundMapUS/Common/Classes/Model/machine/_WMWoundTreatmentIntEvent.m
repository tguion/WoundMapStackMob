// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundTreatmentIntEvent.m instead.

#import "_WMWoundTreatmentIntEvent.h"

const struct WMWoundTreatmentIntEventAttributes WMWoundTreatmentIntEventAttributes = {
	.wmwoundtreatmentinterventionevent_id = @"wmwoundtreatmentinterventionevent_id",
};

const struct WMWoundTreatmentIntEventRelationships WMWoundTreatmentIntEventRelationships = {
	.treatmentGroup = @"treatmentGroup",
};

const struct WMWoundTreatmentIntEventFetchedProperties WMWoundTreatmentIntEventFetchedProperties = {
};

@implementation WMWoundTreatmentIntEventID
@end

@implementation _WMWoundTreatmentIntEvent

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMWoundTreatmentIntEvent" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMWoundTreatmentIntEvent";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMWoundTreatmentIntEvent" inManagedObjectContext:moc_];
}

- (WMWoundTreatmentIntEventID*)objectID {
	return (WMWoundTreatmentIntEventID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic wmwoundtreatmentinterventionevent_id;






@dynamic treatmentGroup;

	






@end
