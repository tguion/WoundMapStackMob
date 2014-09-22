#import "_WMWoundPosition.h"
#import "WMFFManagedObject.h"

@interface WMWoundPosition : _WMWoundPosition <WMFFManagedObject> {}

@property (nonatomic) BOOL optionsInline;
@property (nonatomic) BOOL allowMultipleSelection;
@property (readonly, nonatomic) BOOL hasTitle;

+ (WMWoundPosition *)woundPositionForTitle:(NSString *)title
                                    create:(BOOL)create
                      managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMWoundPosition *)woundPositionForCommonTitle:(NSString *)commonTitle
                                          create:(BOOL)create
                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
