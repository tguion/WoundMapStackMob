#import "_WMNavigationNode.h"
#import "WoundCareProtocols.h"

typedef NS_ENUM(int16_t, NavigationNodeFrequencyUnit) {
    NavigationNodeFrequencyUnit_None        = 0,
    NavigationNodeFrequencyUnit_Hourly      = 1,
    NavigationNodeFrequencyUnit_Daily       = 2,
    NavigationNodeFrequencyUnit_Weekly      = 3,
    NavigationNodeFrequencyUnit_Monthly     = 4,
};

@class WMNavigationStage, WMWoundType;

@interface WMNavigationNode : _WMNavigationNode {}

@property (readonly, nonatomic) NSArray *sortedSubnodes;
@property (readonly) NavigationNodeIdentifier navigationNodeIdentifier;
@property NavigationNodeFrequencyUnit frequencyUnitValue;
@property (readonly, nonatomic) NSString *frequencyUnitForDisplay;
@property NavigationNodeFrequencyUnit closeUnitValue;
@property (readonly, nonatomic) NSString *closeUnitForDisplay;
@property (nonatomic, getter = isRequired) BOOL requiredFlag;
@property (nonatomic) BOOL hidesStatusIndicator;

- (BOOL)requiresIAPForWoundType:(WMWoundType *)woundType;

+ (WMNavigationNode *)updateNodeFromDictionary:(NSDictionary *)dictionary
                                         stage:(WMNavigationStage *)stage
                                    parentNode:(WMNavigationNode *)parentNode
                                        create:(BOOL)create;

+ (void)seedPatientNodes:(NSManagedObjectContext *)managedObjectContext;
+ (void)seedWoundNodes:(NSManagedObjectContext *)managedObjectContext;
+ (NSArray *)patientNodes:(NSManagedObjectContext *)managedObjectContext;
+ (NSArray *)woundNodes:(NSManagedObjectContext *)managedObjectContext;

+ (NSInteger)navigationNodeCount:(NSManagedObjectContext *)managedObjectContext;
+ (WMNavigationNode *)navigationNodeForTaskIdentifier:(NSInteger)navigationNodeIdentifier
                               constrainToPatientFlag:(BOOL)constrainToPatientFlag
                                 constrainToWoundFlag:(BOOL)constrainToWoundFlag
                                 managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (WMNavigationNode *)addPatientNavigationNode:(NSManagedObjectContext *)managedObjectContext;
+ (WMNavigationNode *)selectPatientNavigationNode:(NSManagedObjectContext *)managedObjectContext;
+ (WMNavigationNode *)editPatientNavigationNode:(NSManagedObjectContext *)managedObjectContext;
+ (WMNavigationNode *)addWoundNavigationNode:(NSManagedObjectContext *)managedObjectContext;
+ (WMNavigationNode *)selectWoundNavigationNode:(NSManagedObjectContext *)managedObjectContext;
+ (WMNavigationNode *)editWoundNavigationNode:(NSManagedObjectContext *)managedObjectContext;
+ (WMNavigationNode *)initialStageNavigationNode:(NSManagedObjectContext *)managedObjectContext;
+ (WMNavigationNode *)followupStageNavigationNode:(NSManagedObjectContext *)managedObjectContext;
+ (WMNavigationNode *)dischargeStageNavigationNode:(NSManagedObjectContext *)managedObjectContext;

+ (WMNavigationNode *)carePlanNavigationNode:(NSManagedObjectContext *)managedObjectContext;

+ (WMNavigationNode *)browsePhotosNavigationNode:(NSManagedObjectContext *)managedObjectContext;
+ (WMNavigationNode *)viewGraphsNavigationNode:(NSManagedObjectContext *)managedObjectContext;
+ (WMNavigationNode *)shareNavigationNode:(NSManagedObjectContext *)managedObjectContext;

+ (NSArray *)sortedRootNodesForStage:(WMNavigationStage *)navigationStage;

+ (WMNavigationNode *)nodeForTitle:(NSString *)title
                             stage:(WMNavigationStage *)stage
                        parentNode:(WMNavigationNode *)parentNode
                            create:(BOOL)create;

+ (WMNavigationNode *)nodeForIdentifier:(NSInteger)taskIdentifier
                                  stage:(WMNavigationStage *)stage
                             parentNode:(WMNavigationNode *)parentNode
                                 create:(BOOL)create;

@end
