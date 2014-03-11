// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWound.h instead.

#import <CoreData/CoreData.h>


extern const struct WMWoundAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *desc;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *sortRank;
	__unsafe_unretained NSString *updatedAt;
	__unsafe_unretained NSString *woundLocationValue;
	__unsafe_unretained NSString *woundTypeValue;
} WMWoundAttributes;

extern const struct WMWoundRelationships {
	__unsafe_unretained NSString *locationValue;
	__unsafe_unretained NSString *measurementGroups;
	__unsafe_unretained NSString *patient;
	__unsafe_unretained NSString *photos;
	__unsafe_unretained NSString *positionValues;
	__unsafe_unretained NSString *treatmentGroups;
	__unsafe_unretained NSString *woundType;
} WMWoundRelationships;

extern const struct WMWoundFetchedProperties {
} WMWoundFetchedProperties;

@class WMWoundLocationValue;
@class WMWoundMeasurementGroup;
@class WMPatient;
@class WMWoundPhoto;
@class WMWoundPositionValue;
@class WMWoundTreatmentGroup;
@class WMWoundType;











@interface WMWoundID : NSManagedObjectID {}
@end

@interface _WMWound : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMWoundID*)objectID;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* desc;



//- (BOOL)validateDesc:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sortRank;



@property int16_t sortRankValue;
- (int16_t)sortRankValue;
- (void)setSortRankValue:(int16_t)value_;

//- (BOOL)validateSortRank:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* woundLocationValue;



//- (BOOL)validateWoundLocationValue:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* woundTypeValue;



//- (BOOL)validateWoundTypeValue:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMWoundLocationValue *locationValue;

//- (BOOL)validateLocationValue:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *measurementGroups;

- (NSMutableSet*)measurementGroupsSet;




@property (nonatomic, strong) WMPatient *patient;

//- (BOOL)validatePatient:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *photos;

- (NSMutableSet*)photosSet;




@property (nonatomic, strong) NSSet *positionValues;

- (NSMutableSet*)positionValuesSet;




@property (nonatomic, strong) NSSet *treatmentGroups;

- (NSMutableSet*)treatmentGroupsSet;




@property (nonatomic, strong) WMWoundType *woundType;

//- (BOOL)validateWoundType:(id*)value_ error:(NSError**)error_;





@end

@interface _WMWound (CoreDataGeneratedAccessors)

- (void)addMeasurementGroups:(NSSet*)value_;
- (void)removeMeasurementGroups:(NSSet*)value_;
- (void)addMeasurementGroupsObject:(WMWoundMeasurementGroup*)value_;
- (void)removeMeasurementGroupsObject:(WMWoundMeasurementGroup*)value_;

- (void)addPhotos:(NSSet*)value_;
- (void)removePhotos:(NSSet*)value_;
- (void)addPhotosObject:(WMWoundPhoto*)value_;
- (void)removePhotosObject:(WMWoundPhoto*)value_;

- (void)addPositionValues:(NSSet*)value_;
- (void)removePositionValues:(NSSet*)value_;
- (void)addPositionValuesObject:(WMWoundPositionValue*)value_;
- (void)removePositionValuesObject:(WMWoundPositionValue*)value_;

- (void)addTreatmentGroups:(NSSet*)value_;
- (void)removeTreatmentGroups:(NSSet*)value_;
- (void)addTreatmentGroupsObject:(WMWoundTreatmentGroup*)value_;
- (void)removeTreatmentGroupsObject:(WMWoundTreatmentGroup*)value_;

@end

@interface _WMWound (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSString*)primitiveDesc;
- (void)setPrimitiveDesc:(NSString*)value;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveSortRank;
- (void)setPrimitiveSortRank:(NSNumber*)value;

- (int16_t)primitiveSortRankValue;
- (void)setPrimitiveSortRankValue:(int16_t)value_;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;




- (NSString*)primitiveWoundLocationValue;
- (void)setPrimitiveWoundLocationValue:(NSString*)value;




- (NSString*)primitiveWoundTypeValue;
- (void)setPrimitiveWoundTypeValue:(NSString*)value;





- (WMWoundLocationValue*)primitiveLocationValue;
- (void)setPrimitiveLocationValue:(WMWoundLocationValue*)value;



- (NSMutableSet*)primitiveMeasurementGroups;
- (void)setPrimitiveMeasurementGroups:(NSMutableSet*)value;



- (WMPatient*)primitivePatient;
- (void)setPrimitivePatient:(WMPatient*)value;



- (NSMutableSet*)primitivePhotos;
- (void)setPrimitivePhotos:(NSMutableSet*)value;



- (NSMutableSet*)primitivePositionValues;
- (void)setPrimitivePositionValues:(NSMutableSet*)value;



- (NSMutableSet*)primitiveTreatmentGroups;
- (void)setPrimitiveTreatmentGroups:(NSMutableSet*)value;



- (WMWoundType*)primitiveWoundType;
- (void)setPrimitiveWoundType:(WMWoundType*)value;


@end
