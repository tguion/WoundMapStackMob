#import "WMDefinitionKeyword.h"
#import "StackMob.h"

@interface WMDefinitionKeyword ()

// Private interface goes here.

@end


@implementation WMDefinitionKeyword

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMDefinitionKeyword *definitionKeyword = [[WMDefinitionKeyword alloc] initWithEntity:[NSEntityDescription entityForName:@"WMDefinitionKeyword" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:definitionKeyword toPersistentStore:store];
	}
    [definitionKeyword setValue:[definitionKeyword assignObjectId] forKey:[definitionKeyword primaryKeyField]];
	return definitionKeyword;
}

@end
