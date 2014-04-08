#import "_WMMedicalHistoryItem.h"
#import "WoundCareProtocols.h"

@interface WMMedicalHistoryItem : _WMMedicalHistoryItem {}

+ (WMMedicalHistoryItem *)medicalHistoryItemForTitle:(NSString *)title
                                              create:(BOOL)create
                                managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallback)completionHandler;

@end
