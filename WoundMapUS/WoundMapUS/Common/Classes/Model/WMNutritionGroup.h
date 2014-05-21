#import "_WMNutritionGroup.h"
#import "WMInterventionEventType.h"

@class WMPatient, WMInterventionEvent, WMParticipant, WMNutritionItem;

@interface WMNutritionGroup : _WMNutritionGroup {}

+ (WMNutritionGroup *)activeNutritionGroup:(WMPatient *)patient;
+ (NSDate *)mostRecentOrActiveNutritionGroupDateModified:(WMPatient *)patient;
+ (WMNutritionGroup *)nutritionGroupForPatient:(WMPatient *)patient;

+ (NSInteger)closeNutritionGroupsCreatedBefore:(NSDate *)date
                                       patient:(WMPatient *)patient;

- (WMNutritionValue *)nutritionValueForItem:(WMNutritionItem *)item
                                     create:(BOOL)create
                                      value:(NSString *)value;

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
