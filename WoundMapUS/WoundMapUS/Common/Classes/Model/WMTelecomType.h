#import "_WMTelecomType.h"

extern NSString * const kTelecomTypeEmailTitle;

@interface WMTelecomType : _WMTelecomType {}

@property (readonly, nonatomic) BOOL isEmail;

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext;

+ (NSArray *)sortedTelecomTypes:(NSManagedObjectContext *)managedObjectContext;

+ (WMTelecomType *)telecomTypeForTitle:(NSString *)title
                                create:(BOOL)create
                  managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
