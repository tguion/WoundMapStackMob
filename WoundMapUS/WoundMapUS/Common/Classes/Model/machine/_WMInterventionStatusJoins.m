// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMInterventionStatusJoins.m instead.

#import "_WMInterventionStatusJoins.h"

const struct WMInterventionStatusJoinsAttributes WMInterventionStatusJoinsAttributes = {
};

const struct WMInterventionStatusJoinsRelationships WMInterventionStatusJoinsRelationships = {
	.fromStatus = @"fromStatus",
	.toStatus = @"toStatus",
};

const struct WMInterventionStatusJoinsFetchedProperties WMInterventionStatusJoinsFetchedProperties = {
};

@implementation WMInterventionStatusJoinsID
@end

@implementation _WMInterventionStatusJoins

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMInterventionStatusJoin" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMInterventionStatusJoin";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMInterventionStatusJoin" inManagedObjectContext:moc_];
}

- (WMInterventionStatusJoinsID*)objectID {
	return (WMInterventionStatusJoinsID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic fromStatus;

	

@dynamic toStatus;

	






@end
