#import "_WMWoundOdor.h"
#import "WoundCareProtocols.h"

@interface WMWoundOdor : _WMWoundOdor {}

+ (WMWoundOdor *)woundOdorForTitle:(NSString *)title
                            create:(BOOL)create
              managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallbackWithCallback)completionHandler;

@end
