// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMUnhandledSilentUpdateNotification.m instead.

#import "_WMUnhandledSilentUpdateNotification.h"

const struct WMUnhandledSilentUpdateNotificationAttributes WMUnhandledSilentUpdateNotificationAttributes = {
	.notification = @"notification",
	.userNamme = @"userNamme",
};

const struct WMUnhandledSilentUpdateNotificationRelationships WMUnhandledSilentUpdateNotificationRelationships = {
};

const struct WMUnhandledSilentUpdateNotificationFetchedProperties WMUnhandledSilentUpdateNotificationFetchedProperties = {
};

@implementation WMUnhandledSilentUpdateNotificationID
@end

@implementation _WMUnhandledSilentUpdateNotification

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMUnhandledSilentUpdateNotification" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMUnhandledSilentUpdateNotification";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMUnhandledSilentUpdateNotification" inManagedObjectContext:moc_];
}

- (WMUnhandledSilentUpdateNotificationID*)objectID {
	return (WMUnhandledSilentUpdateNotificationID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic notification;






@dynamic userNamme;











@end
