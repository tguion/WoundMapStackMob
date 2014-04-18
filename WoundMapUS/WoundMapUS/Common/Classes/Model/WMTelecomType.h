#import "_WMTelecomType.h"
#import "WoundCareProtocols.h"

extern NSString * const kTelecomTypeEmailTitle;

@interface WMTelecomType : _WMTelecomType {}

@property (readonly, nonatomic) BOOL isEmail;

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallbackWithCallback)completionHandler;

+ (NSArray *)sortedTelecomTypes:(NSManagedObjectContext *)managedObjectContext;

+ (WMTelecomType *)telecomTypeForTitle:(NSString *)title
                                create:(BOOL)create
                  managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMTelecomType *)emailTelecomType:(NSManagedObjectContext *)managedObjectContext;

@end
