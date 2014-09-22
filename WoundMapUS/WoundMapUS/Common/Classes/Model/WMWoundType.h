#import "_WMWoundType.h"
#import "WoundCareProtocols.h"
#import "WMFFManagedObject.h"

// IAP: wound type codes here
typedef enum {
    WoundTypeCode_PressureUlcer                 = 0,
    WoundTypeCode_Arterial                      = 1,
    WoundTypeCode_Venous                        = 2,
    WoundTypeCode_Diabetic                      = 3,
    WoundTypeCode_SkinTear                      = 4,
    WoundTypeCode_MoistureAssociatedDermatitis  = 5,
    WoundTypeCode_Burn                          = 6,
    WoundTypeCode_Surgical                      = 7,
    WoundTypeCode_Trauma                        = 8,
    WoundTypeCode_Cut                           = 9,
    WoundTypeCode_Mixed                         = 10,
    WoundTypeCode_GeneralAbrasion               = 11,
    WoundTypeCode_Other                         = 12,
} WoundTypeCode;

@interface WMWoundType : _WMWoundType <AssessmentGroup, WMFFManagedObject> {}

@property (readonly, nonatomic) BOOL isOther;
@property (readonly, nonatomic) BOOL hasChildrenWoundTypes;
@property (readonly, nonatomic) BOOL childrenHaveSectionTitles;
@property (readonly, nonatomic) NSString *titleForDisplay;

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext completionHandler:(WMProcessCallbackWithCallback)completionHandler;

+ (NSInteger)woundTypeCount:(NSManagedObjectContext *)managedObjectContext;

+ (WMWoundType *)woundTypeForTitle:(NSString *)title
                            create:(BOOL)create
              managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (NSArray *)woundTypesForWoundTypeCode:(NSInteger)woundTypeCodeValue
                   managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WMWoundType *)otherWoundType:(NSManagedObjectContext *)managedObjectContext;

@end
