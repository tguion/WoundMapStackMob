// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMPsychoSocialInterventionEvent.m instead.

#import "_WMPsychoSocialInterventionEvent.h"

const struct WMPsychoSocialInterventionEventAttributes WMPsychoSocialInterventionEventAttributes = {
	.wmpsychosocialinterventionevent_id = @"wmpsychosocialinterventionevent_id",
};

const struct WMPsychoSocialInterventionEventRelationships WMPsychoSocialInterventionEventRelationships = {
	.group = @"group",
};

const struct WMPsychoSocialInterventionEventFetchedProperties WMPsychoSocialInterventionEventFetchedProperties = {
};

@implementation WMPsychoSocialInterventionEventID
@end

@implementation _WMPsychoSocialInterventionEvent

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMPsychoSocialInterventionEvent" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMPsychoSocialInterventionEvent";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMPsychoSocialInterventionEvent" inManagedObjectContext:moc_];
}

- (WMPsychoSocialInterventionEventID*)objectID {
	return (WMPsychoSocialInterventionEventID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic wmpsychosocialinterventionevent_id;






@dynamic group;

	






@end
