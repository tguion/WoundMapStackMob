// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMInterventionEvent.m instead.

#import "_WMInterventionEvent.h"

const struct WMInterventionEventAttributes WMInterventionEventAttributes = {
	.changeType = @"changeType",
	.createddate = @"createddate",
	.dateEvent = @"dateEvent",
	.datePushed = @"datePushed",
	.lastmoddate = @"lastmoddate",
	.path = @"path",
	.title = @"title",
	.valueFrom = @"valueFrom",
	.valueTo = @"valueTo",
	.wminterventionevent_id = @"wminterventionevent_id",
};

const struct WMInterventionEventRelationships WMInterventionEventRelationships = {
	.eventType = @"eventType",
	.participant = @"participant",
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





@dynamic createddate;






@dynamic dateEvent;






@dynamic datePushed;






@dynamic lastmoddate;






@dynamic path;






@dynamic title;






@dynamic valueFrom;






@dynamic valueTo;






@dynamic wminterventionevent_id;






@dynamic eventType;

	

@dynamic participant;

	






@end
