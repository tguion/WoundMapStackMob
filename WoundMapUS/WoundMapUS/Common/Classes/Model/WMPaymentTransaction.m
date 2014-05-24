#import "WMPaymentTransaction.h"

@interface WMPaymentTransaction ()

// Private interface goes here.

@end


@implementation WMPaymentTransaction

+ (WMPaymentTransaction *)paymentTransactionForSKPaymentTransaction:(SKPaymentTransaction *)transaction
                                                originalTransaction:(WMPaymentTransaction *)originalTransaction
                                                           username:(NSString *)username
                                                             create:(BOOL)create
                                               managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    WMPaymentTransaction *paymentTransaction = [WMPaymentTransaction MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"%K == %@", WMPaymentTransactionAttributes.transactionIdentifier, transaction.transactionIdentifier]
                                                                                     inContext:managedObjectContext];
    if (create && nil == paymentTransaction) {
        paymentTransaction = [WMPaymentTransaction MR_createInContext:managedObjectContext];
    }
    paymentTransaction.errorCode = @(transaction.error.code);
    paymentTransaction.errorMessage = transaction.error.localizedDescription;
    paymentTransaction.originalTransactionIdentifier = originalTransaction.transactionIdentifier;
    paymentTransaction.productIdentifier = transaction.payment.productIdentifier;
    paymentTransaction.quantityValue = transaction.payment.quantity;
    paymentTransaction.transactionDate = transaction.transactionDate;
    paymentTransaction.transactionStateValue = transaction.transactionState;
    paymentTransaction.username = username;
    return paymentTransaction;
}

#pragma mark - FatFractal

+ (NSSet *)attributeNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"errorCodeValue",
                                                            @"flagsValue",
                                                            @"quantityValue",
                                                            @"transactionStateValue",
                                                            @"appliedFlagValue"]];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSSet *)relationshipNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[]];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMPaymentTransaction attributeNamesNotToSerialize] containsObject:propertyName] || [[WMPaymentTransaction relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMPaymentTransaction relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end
