#import "_WMSkinAssessment.h"
#import "WoundCareProtocols.h"

@class WMWoundType, WMSkinAssessmentCategory;

@interface WMSkinAssessment : _WMSkinAssessment <AssessmentGroup> {}

+ (WMSkinAssessment *)updateSkinAssessmentFromDictionary:(NSDictionary *)dictionary
                                                category:(WMSkinAssessmentCategory *)category
                                    managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                         persistentStore:(NSPersistentStore *)store;

+ (WMSkinAssessment *)skinInspectionForTitle:(NSString *)title
                                    category:(WMSkinAssessmentCategory *)category
                                      create:(BOOL)create
                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                             persistentStore:(NSPersistentStore *)store;

+ (NSPredicate *)predicateForWoundType:(WMWoundType *)woundType;

@end
