#import "_WMMedicalHistoryItem.h"
#import "WoundCareProtocols.h"

@interface WMMedicalHistoryItem : _WMMedicalHistoryItem {}

+ (NSArray *)sortedMedicalHistoryItems:(NSManagedObjectContext *)managedObjectContext;

+ (WMMedicalHistoryItem *)medicalHistoryItemForTitle:(NSString *)title
                                              create:(BOOL)create
                                managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallbackWithCallback)completionHandler;

@end
