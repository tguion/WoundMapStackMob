#import "_WMDefinition.h"

typedef enum {
    WoundPUMPScopeAll                   = 0,
    WoundPUMPScopeWoundType             = 1,
    WoundPUMPScopeWoundAssessment       = 2,
    WoundPUMPScopeMedications           = 3,
    WoundPUMPScopeSkinAssessment        = 4,
    WoundPUMPScopeWoundMeasurement      = 5,
    WoundPUMPScopeWoundTreatment        = 6,
    WoundPUMPScopeWoundPosition         = 7,
    WoundPUMPScopeWoundCarePlan         = 8,
    WoundPUMPScopeWoundDevice           = 9,
    WoundPUMPScopeWoundLocation         = 10,
    WoundPUMPScopeWoundUandT            = 11,
    WoundPUMPScopeWoundPsychSocial      = 12,
} WoundPUMPScope;

@interface WMDefinition : _WMDefinition {}

+ (NSInteger)definitionsCount:(NSManagedObjectContext *)managedObjectContext
              persistentStore:(NSPersistentStore *)store;

+ (WMDefinition *)definitionForTerm:(NSString *)term
                         definition:(NSString *)definition
                              scope:(WoundPUMPScope)scope
                             create:(BOOL)create
               managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                    persistentStore:(NSPersistentStore *)store;

+ (NSInteger)updateKeywords:(WMDefinition *)definition
                  inserting:(BOOL)inserting
       managedObjectContext:(NSManagedObjectContext *)managedObjectContext
            persistentStore:(NSPersistentStore *)store;

+ (NSInteger)addWordsAsKeywords:(WMDefinition *)definition
                          words:(NSArray *)words
           managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                persistentStore:(NSPersistentStore *)store;

+ (NSPredicate *)predicateForSearchInput:(NSString *)searchString;
+ (NSPredicate *)predicateForSearchInput:(NSString *)searchString section:(WoundPUMPScope)woundPUMPScope;

+ (void)seedDatabase:(NSManagedObjectContext *)managedObjectContext persistentStore:(NSPersistentStore *)store;

@end
