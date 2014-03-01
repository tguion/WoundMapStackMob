#import "_WMSkinAssessmentGroup.h"
#import "WoundCareProtocols.h"

@class WMPatient, WMSkinAssessment, WMSkinAssessmentCategory, WMSkinAssessmentValue;

@interface WMSkinAssessmentGroup : _WMSkinAssessmentGroup <AssessmentGroup> {}

@property (readonly, nonatomic) BOOL isClosed;
@property (readonly, nonatomic) NSArray *sortedSkinAssessmentValues;
@property (readonly, nonatomic) BOOL hasValues;

+ (WMSkinAssessmentGroup *)activeSkinAssessmentGroup:(WMPatient *)patient;
+ (WMSkinAssessmentGroup *)mostRecentOrActiveSkinAssessmentGroup:(WMPatient *)patient;
+ (NSDate *)mostRecentOrActiveSkinAssessmentGroupDateModified:(WMPatient *)patient;
+ (NSInteger)closeSkinAssessmentGroupsCreatedBefore:(NSDate *)date
                                            patient:(WMPatient *)patient;

+ (BOOL)skinAssessmentGroupsHaveHistory:(WMPatient *)patient;
+ (NSInteger)skinAssessmentGroupsCount:(WMPatient *)patient;

+ (NSArray *)sortedSkinAssessmentGroups:(WMPatient *)patient;

- (WMSkinAssessmentValue *)skinAssessmentValueForSkinAssessment:(WMSkinAssessment *)skinAssessment
                                                         create:(BOOL)create
                                                          value:(id)value;

- (void)removeSkinAssessmentValuesForCategory:(WMSkinAssessmentCategory *)category;

- (void)incrementContinueCount;

@end
