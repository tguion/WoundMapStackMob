// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMInterventionEvent.m instead.

#import "_WMInterventionEvent.h"

const struct WMInterventionEventAttributes WMInterventionEventAttributes = {
	.changeType = @"changeType",
	.createdAt = @"createdAt",
	.dateEvent = @"dateEvent",
	.datePushed = @"datePushed",
	.ffUrl = @"ffUrl",
	.path = @"path",
	.title = @"title",
	.updatedAt = @"updatedAt",
	.valueFrom = @"valueFrom",
	.valueTo = @"valueTo",
};

const struct WMInterventionEventRelationships WMInterventionEventRelationships = {
	.carePlanGroup = @"carePlanGroup",
	.deviceGroup = @"deviceGroup",
	.eventType = @"eventType",
	.medicationGroup = @"medicationGroup",
	.participant = @"participant",
	.psychoSocialGroup = @"psychoSocialGroup",
	.skinAssessmentGroup = @"skinAssessmentGroup",
};

const struct WMInterventionEventFetchedProperties WMInterventionEventFetchedProperties = {
};

@implementation WMInterventionEventID
@end

@implementation _WMInterventionEvent

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMInterventionEvent" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMInterventionEvent";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMInterventionEvent" inManagedObjectContext:moc_];
}

- (WMInterventionEventID*)objectID {
	return (WMInterventionEventID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"changeTypeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"changeType"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic changeType;



- (int16_t)changeTypeValue {
	NSNumber *result = [self changeType];
	return [result shortValue];
}

- (void)setChangeTypeValue:(int16_t)value_ {
	[self setChangeType:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveChangeTypeValue {
	NSNumber *result = [self primitiveChangeType];
	return [result shortValue];
}

- (void)setPrimitiveChangeTypeValue:(int16_t)value_ {
	[self setPrimitiveChangeType:[NSNumber numberWithShort:value_]];
}





@dynamic createdAt;






@dynamic dateEvent;






@dynamic datePushed;






@dynamic ffUrl;






@dynamic path;






@dynamic title;






@dynamic updatedAt;






@dynamic valueFrom;






@dynamic valueTo;






@dynamic carePlanGroup;

	

@dynamic deviceGroup;

	

@dynamic eventType;

	

@dynamic medicationGroup;

	

@dynamic participant;

	

@dynamic psychoSocialGroup;

	

@dynamic skinAssessmentGroup;

	






@end
