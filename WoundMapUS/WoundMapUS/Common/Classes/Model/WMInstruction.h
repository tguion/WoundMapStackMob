#import "_WMInstruction.h"

@interface WMInstruction : _WMInstruction {}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext;

+ (WMInstruction *)updateInstructionFromDictionary:(NSDictionary *)dictionary
                                            create:(BOOL)create
                              managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (NSInteger)instructionCount:(NSManagedObjectContext *)managedObjectContext;

+ (WMInstruction *)instructionForTitle:(NSString *)title
                                create:(BOOL)create
                  managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
