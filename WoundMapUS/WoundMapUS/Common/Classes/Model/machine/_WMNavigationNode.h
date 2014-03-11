// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMNavigationNode.h instead.

#import <CoreData/CoreData.h>


extern const struct WMNavigationNodeAttributes {
	__unsafe_unretained NSString *activeFlag;
	__unsafe_unretained NSString *closeUnit;
	__unsafe_unretained NSString *closeValue;
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *desc;
	__unsafe_unretained NSString *disabledFlag;
	__unsafe_unretained NSString *displayTitle;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *frequencyUnit;
	__unsafe_unretained NSString *frequencyValue;
	__unsafe_unretained NSString *iapIdentifier;
	__unsafe_unretained NSString *icon;
	__unsafe_unretained NSString *patientFlag;
	__unsafe_unretained NSString *requiresPatientFlag;
	__unsafe_unretained NSString *requiresWoundFlag;
	__unsafe_unretained NSString *requiresWoundPhotoFlag;
	__unsafe_unretained NSString *sortRank;
	__unsafe_unretained NSString *taskIdentifier;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *updatedAt;
	__unsafe_unretained NSString *userSortRank;
	__unsafe_unretained NSString *woundFlag;
	__unsafe_unretained NSString *woundTypeCodes;
} WMNavigationNodeAttributes;

extern const struct WMNavigationNodeRelationships {
	__unsafe_unretained NSString *parentNode;
	__unsafe_unretained NSString *stage;
	__unsafe_unretained NSString *subnodes;
} WMNavigationNodeRelationships;

extern const struct WMNavigationNodeFetchedProperties {
} WMNavigationNodeFetchedProperties;

@class WMNavigationNode;
@class WMNavigationStage;
@class WMNavigationNode;


























@interface WMNavigationNodeID : NSManagedObjectID {}
@end

@interface _WMNavigationNode : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMNavigationNodeID*)objectID;





@property (nonatomic, strong) NSNumber* activeFlag;



@property BOOL activeFlagValue;
- (BOOL)activeFlagValue;
- (void)setActiveFlagValue:(BOOL)value_;

//- (BOOL)validateActiveFlag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* closeUnit;



@property int16_t closeUnitValue;
- (int16_t)closeUnitValue;
- (void)setCloseUnitValue:(int16_t)value_;

//- (BOOL)validateCloseUnit:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* closeValue;



@property int16_t closeValueValue;
- (int16_t)closeValueValue;
- (void)setCloseValueValue:(int16_t)value_;

//- (BOOL)validateCloseValue:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* desc;



//- (BOOL)validateDesc:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* disabledFlag;



@property BOOL disabledFlagValue;
- (BOOL)disabledFlagValue;
- (void)setDisabledFlagValue:(BOOL)value_;

//- (BOOL)validateDisabledFlag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* displayTitle;



//- (BOOL)validateDisplayTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* frequencyUnit;



@property int16_t frequencyUnitValue;
- (int16_t)frequencyUnitValue;
- (void)setFrequencyUnitValue:(int16_t)value_;

//- (BOOL)validateFrequencyUnit:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* frequencyValue;



@property int16_t frequencyValueValue;
- (int16_t)frequencyValueValue;
- (void)setFrequencyValueValue:(int16_t)value_;

//- (BOOL)validateFrequencyValue:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* iapIdentifier;



//- (BOOL)validateIapIdentifier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* icon;



//- (BOOL)validateIcon:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* patientFlag;



@property BOOL patientFlagValue;
- (BOOL)patientFlagValue;
- (void)setPatientFlagValue:(BOOL)value_;

//- (BOOL)validatePatientFlag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* requiresPatientFlag;



@property BOOL requiresPatientFlagValue;
- (BOOL)requiresPatientFlagValue;
- (void)setRequiresPatientFlagValue:(BOOL)value_;

//- (BOOL)validateRequiresPatientFlag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* requiresWoundFlag;



@property BOOL requiresWoundFlagValue;
- (BOOL)requiresWoundFlagValue;
- (void)setRequiresWoundFlagValue:(BOOL)value_;

//- (BOOL)validateRequiresWoundFlag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* requiresWoundPhotoFlag;



@property BOOL requiresWoundPhotoFlagValue;
- (BOOL)requiresWoundPhotoFlagValue;
- (void)setRequiresWoundPhotoFlagValue:(BOOL)value_;

//- (BOOL)validateRequiresWoundPhotoFlag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sortRank;



@property int16_t sortRankValue;
- (int16_t)sortRankValue;
- (void)setSortRankValue:(int16_t)value_;

//- (BOOL)validateSortRank:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* taskIdentifier;



@property int16_t taskIdentifierValue;
- (int16_t)taskIdentifierValue;
- (void)setTaskIdentifierValue:(int16_t)value_;

//- (BOOL)validateTaskIdentifier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* userSortRank;



@property int16_t userSortRankValue;
- (int16_t)userSortRankValue;
- (void)setUserSortRankValue:(int16_t)value_;

//- (BOOL)validateUserSortRank:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* woundFlag;



@property BOOL woundFlagValue;
- (BOOL)woundFlagValue;
- (void)setWoundFlagValue:(BOOL)value_;

//- (BOOL)validateWoundFlag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* woundTypeCodes;



//- (BOOL)validateWoundTypeCodes:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMNavigationNode *parentNode;

//- (BOOL)validateParentNode:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMNavigationStage *stage;

//- (BOOL)validateStage:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *subnodes;

- (NSMutableSet*)subnodesSet;





@end

@interface _WMNavigationNode (CoreDataGeneratedAccessors)

- (void)addSubnodes:(NSSet*)value_;
- (void)removeSubnodes:(NSSet*)value_;
- (void)addSubnodesObject:(WMNavigationNode*)value_;
- (void)removeSubnodesObject:(WMNavigationNode*)value_;

@end

@interface _WMNavigationNode (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveActiveFlag;
- (void)setPrimitiveActiveFlag:(NSNumber*)value;

- (BOOL)primitiveActiveFlagValue;
- (void)setPrimitiveActiveFlagValue:(BOOL)value_;




- (NSNumber*)primitiveCloseUnit;
- (void)setPrimitiveCloseUnit:(NSNumber*)value;

- (int16_t)primitiveCloseUnitValue;
- (void)setPrimitiveCloseUnitValue:(int16_t)value_;




- (NSNumber*)primitiveCloseValue;
- (void)setPrimitiveCloseValue:(NSNumber*)value;

- (int16_t)primitiveCloseValueValue;
- (void)setPrimitiveCloseValueValue:(int16_t)value_;




- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSString*)primitiveDesc;
- (void)setPrimitiveDesc:(NSString*)value;




- (NSNumber*)primitiveDisabledFlag;
- (void)setPrimitiveDisabledFlag:(NSNumber*)value;

- (BOOL)primitiveDisabledFlagValue;
- (void)setPrimitiveDisabledFlagValue:(BOOL)value_;




- (NSString*)primitiveDisplayTitle;
- (void)setPrimitiveDisplayTitle:(NSString*)value;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSNumber*)primitiveFrequencyUnit;
- (void)setPrimitiveFrequencyUnit:(NSNumber*)value;

- (int16_t)primitiveFrequencyUnitValue;
- (void)setPrimitiveFrequencyUnitValue:(int16_t)value_;




- (NSNumber*)primitiveFrequencyValue;
- (void)setPrimitiveFrequencyValue:(NSNumber*)value;

- (int16_t)primitiveFrequencyValueValue;
- (void)setPrimitiveFrequencyValueValue:(int16_t)value_;




- (NSString*)primitiveIapIdentifier;
- (void)setPrimitiveIapIdentifier:(NSString*)value;




- (NSString*)primitiveIcon;
- (void)setPrimitiveIcon:(NSString*)value;




- (NSNumber*)primitivePatientFlag;
- (void)setPrimitivePatientFlag:(NSNumber*)value;

- (BOOL)primitivePatientFlagValue;
- (void)setPrimitivePatientFlagValue:(BOOL)value_;




- (NSNumber*)primitiveRequiresPatientFlag;
- (void)setPrimitiveRequiresPatientFlag:(NSNumber*)value;

- (BOOL)primitiveRequiresPatientFlagValue;
- (void)setPrimitiveRequiresPatientFlagValue:(BOOL)value_;




- (NSNumber*)primitiveRequiresWoundFlag;
- (void)setPrimitiveRequiresWoundFlag:(NSNumber*)value;

- (BOOL)primitiveRequiresWoundFlagValue;
- (void)setPrimitiveRequiresWoundFlagValue:(BOOL)value_;




- (NSNumber*)primitiveRequiresWoundPhotoFlag;
- (void)setPrimitiveRequiresWoundPhotoFlag:(NSNumber*)value;

- (BOOL)primitiveRequiresWoundPhotoFlagValue;
- (void)setPrimitiveRequiresWoundPhotoFlagValue:(BOOL)value_;




- (NSNumber*)primitiveSortRank;
- (void)setPrimitiveSortRank:(NSNumber*)value;

- (int16_t)primitiveSortRankValue;
- (void)setPrimitiveSortRankValue:(int16_t)value_;




- (NSNumber*)primitiveTaskIdentifier;
- (void)setPrimitiveTaskIdentifier:(NSNumber*)value;

- (int16_t)primitiveTaskIdentifierValue;
- (void)setPrimitiveTaskIdentifierValue:(int16_t)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;




- (NSNumber*)primitiveUserSortRank;
- (void)setPrimitiveUserSortRank:(NSNumber*)value;

- (int16_t)primitiveUserSortRankValue;
- (void)setPrimitiveUserSortRankValue:(int16_t)value_;




- (NSNumber*)primitiveWoundFlag;
- (void)setPrimitiveWoundFlag:(NSNumber*)value;

- (BOOL)primitiveWoundFlagValue;
- (void)setPrimitiveWoundFlagValue:(BOOL)value_;




- (NSString*)primitiveWoundTypeCodes;
- (void)setPrimitiveWoundTypeCodes:(NSString*)value;





- (WMNavigationNode*)primitiveParentNode;
- (void)setPrimitiveParentNode:(WMNavigationNode*)value;



- (WMNavigationStage*)primitiveStage;
- (void)setPrimitiveStage:(WMNavigationStage*)value;



- (NSMutableSet*)primitiveSubnodes;
- (void)setPrimitiveSubnodes:(NSMutableSet*)value;


@end
