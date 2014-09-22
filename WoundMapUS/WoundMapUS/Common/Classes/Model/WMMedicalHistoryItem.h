#import "_WMMedicalHistoryItem.h"
#import "WoundCareProtocols.h"
#import "WMFFManagedObject.h"

@interface WMMedicalHistoryItem : _WMMedicalHistoryItem <WMFFManagedObject> {}

+ (NSArray *)sortedMedicalHistoryItems:(NSManagedObjectContext *)managedObjectContext;

+ (WMMedicalHistoryItem *)medicalHistoryItemForTitle:(NSString *)title
                                              create:(BOOL)create
                                managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallbackWithCallback)completionHandler;

@end
