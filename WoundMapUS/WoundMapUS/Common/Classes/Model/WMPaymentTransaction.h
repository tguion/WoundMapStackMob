#import "_WMPaymentTransaction.h"
#import <StoreKit/StoreKit.h>
#import "WMFFManagedObject.h"

@interface WMPaymentTransaction : _WMPaymentTransaction {}

+ (WMPaymentTransaction *)paymentTransactionForSKPaymentTransaction:(SKPaymentTransaction *)transaction
                                                originalTransaction:(WMPaymentTransaction *)originalTransaction
                                                           username:(NSString *)username
                                                             create:(BOOL)create
                                               managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
