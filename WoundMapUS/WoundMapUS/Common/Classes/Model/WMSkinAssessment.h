#import "_WMSkinAssessment.h"
#import "WoundCareProtocols.h"
#import "WMFFManagedObject.h"

@class WMWoundType, WMSkinAssessmentCategory;

@interface WMSkinAssessment : _WMSkinAssessment <AssessmentGroup, WMFFManagedObject> {}

+ (WMSkinAssessment *)updateSkinAssessmentFromDictionary:(NSDictionary *)dictionary
                                                category:(WMSkinAssessmentCategory *)category
                                    managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMSkinAssessment *)skinInspectionForTitle:(NSString *)title
                                    category:(WMSkinAssessmentCategory *)category
                                      create:(BOOL)create
                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (NSPredicate *)predicateForWoundType:(WMWoundType *)woundType;

@end
