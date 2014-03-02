// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMPsychoSocialIntEvent.m instead.

#import "_WMPsychoSocialIntEvent.h"

const struct WMPsychoSocialIntEventAttributes WMPsychoSocialIntEventAttributes = {
	.wmpsychosocialinterventionevent_id = @"wmpsychosocialinterventionevent_id",
};

const struct WMPsychoSocialIntEventRelationships WMPsychoSocialIntEventRelationships = {
	.group = @"group",
};

const struct WMPsychoSocialIntEventFetchedProperties WMPsychoSocialIntEventFetchedProperties = {
};

@implementation WMPsychoSocialIntEventID
@end

@implementation _WMPsychoSocialIntEvent

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMPsychoSocialIntEvent" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMPsychoSocialIntEvent";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMPsychoSocialIntEvent" inManagedObjectContext:moc_];
}

- (WMPsychoSocialIntEventID*)objectID {
	return (WMPsychoSocialIntEventID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic wmpsychosocialinterventionevent_id;






@dynamic group;

	






@end
