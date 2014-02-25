// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundType.h instead.

#import <CoreData/CoreData.h>


extern const struct WMWoundTypeAttributes {
	__unsafe_unretained NSString *createddate;
	__unsafe_unretained NSString *definition;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *label;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *loincCode;
	__unsafe_unretained NSString *options;
	__unsafe_unretained NSString *placeHolder;
	__unsafe_unretained NSString *sectionTitle;
	__unsafe_unretained NSString *snomedCID;
	__unsafe_unretained NSString *snomedFSN;
	__unsafe_unretained NSString *sortRank;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *valueTypeCode;
	__unsafe_unretained NSString *wmwoundtype_id;
	__unsafe_unretained NSString *woundTypeCode;
} WMWoundTypeAttributes;

extern const struct WMWoundTypeRelationships {
	__unsafe_unretained NSString *children;
	__unsafe_unretained NSString *deviceCategories;
	__unsafe_unretained NSString *iapProducts;
	__unsafe_unretained NSString *medicationCategories;
	__unsafe_unretained NSString *parent;
	__unsafe_unretained NSString *woundMeasurements;
	__unsafe_unretained NSString *wounds;
} WMWoundTypeRelationships;

extern const struct WMWoundTypeFetchedProperties {
} WMWoundTypeFetchedProperties;

@class WMWoundType;
@class WMDeviceCategory;
@class IAPProduct;
@class WMMedicationCategory;
@class WMWoundType;
@class WMWoundMeasurement;
@class WMWound;


















@interface WMWoundTypeID : NSManagedObjectID {}
@end

@interface _WMWoundType : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMWoundTypeID*)objectID;





@property (nonatomic, strong) NSDate* createddate;



//- (BOOL)validateCreateddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* definition;



//- (BOOL)validateDefinition:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* label;



//- (BOOL)validateLabel:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastmoddate;



//- (BOOL)validateLastmoddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* loincCode;



//- (BOOL)validateLoincCode:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* options;



//- (BOOL)validateOptions:(id*)value_ error:(NSError**)error_;





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





@property (nonatomic, strong) NSNumber* valueTypeCode;



@property int16_t valueTypeCodeValue;
- (int16_t)valueTypeCodeValue;
- (void)setValueTypeCodeValue:(int16_t)value_;

//- (BOOL)validateValueTypeCode:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wmwoundtype_id;



//- (BOOL)validateWmwoundtype_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* woundTypeCode;



@property int16_t woundTypeCodeValue;
- (int16_t)woundTypeCodeValue;
- (void)setWoundTypeCodeValue:(int16_t)value_;

//- (BOOL)validateWoundTypeCode:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *children;

- (NSMutableSet*)childrenSet;




@property (nonatomic, strong) NSSet *deviceCategories;

- (NSMutableSet*)deviceCategoriesSet;




@property (nonatomic, strong) NSSet *iapProducts;

- (NSMutableSet*)iapProductsSet;




@property (nonatomic, strong) NSSet *medicationCategories;

- (NSMutableSet*)medicationCategoriesSet;




@property (nonatomic, strong) WMWoundType *parent;

//- (BOOL)validateParent:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *woundMeasurements;

- (NSMutableSet*)woundMeasurementsSet;




@property (nonatomic, strong) NSSet *wounds;

- (NSMutableSet*)woundsSet;





@end

@interface _WMWoundType (CoreDataGeneratedAccessors)

- (void)addChildren:(NSSet*)value_;
- (void)removeChildren:(NSSet*)value_;
- (void)addChildrenObject:(WMWoundType*)value_;
- (void)removeChildrenObject:(WMWoundType*)value_;

- (void)addDeviceCategories:(NSSet*)value_;
- (void)removeDeviceCategories:(NSSet*)value_;
- (void)addDeviceCategoriesObject:(WMDeviceCategory*)value_;
- (void)removeDeviceCategoriesObject:(WMDeviceCategory*)value_;

- (void)addIapProducts:(NSSet*)value_;
- (void)removeIapProducts:(NSSet*)value_;
- (void)addIapProductsObject:(IAPProduct*)value_;
- (void)removeIapProductsObject:(IAPProduct*)value_;

- (void)addMedicationCategories:(NSSet*)value_;
- (void)removeMedicationCategories:(NSSet*)value_;
- (void)addMedicationCategoriesObject:(WMMedicationCategory*)value_;
- (void)removeMedicationCategoriesObject:(WMMedicationCategory*)value_;

- (void)addWoundMeasurements:(NSSet*)value_;
- (void)removeWoundMeasurements:(NSSet*)value_;
- (void)addWoundMeasurementsObject:(WMWoundMeasurement*)value_;
- (void)removeWoundMeasurementsObject:(WMWoundMeasurement*)value_;

- (void)addWounds:(NSSet*)value_;
- (void)removeWounds:(NSSet*)value_;
- (void)addWoundsObject:(WMWound*)value_;
- (void)removeWoundsObject:(WMWound*)value_;

@end

@interface _WMWoundType (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreateddate;
- (void)setPrimitiveCreateddate:(NSDate*)value;




- (NSString*)primitiveDefinition;
- (void)setPrimitiveDefinition:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSString*)primitiveLabel;
- (void)setPrimitiveLabel:(NSString*)value;




- (NSDate*)primitiveLastmoddate;
- (void)setPrimitiveLastmoddate:(NSDate*)value;




- (NSString*)primitiveLoincCode;
- (void)setPrimitiveLoincCode:(NSString*)value;




- (NSString*)primitiveOptions;
- (void)setPrimitiveOptions:(NSString*)value;




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




- (NSNumber*)primitiveValueTypeCode;
- (void)setPrimitiveValueTypeCode:(NSNumber*)value;

- (int16_t)primitiveValueTypeCodeValue;
- (void)setPrimitiveValueTypeCodeValue:(int16_t)value_;




- (NSString*)primitiveWmwoundtype_id;
- (void)setPrimitiveWmwoundtype_id:(NSString*)value;




- (NSNumber*)primitiveWoundTypeCode;
- (void)setPrimitiveWoundTypeCode:(NSNumber*)value;

- (int16_t)primitiveWoundTypeCodeValue;
- (void)setPrimitiveWoundTypeCodeValue:(int16_t)value_;





- (NSMutableSet*)primitiveChildren;
- (void)setPrimitiveChildren:(NSMutableSet*)value;



- (NSMutableSet*)primitiveDeviceCategories;
- (void)setPrimitiveDeviceCategories:(NSMutableSet*)value;



- (NSMutableSet*)primitiveIapProducts;
- (void)setPrimitiveIapProducts:(NSMutableSet*)value;



- (NSMutableSet*)primitiveMedicationCategories;
- (void)setPrimitiveMedicationCategories:(NSMutableSet*)value;



- (WMWoundType*)primitiveParent;
- (void)setPrimitiveParent:(WMWoundType*)value;



- (NSMutableSet*)primitiveWoundMeasurements;
- (void)setPrimitiveWoundMeasurements:(NSMutableSet*)value;



- (NSMutableSet*)primitiveWounds;
- (void)setPrimitiveWounds:(NSMutableSet*)value;


@end
