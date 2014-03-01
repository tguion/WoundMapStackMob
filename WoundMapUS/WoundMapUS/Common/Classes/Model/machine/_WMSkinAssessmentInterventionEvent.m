// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMSkinAssessmentInterventionEvent.m instead.

#import "_WMSkinAssessmentInterventionEvent.h"

const struct WMSkinAssessmentInterventionEventAttributes WMSkinAssessmentInterventionEventAttributes = {
	.wmskinassessmentinterventionevent_id = @"wmskinassessmentinterventionevent_id",
};

const struct WMSkinAssessmentInterventionEventRelationships WMSkinAssessmentInterventionEventRelationships = {
	.skinAssessmentGroup = @"skinAssessmentGroup",
};

const struct WMSkinAssessmentInterventionEventFetchedProperties WMSkinAssessmentInterventionEventFetchedProperties = {
};

@implementation WMSkinAssessmentInterventionEventID
@end

@implementation _WMSkinAssessmentInterventionEvent

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMSkinAssessmentInterventionEvent" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMSkinAssessmentInterventionEvent";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMSkinAssessmentInterventionEvent" inManagedObjectContext:moc_];
}

- (WMSkinAssessmentInterventionEventID*)objectID {
	return (WMSkinAssessmentInterventionEventID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic wmskinassessmentinterventionevent_id;






@dynamic skinAssessmentGroup;

	






@end
