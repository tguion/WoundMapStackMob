// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMPaymentTransaction.m instead.

#import "_WMPaymentTransaction.h"

const struct WMPaymentTransactionAttributes WMPaymentTransactionAttributes = {
	.appliedFlag = @"appliedFlag",
	.createdAt = @"createdAt",
	.errorCode = @"errorCode",
	.errorMessage = @"errorMessage",
	.ffUrl = @"ffUrl",
	.flags = @"flags",
	.originalTransactionIdentifier = @"originalTransactionIdentifier",
	.productIdentifier = @"productIdentifier",
	.quantity = @"quantity",
	.transactionDate = @"transactionDate",
	.transactionIdentifier = @"transactionIdentifier",
	.transactionState = @"transactionState",
	.updatedAt = @"updatedAt",
	.username = @"username",
};

const struct WMPaymentTransactionRelationships WMPaymentTransactionRelationships = {
};

const struct WMPaymentTransactionFetchedProperties WMPaymentTransactionFetchedProperties = {
};

@implementation WMPaymentTransactionID
@end

@implementation _WMPaymentTransaction

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WMPaymentTransaction" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WMPaymentTransaction";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WMPaymentTransaction" inManagedObjectContext:moc_];
}

- (WMPaymentTransactionID*)objectID {
	return (WMPaymentTransactionID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"appliedFlagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"appliedFlag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"errorCodeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"errorCode"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"flagsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"flags"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"quantityValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"quantity"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"transactionStateValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"transactionState"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic appliedFlag;



- (BOOL)appliedFlagValue {
	NSNumber *result = [self appliedFlag];
	return [result boolValue];
}

- (void)setAppliedFlagValue:(BOOL)value_ {
	[self setAppliedFlag:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveAppliedFlagValue {
	NSNumber *result = [self primitiveAppliedFlag];
	return [result boolValue];
}

- (void)setPrimitiveAppliedFlagValue:(BOOL)value_ {
	[self setPrimitiveAppliedFlag:[NSNumber numberWithBool:value_]];
}





@dynamic createdAt;






@dynamic errorCode;



- (int32_t)errorCodeValue {
	NSNumber *result = [self errorCode];
	return [result intValue];
}

- (void)setErrorCodeValue:(int32_t)value_ {
	[self setErrorCode:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveErrorCodeValue {
	NSNumber *result = [self primitiveErrorCode];
	return [result intValue];
}

- (void)setPrimitiveErrorCodeValue:(int32_t)value_ {
	[self setPrimitiveErrorCode:[NSNumber numberWithInt:value_]];
}





@dynamic errorMessage;






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





@dynamic originalTransactionIdentifier;






@dynamic productIdentifier;






@dynamic quantity;



- (int16_t)quantityValue {
	NSNumber *result = [self quantity];
	return [result shortValue];
}

- (void)setQuantityValue:(int16_t)value_ {
	[self setQuantity:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveQuantityValue {
	NSNumber *result = [self primitiveQuantity];
	return [result shortValue];
}

- (void)setPrimitiveQuantityValue:(int16_t)value_ {
	[self setPrimitiveQuantity:[NSNumber numberWithShort:value_]];
}





@dynamic transactionDate;






@dynamic transactionIdentifier;






@dynamic transactionState;



- (int16_t)transactionStateValue {
	NSNumber *result = [self transactionState];
	return [result shortValue];
}

- (void)setTransactionStateValue:(int16_t)value_ {
	[self setTransactionState:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveTransactionStateValue {
	NSNumber *result = [self primitiveTransactionState];
	return [result shortValue];
}

- (void)setPrimitiveTransactionStateValue:(int16_t)value_ {
	[self setPrimitiveTransactionState:[NSNumber numberWithShort:value_]];
}





@dynamic updatedAt;






@dynamic username;











@end
