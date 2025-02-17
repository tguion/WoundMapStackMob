#import "_WMAmountQualifier.h"
#import "WoundCareProtocols.h"
#import "WMFFManagedObject.h"

@interface WMAmountQualifier : _WMAmountQualifier <WMFFManagedObject> {}

+ (WMAmountQualifier *)amountQualifierForTitle:(NSString *)title
                                        create:(BOOL)create
                          managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallbackWithCallback)completionHandler;

@end
