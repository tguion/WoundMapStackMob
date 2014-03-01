#import "_WMSkinAssessmentValue.h"

@interface WMSkinAssessmentValue : _WMSkinAssessmentValue {}

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store;

@end
