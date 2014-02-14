#import "_WMNavigationStage.h"

@interface WMNavigationStage : _WMNavigationStage {}

+ (NSInteger)navigationStageCount:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;

@end
