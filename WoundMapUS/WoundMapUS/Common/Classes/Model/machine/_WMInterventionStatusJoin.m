// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMInterventionStatusJoin.m instead.

#import "_WMInterventionStatusJoin.h"

const struct WMInterventionStatusJoinAttributes WMInterventionStatusJoinAttributes = {
	.createdAt = @"createdAt",
	.ffUrl = @"ffUrl",
	.updatedAt = @"updatedAt",
};

const struct WMInterventionStatusJoinRelationships WMInterventionStatusJoinRelationships = {
	.fromStatus = @"fromStatus",
	.toStatus = @"toStatus",
};

const struct WMInterventionStatusJoinFetchedProperties WMInterventionStatusJoinFetchedProperties = {
};

@implementation WMInterventionStatusJoinID
@end

@implementation _WMInterventionStatusJoin

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

- (WMInterventionStatusJoinID*)objectID {
	return (WMInterventionStatusJoinID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic createdAt;






@dynamic ffUrl;






@dynamic updatedAt;






@dynamic fromStatus;

	

@dynamic toStatus;

	






@end
