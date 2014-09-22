#import "_WMInterventionEvent.h"
#import "WMInterventionEventType.h"
#import "WMFFManagedObject.h"

@class WMParticipant, WMInterventionEventType;
@class WMSkinAssessmentGroup, WMCarePlanGroup, WMDeviceGroup, WMMedicationGroup, WMPsychoSocialGroup, WMWoundMeasurementGroup, WMWoundTreatmentGroup, WMNutritionGroup;

@interface WMInterventionEvent : _WMInterventionEvent <WMFFManagedObject> {}

+ (WMInterventionEvent *)interventionEventForSkinAssessmentGroup:(WMSkinAssessmentGroup *)skinAssessmentGroup
                                                      changeType:(InterventionEventChangeType)changeType
                                                           title:(NSString *)title
                                                       valueFrom:(id)valueFrom
                                                         valueTo:(id)valueTo
                                                            type:(WMInterventionEventType *)eventType
                                                     participant:(WMParticipant *)participant
                                                          create:(BOOL)create
                                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMInterventionEvent *)interventionEventForDeviceGroup:(WMDeviceGroup *)deviceGroup
                                              changeType:(InterventionEventChangeType)changeType
                                                   title:(NSString *)title
                                               valueFrom:(id)valueFrom
                                                 valueTo:(id)valueTo
                                                    type:(WMInterventionEventType *)eventType
                                             participant:(WMParticipant *)participant
                                                  create:(BOOL)create
                                    managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMInterventionEvent *)interventionEventForMedicationGroup:(WMMedicationGroup *)medicationGroup
                                                  changeType:(InterventionEventChangeType)changeType
                                                       title:(NSString *)title
                                                   valueFrom:(id)valueFrom
                                                     valueTo:(id)valueTo
                                                        type:(WMInterventionEventType *)eventType
                                                 participant:(WMParticipant *)participant
                                                      create:(BOOL)create
                                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMInterventionEvent *)interventionEventForPsychoSocialGroup:(WMPsychoSocialGroup *)psychoSocialGroup
                                                    changeType:(InterventionEventChangeType)changeType
                                                          path:(NSString *)path
                                                         title:(NSString *)title
                                                     valueFrom:(id)valueFrom
                                                       valueTo:(id)valueTo
                                                          type:(WMInterventionEventType *)eventType
                                                   participant:(WMParticipant *)participant
                                                        create:(BOOL)create
                                          managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMInterventionEvent *)interventionEventForNutritionGroup:(WMNutritionGroup *)nutritionGroup
                                                 changeType:(InterventionEventChangeType)changeType
                                                      title:(NSString *)title
                                                  valueFrom:(id)valueFrom
                                                    valueTo:(id)valueTo
                                                       type:(WMInterventionEventType *)eventType
                                                participant:(WMParticipant *)participant
                                                     create:(BOOL)create
                                       managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMInterventionEvent *)interventionEventForWoundMeasurementGroup:(WMWoundMeasurementGroup *)woundMeasurementGroup
                                                        changeType:(InterventionEventChangeType)changeType
                                                             title:(NSString *)title
                                                         valueFrom:(id)valueFrom
                                                           valueTo:(id)valueTo
                                                              type:(WMInterventionEventType *)eventType
                                                       participant:(WMParticipant *)participant
                                                            create:(BOOL)create
                                              managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMInterventionEvent *)interventionEventForCarePlanGroup:(WMCarePlanGroup *)carePlanGroup
                                                changeType:(InterventionEventChangeType)changeType
                                                      path:(NSString *)path
                                                     title:(NSString *)title
                                                 valueFrom:(id)valueFrom
                                                   valueTo:(id)valueTo
                                                      type:(WMInterventionEventType *)eventType
                                               participant:(WMParticipant *)participant
                                                    create:(BOOL)create
                                      managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMInterventionEvent *)interventionEventForWoundTreatmentGroup:(WMWoundTreatmentGroup *)woundTreatmentGroup
                                                      changeType:(InterventionEventChangeType)changeType
                                                           title:(NSString *)title
                                                       valueFrom:(id)valueFrom
                                                         valueTo:(id)valueTo
                                                            type:(WMInterventionEventType *)eventType
                                                     participant:(WMParticipant *)participant
                                                          create:(BOOL)create
                                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
