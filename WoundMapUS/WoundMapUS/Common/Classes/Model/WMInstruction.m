#import "WMInstruction.h"
#import "WMUtilities.h"
#import "StackMob.h"

@interface WMInstruction ()

// Private interface goes here.

@end


@implementation WMInstruction

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    WMInstruction *instruction = [[WMInstruction alloc] initWithEntity:[NSEntityDescription entityForName:@"WMInstruction" inManagedObjectContext:managedObjectContext] insertIntoManagedObjectContext:managedObjectContext];
	if (store) {
		[managedObjectContext assignObject:instruction toPersistentStore:store];
	}
    [instruction setValue:[instruction assignObjectId] forKey:[instruction primaryKeyField]];
	return instruction;
}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    // read the plist
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"Instructions" withExtension:@"plist"];
    if (nil == fileURL) {
        DLog(@"Instructions.plist file not found");
        return;
    }
    // else
    @autoreleasepool {
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfURL:fileURL];
        id propertyList = [NSPropertyListSerialization propertyListWithData:data
                                                                    options:NSPropertyListImmutable
                                                                     format:NULL
                                                                      error:&error];
        NSAssert1([propertyList isKindOfClass:[NSArray class]], @"Property list file did not return an NSArray, class was %@", NSStringFromClass([propertyList class]));
        __weak __typeof(self) weakSelf = self;
        [managedObjectContext performBlockAndWait:^{
            // check if already seeded
            NSInteger count = [WMInstruction instructionCount:managedObjectContext persistentStore:store];
            if (count > 0 && count != NSNotFound) {
                return;
            }
            // else
            for (NSDictionary *dictionary in propertyList) {
                [weakSelf updateInstructionFromDictionary:dictionary create:YES managedObjectContext:managedObjectContext persistentStore:store];
            }
        }];
    }
}

+ (NSInteger)instructionCount:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMInstruction" inManagedObjectContext:managedObjectContext]];
    NSError *error = nil;
    NSInteger count = [managedObjectContext countForFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    return count;
}

+ (WMInstruction *)updateInstructionFromDictionary:(NSDictionary *)dictionary
                                            create:(BOOL)create
                              managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                   persistentStore:(NSPersistentStore *)store
{
    id object = [dictionary objectForKey:@"title"];
    WMInstruction *instruction = [WMInstruction instructionForTitle:object
                                                             create:create
                                               managedObjectContext:managedObjectContext
                                                    persistentStore:store];
    instruction.contentFileExtension = [dictionary objectForKey:@"contentFileExtension"];
    instruction.contentFileName = [dictionary objectForKey:@"contentFileName"];
    instruction.sortRank = [dictionary objectForKey:@"sortRank"];
    instruction.desc = [dictionary objectForKey:@"desc"];
    instruction.iconFileName = [dictionary objectForKey:@"iconFileName"];
    return instruction;
}

+ (WMInstruction *)instructionForTitle:(NSString *)title
                                create:(BOOL)create
                  managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    if (nil != store) {
        [request setAffectedStores:[NSArray arrayWithObject:store]];
    }
    [request setEntity:[NSEntityDescription entityForName:@"WMInstruction" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"title == %@", title]];
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequestAndWait:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
    }
    // else
    WMInstruction *instruction = [array lastObject];
    if (create && nil == instruction) {
        instruction = [self instanceWithManagedObjectContext:managedObjectContext persistentStore:store];
        instruction.title = title;
    }
    return instruction;
}

@end
