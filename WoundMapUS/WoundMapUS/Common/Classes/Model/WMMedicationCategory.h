#import "_WMMedicationCategory.h"
#import "WoundCareProtocols.h"
#import "WMFFManagedObject.h"

@interface WMMedicationCategory : _WMMedicationCategory <WMFFManagedObject> {}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallbackWithCallback)completionHandler;

+ (WMMedicationCategory *)medicationCategoryForTitle:(NSString *)title
                                              create:(BOOL)create
                                managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMMedicationCategory *)medicationCategoryForSortRank:(id)sortRank
                                   managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
