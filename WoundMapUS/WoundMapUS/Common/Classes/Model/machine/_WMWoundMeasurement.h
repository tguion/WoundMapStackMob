// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundMeasurement.h instead.

#import <CoreData/CoreData.h>


extern const struct WMWoundMeasurementAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *definition;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *graphableFlag;
	__unsafe_unretained NSString *iapIdentifier;
	__unsafe_unretained NSString *keyboardType;
	__unsafe_unretained NSString *label;
	__unsafe_unretained NSString *loincCode;
	__unsafe_unretained NSString *placeHolder;
	__unsafe_unretained NSString *sectionTitle;
	__unsafe_unretained NSString *snomedCID;
	__unsafe_unretained NSString *snomedFSN;
	__unsafe_unretained NSString *sortRank;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *unit;
	__unsafe_unretained NSString *updatedAt;
	__unsafe_unretained NSString *valueMaximum;
	__unsafe_unretained NSString *valueMinimum;
	__unsafe_unretained NSString *valueTypeCode;
} WMWoundMeasurementAttributes;

extern const struct WMWoundMeasurementRelationships {
	__unsafe_unretained NSString *childrenMeasurements;
	__unsafe_unretained NSString *parentMeasurement;
	__unsafe_unretained NSString *values;
	__unsafe_unretained NSString *woundTypes;
} WMWoundMeasurementRelationships;

extern const struct WMWoundMeasurementFetchedProperties {
} WMWoundMeasurementFetchedProperties;

@class WMWoundMeasurement;
@class WMWoundMeasurement;
@class WMWoundMeasurementValue;
@class WMWoundType;






















@interface WMWoundMeasurementID : NSManagedObjectID {}
@end

@interface _WMWoundMeasurement : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMWoundMeasurementID*)objectID;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* definition;



//- (BOOL)validateDefinition:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* graphableFlag;



@property BOOL graphableFlagValue;
- (BOOL)graphableFlagValue;
- (void)setGraphableFlagValue:(BOOL)value_;

//- (BOOL)validateGraphableFlag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* iapIdentifier;



//- (BOOL)validateIapIdentifier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* keyboardType;



@property int16_t keyboardTypeValue;
- (int16_t)keyboardTypeValue;
- (void)setKeyboardTypeValue:(int16_t)value_;

//- (BOOL)validateKeyboardType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* label;



//- (BOOL)validateLabel:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* loincCode;



//- (BOOL)validateLoincCode:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* placeHolder;



//- (BOOL)validatePlaceHolder:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* sectionTitle;



//- (BOOL)validateSectionTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* snomedCID;



@property int64_t snomedCIDValue;
- (int64_t)snomedCIDValue;
- (void)setSnomedCIDValue:(int64_t)value_;

//- (BOOL)validateSnomedCID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* snomedFSN;



//- (BOOL)validateSnomedFSN:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sortRank;



@property int16_t sortRankValue;
- (int16_t)sortRankValue;
- (void)setSortRankValue:(int16_t)value_;

//- (BOOL)validateSortRank:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* unit;



//- (BOOL)validateUnit:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* valueMaximum;



@property float valueMaximumValue;
- (float)valueMaximumValue;
- (void)setValueMaximumValue:(float)value_;

//- (BOOL)validateValueMaximum:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* valueMinimum;



@property float valueMinimumValue;
- (float)valueMinimumValue;
- (void)setValueMinimumValue:(float)value_;

//- (BOOL)validateValueMinimum:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* valueTypeCode;



@property int16_t valueTypeCodeValue;
- (int16_t)valueTypeCodeValue;
- (void)setValueTypeCodeValue:(int16_t)value_;

//- (BOOL)validateValueTypeCode:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *childrenMeasurements;

- (NSMutableSet*)childrenMeasurementsSet;




@property (nonatomic, strong) WMWoundMeasurement *parentMeasurement;

//- (BOOL)validateParentMeasurement:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *values;

- (NSMutableSet*)valuesSet;




@property (nonatomic, strong) NSSet *woundTypes;

- (NSMutableSet*)woundTypesSet;





@end

@interface _WMWoundMeasurement (CoreDataGeneratedAccessors)

- (void)addChildrenMeasurements:(NSSet*)value_;
- (void)removeChildrenMeasurements:(NSSet*)value_;
- (void)addChildrenMeasurementsObject:(WMWoundMeasurement*)value_;
- (void)removeChildrenMeasurementsObject:(WMWoundMeasurement*)value_;

- (void)addValues:(NSSet*)value_;
- (void)removeValues:(NSSet*)value_;
- (void)addValuesObject:(WMWoundMeasurementValue*)value_;
- (void)removeValuesObject:(WMWoundMeasurementValue*)value_;

- (void)addWoundTypes:(NSSet*)value_;
- (void)removeWoundTypes:(NSSet*)value_;
- (void)addWoundTypesObject:(WMWoundType*)value_;
- (void)removeWoundTypesObject:(WMWoundType*)value_;

@end

@interface _WMWoundMeasurement (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSString*)primitiveDefinition;
- (void)setPrimitiveDefinition:(NSString*)value;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSNumber*)primitiveGraphableFlag;
- (void)setPrimitiveGraphableFlag:(NSNumber*)value;

- (BOOL)primitiveGraphableFlagValue;
- (void)setPrimitiveGraphableFlagValue:(BOOL)value_;




- (NSString*)primitiveIapIdentifier;
- (void)setPrimitiveIapIdentifier:(NSString*)value;




- (NSNumber*)primitiveKeyboardType;
- (void)setPrimitiveKeyboardType:(NSNumber*)value;

- (int16_t)primitiveKeyboardTypeValue;
- (void)setPrimitiveKeyboardTypeValue:(int16_t)value_;




- (NSString*)primitiveLabel;
- (void)setPrimitiveLabel:(NSString*)value;




- (NSString*)primitiveLoincCode;
- (void)setPrimitiveLoincCode:(NSString*)value;




- (NSString*)primitivePlaceHolder;
- (void)setPrimitivePlaceHolder:(NSString*)value;




- (NSString*)primitiveSectionTitle;
- (void)setPrimitiveSectionTitle:(NSString*)value;




- (NSNumber*)primitiveSnomedCID;
- (void)setPrimitiveSnomedCID:(NSNumber*)value;

- (int64_t)primitiveSnomedCIDValue;
- (void)setPrimitiveSnomedCIDValue:(int64_t)value_;




- (NSString*)primitiveSnomedFSN;
- (void)setPrimitiveSnomedFSN:(NSString*)value;




- (NSNumber*)primitiveSortRank;
- (void)setPrimitiveSortRank:(NSNumber*)value;

- (int16_t)primitiveSortRankValue;
- (void)setPrimitiveSortRankValue:(int16_t)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSString*)primitiveUnit;
- (void)setPrimitiveUnit:(NSString*)value;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;




- (NSNumber*)primitiveValueMaximum;
- (void)setPrimitiveValueMaximum:(NSNumber*)value;

- (float)primitiveValueMaximumValue;
- (void)setPrimitiveValueMaximumValue:(float)value_;




- (NSNumber*)primitiveValueMinimum;
- (void)setPrimitiveValueMinimum:(NSNumber*)value;

- (float)primitiveValueMinimumValue;
- (void)setPrimitiveValueMinimumValue:(float)value_;




- (NSNumber*)primitiveValueTypeCode;
- (void)setPrimitiveValueTypeCode:(NSNumber*)value;

- (int16_t)primitiveValueTypeCodeValue;
- (void)setPrimitiveValueTypeCodeValue:(int16_t)value_;





- (NSMutableSet*)primitiveChildrenMeasurements;
- (void)setPrimitiveChildrenMeasurements:(NSMutableSet*)value;



- (WMWoundMeasurement*)primitiveParentMeasurement;
- (void)setPrimitiveParentMeasurement:(WMWoundMeasurement*)value;



- (NSMutableSet*)primitiveValues;
- (void)setPrimitiveValues:(NSMutableSet*)value;



- (NSMutableSet*)primitiveWoundTypes;
- (void)setPrimitiveWoundTypes:(NSMutableSet*)value;


@end
