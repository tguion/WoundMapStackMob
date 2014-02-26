#import "_WMBradenCare.h"

@interface WMBradenCare : _WMBradenCare {}

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store;

+ (WMBradenCare *)bradenCareForSectionTitle:(NSString *)sectionTitle
                                   sortRank:(NSNumber *)sortRank
                       managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMBradenCare *)bradenCareForSectionTitle:(NSString *)sectionTitle
                                      score:(NSNumber *)score
                       managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
@end
