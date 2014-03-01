#import "WMSkinAssessmentValue.h"
#import "StackMob.h"

@interface WMSkinAssessmentValue ()

// Private interface goes here.

@end


@implementation WMSkinAssessmentValue

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMSkinAssessmentValue *skinAssessmentValue = [[WMSkinAssessmentValue alloc] initWithEntity:[NSEntityDescription entityForName:@"WMSkinAssessmentValue" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:skinAssessmentValue toPersistentStore:store];
	}
    [skinAssessmentValue setValue:[skinAssessmentValue assignObjectId] forKey:[skinAssessmentValue primaryKeyField]];
	return skinAssessmentValue;
}

@end
