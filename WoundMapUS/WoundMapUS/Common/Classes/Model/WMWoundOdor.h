#import "_WMWoundOdor.h"
#import "WoundCareProtocols.h"
#import "WMFFManagedObject.h"

@interface WMWoundOdor : _WMWoundOdor <WMFFManagedObject> {}

+ (WMWoundOdor *)woundOdorForTitle:(NSString *)title
                            create:(BOOL)create
              managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallbackWithCallback)completionHandler;

@end
