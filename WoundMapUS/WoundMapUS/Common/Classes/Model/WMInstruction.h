#import "_WMInstruction.h"

@interface WMInstruction : _WMInstruction {}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;
+ (WMInstruction *)updateInstructionFromDictionary:(NSDictionary *)dictionary
                                            create:(BOOL)create
                              managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                   persistentStore:(NSPersistentStore *)store;

+ (NSInteger)instructionCount:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;

+ (WMInstruction *)instructionForTitle:(NSString *)title
                                create:(BOOL)create
                  managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store;

@end
