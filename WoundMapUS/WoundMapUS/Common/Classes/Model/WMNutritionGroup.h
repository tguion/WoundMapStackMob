#import "_WMNutritionGroup.h"
#import "WMInterventionEventType.h"
#import "WMFFManagedObject.h"

@class WMPatient, WMInterventionEvent, WMParticipant, WMNutritionItem;

@interface WMNutritionGroup : _WMNutritionGroup <WMFFManagedObject> {}

@property (readonly, nonatomic) NSArray *sortedValues;

+ (WMNutritionGroup *)activeNutritionGroup:(WMPatient *)patient;
+ (WMNutritionGroup *)mostRecentOrActiveNutritionGroup:(WMPatient *)patient;
+ (NSDate *)mostRecentOrActiveNutritionGroupDateModified:(WMPatient *)patient;
+ (WMNutritionGroup *)nutritionGroupForPatient:(WMPatient *)patient;

+ (NSInteger)closeNutritionGroupsCreatedBefore:(NSDate *)date
                                       patient:(WMPatient *)patient;

- (WMNutritionValue *)nutritionValueForItem:(WMNutritionItem *)item
                                     create:(BOOL)create
                                      value:(NSString *)value;

+ (NSArray *)sortedNutritionGroups:(WMPatient *)patient;
+ (NSInteger)nutritionGroupsCount:(WMPatient *)patient;

- (WMInterventionEvent *)interventionEventForChangeType:(InterventionEventChangeType)changeType
                                                  title:(NSString *)title
                                              valueFrom:(id)valueFrom
                                                valueTo:(id)valueTo
                                                   type:(WMInterventionEventType *)type
                                            participant:(WMParticipant *)participant
                                                 create:(BOOL)create
                                   managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (NSArray *)createEditEventsForParticipant:(WMParticipant *)participant;

@end
