#import "_WMPsychoSocialGroup.h"
#import "WoundCareProtocols.h"
#import "WMInterventionEventType.h"

@class WMPatient, WMPsychoSocialItem, WMPsychoSocialValue, WMPsychoSocialIntEvent, WMParticipant;

@interface WMPsychoSocialGroup : _WMPsychoSocialGroup <AssessmentGroup> {}

@property (readonly, nonatomic) BOOL hasInterventionEvents;

+ (BOOL)psychoSocialGroupsHaveHistory:(WMPatient *)patient;
+ (NSInteger)psychoSocialGroupsCount:(WMPatient *)patient;
+ (NSSet *)psychoSocialValuesForPsychoSocialGroup:(WMPsychoSocialGroup *)psychoSocialGroup;

+ (WMPsychoSocialGroup *)activePsychoSocialGroup:(WMPatient *)patient;
+ (WMPsychoSocialGroup *)mostRecentOrActivePsychosocialGroup:(WMPatient *)patient;
+ (NSDate *)mostRecentOrActivePsychoSocialGroupDateModified:(WMPatient *)patient;
+ (NSInteger)closePsychoSocialGroupsCreatedBefore:(NSDate *)date
                                          patient:(WMPatient *)patient;

+ (NSArray *)sortedPsychoSocialGroups:(WMPatient *)patient;
+ (NSArray *)sortedPsychoSocialValuesForGroup:(WMPsychoSocialGroup *)group psychoSocialItem:(WMPsychoSocialItem *)psychoSocialItem;
+ (NSArray *)sortedPsychoSocialValuesForGroup:(WMPsychoSocialGroup *)group parentPsychoSocialItem:(WMPsychoSocialItem *)parentItem;

+ (BOOL)hasPsychoSocialValueForChildrenOfParentItem:(WMPsychoSocialGroup *)psychoSocialGroup
                             parentPsychoSocialItem:(WMPsychoSocialItem *)parentPsychoSocialItem;

- (WMPsychoSocialValue *)psychoSocialValueForPsychoSocialGroup:(WMPsychoSocialGroup *)psychoSocialGroup
                                              psychoSocialItem:(WMPsychoSocialItem *)psychoSocialItem
                                                        create:(BOOL)create
                                                         value:(NSString *)value;

- (WMPsychoSocialValue *)psychoSocialValueForParentItem:(WMPsychoSocialItem *)parentItem;
- (void)removePsychoSocialValuesForPsychoSocialItem:(WMPsychoSocialItem *)psychoSocialItem;


- (NSInteger)valuesCountForPsychoSocialItem:(WMPsychoSocialItem *)psychoSocialItem;
- (NSInteger)updatedScoreForPsychoSocialItem:(WMPsychoSocialItem *)psychoSocialItem;
- (NSInteger)subitemValueCountForPsychoSocialItem:(WMPsychoSocialItem *)psychoSocialItem;

- (WMPsychoSocialIntEvent *)interventionEventForChangeType:(InterventionEventChangeType)changeType
                                                      path:(NSString *)path
                                                     title:(NSString *)title
                                                 valueFrom:(id)valueFrom
                                                   valueTo:(id)valueTo
                                                      type:(WMInterventionEventType *)type
                                               participant:(WMParticipant *)participant
                                                    create:(BOOL)create
                                      managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (NSArray *)createEditEventsForParticipant:(WMParticipant *)participant;

@end
