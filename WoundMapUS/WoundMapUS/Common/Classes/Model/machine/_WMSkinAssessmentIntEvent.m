// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMSkinAssessmentIntEvent.m instead.

#import "_WMSkinAssessmentIntEvent.h"

const struct WMSkinAssessmentIntEventAttributes WMSkinAssessmentIntEventAttributes = {
	.wmskinassessmentinterventionevent_id = @"wmskinassessmentinterventionevent_id",
};

const struct WMSkinAssessmentIntEventRelationships WMSkinAssessmentIntEventRelationships = {
	.skinAssessmentGroup = @"skinAssessmentGroup",
};

const struct WMSkinAssessmentIntEventFetchedProperties WMSkinAssessmentIntEventFetchedProperties = {
};

@implementation WMSkinAssessmentIntEventID
@end

@implementation _WMSkinAssessmentIntEvent

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMSkinAssessmentIntEvent" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMSkinAssessmentIntEvent";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMSkinAssessmentIntEvent" inManagedObjectContext:moc_];
}

- (WMSkinAssessmentIntEventID*)objectID {
	return (WMSkinAssessmentIntEventID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic wmskinassessmentinterventionevent_id;






@dynamic skinAssessmentGroup;

	






@end
