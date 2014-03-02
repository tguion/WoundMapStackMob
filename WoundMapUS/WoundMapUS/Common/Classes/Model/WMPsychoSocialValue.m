#import "WMPsychoSocialValue.h"
#import "WMPsychoSocialItem.h"
#import "StackMob.h"

@interface WMPsychoSocialValue ()

// Private interface goes here.

@end


@implementation WMPsychoSocialValue

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMPsychoSocialValue *psychoSocialValue = [[WMPsychoSocialValue alloc] initWithEntity:[NSEntityDescription entityForName:@"WMPsychoSocialValue" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:psychoSocialValue toPersistentStore:store];
	}
    [psychoSocialValue setValue:[psychoSocialValue assignObjectId] forKey:[psychoSocialValue primaryKeyField]];
	return psychoSocialValue;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.dateCreated = [NSDate date];
    self.dateModified = [NSDate date];
}

- (NSString *)pathToValue
{
    NSMutableArray *path = [[NSMutableArray alloc] initWithCapacity:16];
    WMPsychoSocialItem *psychoSocialItem = self.psychoSocialItem;
    NSString *string = nil;
    while (nil != psychoSocialItem) {
        string = psychoSocialItem.title;
        if (nil != self.value) {
            string = [string stringByAppendingFormat:@": (%@)", self.value];
        }
        [path insertObject:string atIndex:0];
        psychoSocialItem = psychoSocialItem.parentItem;
    }
    return [path componentsJoinedByString:@","];
}

- (NSString *)displayValue
{
    NSString *displayValue = self.value;
    if ([displayValue length] > 0 && [self.psychoSocialItem.options length] > 0) {
        displayValue = [[self.psychoSocialItem.options componentsSeparatedByString:@","] objectAtIndex:[displayValue integerValue]];
    }
    return displayValue;
}

@end
