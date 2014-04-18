#import "_WMAmountQualifier.h"
#import "WoundCareProtocols.h"

@interface WMAmountQualifier : _WMAmountQualifier {}

+ (WMAmountQualifier *)amountQualifierForTitle:(NSString *)title
                                        create:(BOOL)create
                          managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallbackWithCallback)completionHandler;

@end
