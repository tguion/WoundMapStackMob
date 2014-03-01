// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMMedicationInterventionEvent.m instead.

#import "_WMMedicationInterventionEvent.h"

const struct WMMedicationInterventionEventAttributes WMMedicationInterventionEventAttributes = {
	.wmmedicationinterventionevent_id = @"wmmedicationinterventionevent_id",
};

const struct WMMedicationInterventionEventRelationships WMMedicationInterventionEventRelationships = {
	.medicationGroup = @"medicationGroup",
};

const struct WMMedicationInterventionEventFetchedProperties WMMedicationInterventionEventFetchedProperties = {
};

@implementation WMMedicationInterventionEventID
@end

@implementation _WMMedicationInterventionEvent

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMMedicationInterventionEvent" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMMedicationInterventionEvent";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMMedicationInterventionEvent" inManagedObjectContext:moc_];
}

- (WMMedicationInterventionEventID*)objectID {
	return (WMMedicationInterventionEventID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic wmmedicationinterventionevent_id;






@dynamic medicationGroup;

	






@end
