#import "_WMInterventionEventType.h"
#import "WoundCareProtocols.h"
#import "WMFFManagedObject.h"

extern NSString * const kInterventionEventTypePlan;
extern NSString * const kInterventionEventTypeBegin;
extern NSString * const kInterventionEventTypeProvide;
extern NSString * const kInterventionEventTypeComplete;
extern NSString * const kInterventionEventTypeCancel;
extern NSString * const kInterventionEventTypeDiscontinue;
extern NSString * const kInterventionEventTypeContinue;
extern NSString * const kInterventionEventTypeRevise;

typedef enum {
    InterventionEventChangeTypeNone,
    InterventionEventChangeTypeDelete,
    InterventionEventChangeTypeAdd,
    InterventionEventChangeTypeUpdateValue,
    InterventionEventChangeTypeUpdateStatus,
} InterventionEventChangeType;

@interface WMInterventionEventType : _WMInterventionEventType <WMFFManagedObject> {}

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallbackWithCallback)completionHandler;

+ (WMInterventionEventType *)interventionEventTypeForTitle:(NSString *)title
                                                    create:(BOOL)create
                                      managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (NSString *)interventionEventTypeTitleForInterventionStatusTitle:(NSString *)title;
+ (WMInterventionEventType *)interventionEventTypeForStatusTitle:(NSString *)title
                                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (NSString *)stringForChangeType:(InterventionEventChangeType)changeType;

@end
