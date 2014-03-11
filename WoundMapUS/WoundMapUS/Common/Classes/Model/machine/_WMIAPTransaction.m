// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMIAPTransaction.m instead.

#import "_WMIAPTransaction.h"

const struct WMIAPTransactionAttributes WMIAPTransactionAttributes = {
	.createdAt = @"createdAt",
	.credits = @"credits",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.startupCredits = @"startupCredits",
	.txnDate = @"txnDate",
	.txnId = @"txnId",
	.updatedAt = @"updatedAt",
};

const struct WMIAPTransactionRelationships WMIAPTransactionRelationships = {
};

const struct WMIAPTransactionFetchedProperties WMIAPTransactionFetchedProperties = {
};

@implementation WMIAPTransactionID
@end

@implementation _WMIAPTransaction

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMIAPTransaction" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMIAPTransaction";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMIAPTransaction" inManagedObjectContext:moc_];
}

- (WMIAPTransactionID*)objectID {
	return (WMIAPTransactionID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"creditsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"credits"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"flagsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"flags"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"startupCreditsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"startupCredits"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic createdAt;






@dynamic credits;



- (int32_t)creditsValue {
	NSNumber *result = [self credits];
	return [result intValue];
}

- (void)setCreditsValue:(int32_t)value_ {
	[self setCredits:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveCreditsValue {
	NSNumber *result = [self primitiveCredits];
	return [result intValue];
}

- (void)setPrimitiveCreditsValue:(int32_t)value_ {
	[self setPrimitiveCredits:[NSNumber numberWithInt:value_]];
}





@dynamic ffUrl;






@dynamic flags;



- (int32_t)flagsValue {
	NSNumber *result = [self flags];
	return [result intValue];
}

- (void)setFlagsValue:(int32_t)value_ {
	[self setFlags:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveFlagsValue {
	NSNumber *result = [self primitiveFlags];
	return [result intValue];
}

- (void)setPrimitiveFlagsValue:(int32_t)value_ {
	[self setPrimitiveFlags:[NSNumber numberWithInt:value_]];
}





@dynamic startupCredits;



- (BOOL)startupCreditsValue {
	NSNumber *result = [self startupCredits];
	return [result boolValue];
}

- (void)setStartupCreditsValue:(BOOL)value_ {
	[self setStartupCredits:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveStartupCreditsValue {
	NSNumber *result = [self primitiveStartupCredits];
	return [result boolValue];
}

- (void)setPrimitiveStartupCreditsValue:(BOOL)value_ {
	[self setPrimitiveStartupCredits:[NSNumber numberWithBool:value_]];
}





@dynamic txnDate;






@dynamic txnId;






@dynamic updatedAt;











@end
