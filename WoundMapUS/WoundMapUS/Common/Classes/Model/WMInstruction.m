#import "WMInstruction.h"
#import "WMUtilities.h"

@interface WMInstruction ()

// Private interface goes here.

@end


@implementation WMInstruction

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext
{
    // read the plist
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"Instructions" withExtension:@"plist"];
    if (nil == fileURL) {
        DLog(@"Instructions.plist file not found");
        return;
    }
    // check if already seeded
    NSInteger count = [WMInstruction instructionCount:managedObjectContext];
    if (count > 0 && count != NSNotFound) {
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
        for (NSDictionary *dictionary in propertyList) {
            [self updateInstructionFromDictionary:dictionary create:YES managedObjectContext:managedObjectContext];
        }
        [managedObjectContext MR_saveToPersistentStoreAndWait];
    }
}

+ (NSInteger)instructionCount:(NSManagedObjectContext *)managedObjectContext
{
    return [WMInstruction MR_countOfEntitiesWithContext:managedObjectContext];
}

+ (WMInstruction *)updateInstructionFromDictionary:(NSDictionary *)dictionary
                                            create:(BOOL)create
                              managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    id object = [dictionary objectForKey:@"title"];
    WMInstruction *instruction = [WMInstruction instructionForTitle:object
                                                             create:create
                                               managedObjectContext:managedObjectContext];
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
{
    WMInstruction *instruction = [WMInstruction MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"title == %@", title] inContext:managedObjectContext];
    if (create && nil == instruction) {
        instruction = [self MR_createInContext:managedObjectContext];
        instruction.title = title;
    }
    return instruction;
}

@end
