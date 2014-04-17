#import "WMInterventionEvent.h"
#import "WMParticipant.h"
#import "WMSkinAssessmentGroup.h"
#import "WMCarePlanGroup.h"
#import "WMDeviceGroup.h"
#import "WMMedicationGroup.h"
#import "WMPsychoSocialGroup.h"

@interface WMInterventionEvent ()

// Private interface goes here.

@end


@implementation WMInterventionEvent

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
    self.dateEvent = [NSDate date];
}

+ (WMInterventionEvent *)interventionEventForSkinAssessmentGroup:(WMSkinAssessmentGroup *)skinAssessmentGroup
                                                      changeType:(InterventionEventChangeType)changeType
                                                           title:(NSString *)title
                                                       valueFrom:(id)valueFrom
                                                         valueTo:(id)valueTo
                                                            type:(WMInterventionEventType *)eventType
                                                     participant:(WMParticipant *)participant
                                                          create:(BOOL)create
                                            managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSParameterAssert([skinAssessmentGroup managedObjectContext] == managedObjectContext);
    NSParameterAssert([participant managedObjectContext] == managedObjectContext);
    if (nil != eventType) {
        NSParameterAssert([eventType managedObjectContext] == managedObjectContext);
    }
    WMInterventionEvent *interventionEvent = [WMInterventionEvent MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:
                                                                                             @"skinAssessmentGroup == %@ AND changeType == %d AND title == %@ AND valueFrom == %@ AND valueTo == %@ AND eventType == %@ AND participant == %@",
                                                                                             skinAssessmentGroup, changeType, title, valueFrom, valueTo, eventType, participant] inContext:managedObjectContext];
    if (create && nil == interventionEvent) {
        interventionEvent = [WMInterventionEvent MR_createInContext:managedObjectContext];
        interventionEvent.skinAssessmentGroup = skinAssessmentGroup;
        interventionEvent.changeType = [NSNumber numberWithInt:changeType];
        interventionEvent.title = title;
        if ([valueFrom isKindOfClass:[NSString class]]) {
            interventionEvent.valueFrom = valueFrom;
        }
        if ([valueTo isKindOfClass:[NSString class]]) {
            interventionEvent.valueTo = valueTo;
        }
        interventionEvent.eventType = eventType;
        interventionEvent.participant = participant;
    }
    return interventionEvent;
}

+ (WMInterventionEvent *)interventionEventForCarePlanGroup:(WMCarePlanGroup *)carePlanGroup
                                                changeType:(InterventionEventChangeType)changeType
                                                      path:(NSString *)path
                                                     title:(NSString *)title
                                                 valueFrom:(id)valueFrom
                                                   valueTo:(id)valueTo
                                                      type:(WMInterventionEventType *)eventType
                                               participant:(WMParticipant *)participant
                                                    create:(BOOL)create
                                      managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    carePlanGroup = (WMCarePlanGroup *)[managedObjectContext objectWithID:[carePlanGroup objectID]];
    if (nil != eventType) {
        eventType = (WMInterventionEventType *)[managedObjectContext objectWithID:[eventType objectID]];
    }
    participant = (WMParticipant *)[managedObjectContext objectWithID:[participant objectID]];
    WMInterventionEvent *interventionEvent = [WMInterventionEvent MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:
                                                                                             @"carePlanGroup == %@ AND changeType == %d AND path == %@ AND title == %@ AND valueFrom == %@ AND valueTo == %@ AND eventType == %@ AND participant == %@",
                                                                                             carePlanGroup, changeType, path, title, valueFrom, valueTo, eventType, participant]
                                                                                  inContext:managedObjectContext];
    if (create && nil == interventionEvent) {
        interventionEvent = [WMInterventionEvent MR_createInContext:managedObjectContext];
        interventionEvent.carePlanGroup = carePlanGroup;
        interventionEvent.changeType = [NSNumber numberWithInt:changeType];
        interventionEvent.path = path;
        interventionEvent.title = title;
        interventionEvent.valueFrom = valueFrom;
        interventionEvent.valueTo = valueTo;
        interventionEvent.eventType = eventType;
        interventionEvent.participant = participant;
    }
    return interventionEvent;
}

+ (WMInterventionEvent *)interventionEventForDeviceGroup:(WMDeviceGroup *)deviceGroup
                                              changeType:(InterventionEventChangeType)changeType
                                                   title:(NSString *)title
                                               valueFrom:(id)valueFrom
                                                 valueTo:(id)valueTo
                                                    type:(WMInterventionEventType *)eventType
                                             participant:(WMParticipant *)participant
                                                  create:(BOOL)create
                                    managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    deviceGroup = (WMDeviceGroup *)[managedObjectContext objectWithID:[deviceGroup objectID]];
    if (nil != eventType) {
        eventType = (WMInterventionEventType *)[managedObjectContext objectWithID:[eventType objectID]];
    }
    participant = (WMParticipant *)[managedObjectContext objectWithID:[participant objectID]];
    WMInterventionEvent *interventionEvent = [WMInterventionEvent MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:
                                                                                             @"deviceGroup == %@ AND changeType == %d AND title == %@ AND valueFrom == %@ AND valueTo == %@ AND eventType == %@ AND participant == %@",
                                                                                             deviceGroup, changeType, title, valueFrom, valueTo, eventType, participant]
                                                                                  inContext:managedObjectContext];
    if (create && nil == interventionEvent) {
        interventionEvent = [WMInterventionEvent MR_createInContext:managedObjectContext];
        interventionEvent.deviceGroup = deviceGroup;
        interventionEvent.changeType = [NSNumber numberWithInt:changeType];
        interventionEvent.title = title;
        if ([valueFrom isKindOfClass:[NSString class]]) {
            interventionEvent.valueFrom = valueFrom;
        }
        if ([valueTo isKindOfClass:[NSString class]]) {
            interventionEvent.valueTo = valueTo;
        }
        interventionEvent.eventType = eventType;
        interventionEvent.participant = participant;
    }
    return interventionEvent;
}

+ (WMInterventionEvent *)interventionEventForMedicationGroup:(WMMedicationGroup *)medicationGroup
                                                  changeType:(InterventionEventChangeType)changeType
                                                       title:(NSString *)title
                                                   valueFrom:(id)valueFrom
                                                     valueTo:(id)valueTo
                                                        type:(WMInterventionEventType *)eventType
                                                 participant:(WMParticipant *)participant
                                                      create:(BOOL)create
                                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    medicationGroup = (WMMedicationGroup *)[managedObjectContext objectWithID:[medicationGroup objectID]];
    if (nil != eventType) {
        eventType = (WMInterventionEventType *)[managedObjectContext objectWithID:[eventType objectID]];
    }
    participant = (WMParticipant *)[managedObjectContext objectWithID:[participant objectID]];
    WMInterventionEvent *interventionEvent = [WMInterventionEvent MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:
                                                                                             @"medicationGroup == %@ AND changeType == %d AND valueFrom == %@ AND valueTo == %@ AND eventType == %@ AND participant == %@",
                                                                                             medicationGroup, changeType, valueFrom, valueTo, eventType, participant]
                                                                                  inContext:managedObjectContext];
    if (create && nil == interventionEvent) {
        interventionEvent = [WMInterventionEvent MR_createInContext:managedObjectContext];
        interventionEvent.medicationGroup = medicationGroup;
        interventionEvent.changeType = [NSNumber numberWithInt:changeType];
        interventionEvent.title = title;
        if ([valueFrom isKindOfClass:[NSString class]]) {
            interventionEvent.valueFrom = valueFrom;
        }
        if ([valueTo isKindOfClass:[NSString class]]) {
            interventionEvent.valueTo = valueTo;
        }
        interventionEvent.eventType = eventType;
        interventionEvent.participant = participant;
    }
    return interventionEvent;
}

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
{
    NSParameterAssert([psychoSocialGroup managedObjectContext] == managedObjectContext);
    NSParameterAssert([participant managedObjectContext] == managedObjectContext);
    if (nil != eventType) {
        NSParameterAssert([eventType managedObjectContext] == managedObjectContext);
    }
    WMInterventionEvent *interventionEvent = [WMInterventionEvent MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:
                                                                                             @"group == %@ AND changeType == %d AND path == %@ AND title == %@ AND valueFrom == %@ AND valueTo == %@ AND eventType == %@ AND participant == %@",
                                                                                             psychoSocialGroup, changeType, path, title, valueFrom, valueTo, eventType, participant] inContext:managedObjectContext];
    if (create && nil == interventionEvent) {
        interventionEvent = [WMInterventionEvent MR_createInContext:managedObjectContext];
        interventionEvent.psychoSocialGroup = psychoSocialGroup;
        interventionEvent.changeType = [NSNumber numberWithInt:changeType];
        interventionEvent.path = path;
        interventionEvent.title = title;
        interventionEvent.valueFrom = valueFrom;
        interventionEvent.valueTo = valueTo;
        interventionEvent.eventType = eventType;
        interventionEvent.participant = participant;
    }
    return interventionEvent;
}

#pragma mark - FatFractal

+ (NSSet *)attributeNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"changeTypeValue"]];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSSet *)relationshipNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[]];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMInterventionEvent attributeNamesNotToSerialize] containsObject:propertyName] || [[WMInterventionEvent relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMInterventionEvent relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end
