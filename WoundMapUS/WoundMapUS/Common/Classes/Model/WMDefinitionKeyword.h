#import "_WMDefinitionKeyword.h"

@interface WMDefinitionKeyword : _WMDefinitionKeyword {}

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store;

@end
