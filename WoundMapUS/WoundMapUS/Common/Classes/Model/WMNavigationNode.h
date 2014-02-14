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

- (void)updateFromNavigationNode:(WMNavigationNode *)navigationNode
      targetManagedObjectContext:(NSManagedObjectContext *)targetManagedObjectContext
          targetPersistenceStore:(NSPersistentStore *)targetStore;

- (BOOL)requiresIAPForWoundType:(WMWoundType *)woundType;

+ (id)instanceWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                       persistentStore:(NSPersistentStore *)store;

+ (WMNavigationNode *)updateNodeFromDictionary:(NSDictionary *)dictionary
                                         stage:(WMNavigationStage *)stage
                                    parentNode:(WMNavigationNode *)parentNode
                                        create:(BOOL)create
                          managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                               persistentStore:(NSPersistentStore *)store;

+ (void)seedPatientNodes:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;
+ (void)seedWoundNodes:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;
+ (NSArray *)patientNodes:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;
+ (NSArray *)woundNodes:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;

+ (NSInteger)navigationNodeCount:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;
+ (WMNavigationNode *)navigationNodeForTaskIdentifier:(NSInteger)navigationNodeIdentifier
                               constrainToPatientFlag:(BOOL)constrainToPatientFlag
                                 constrainToWoundFlag:(BOOL)constrainToWoundFlag
                                 managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                      persistentStore:(NSPersistentStore *)store;
+ (WMNavigationNode *)addPatientNavigationNode:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;
+ (WMNavigationNode *)selectPatientNavigationNode:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;
+ (WMNavigationNode *)editPatientNavigationNode:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;
+ (WMNavigationNode *)addWoundNavigationNode:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;
+ (WMNavigationNode *)selectWoundNavigationNode:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;
+ (WMNavigationNode *)editWoundNavigationNode:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;
+ (WMNavigationNode *)initialStageNavigationNode:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;
+ (WMNavigationNode *)followupStageNavigationNode:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;
+ (WMNavigationNode *)dischargeStageNavigationNode:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;

+ (WMNavigationNode *)carePlanNavigationNode:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;

+ (WMNavigationNode *)browsePhotosNavigationNode:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;
+ (WMNavigationNode *)viewGraphsNavigationNode:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;
+ (WMNavigationNode *)shareNavigationNode:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;

+ (NSArray *)sortedRootNodesForStage:(WMNavigationStage *)navigationStage;

+ (WMNavigationNode *)nodeForTitle:(NSString *)title
                             stage:(WMNavigationStage *)stage
                        parentNode:(WMNavigationNode *)parentNode
                            create:(BOOL)create
              managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                   persistentStore:(NSPersistentStore *)store;

+ (WMNavigationNode *)nodeForIdentifier:(NSInteger)taskIdentifier
                                  stage:(WMNavigationStage *)stage
                             parentNode:(WMNavigationNode *)parentNode
                                 create:(BOOL)create
                   managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                        persistentStore:(NSPersistentStore *)store;

@end
