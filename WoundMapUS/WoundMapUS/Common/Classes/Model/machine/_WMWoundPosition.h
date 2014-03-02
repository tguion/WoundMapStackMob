// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundPosition.h instead.

#import <CoreData/CoreData.h>


extern const struct WMWoundPositionAttributes {
	__unsafe_unretained NSString *commonTitle;
	__unsafe_unretained NSString *createddate;
	__unsafe_unretained NSString *definition;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *loincCode;
	__unsafe_unretained NSString *prompt;
	__unsafe_unretained NSString *snomedCID;
	__unsafe_unretained NSString *snomedFSN;
	__unsafe_unretained NSString *sortRank;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *valueTypeCode;
	__unsafe_unretained NSString *wmwoundposition_id;
} WMWoundPositionAttributes;

extern const struct WMWoundPositionRelationships {
	__unsafe_unretained NSString *locationJoins;
	__unsafe_unretained NSString *positionValues;
} WMWoundPositionRelationships;

extern const struct WMWoundPositionFetchedProperties {
} WMWoundPositionFetchedProperties;

@class WMWoundLocationPositionJoin;
@class WMWoundPositionValue;















@interface WMWoundPositionID : NSManagedObjectID {}
@end

@interface _WMWoundPosition : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMWoundPositionID*)objectID;





@property (nonatomic, strong) NSString* commonTitle;



//- (BOOL)validateCommonTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* createddate;



//- (BOOL)validateCreateddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* definition;



//- (BOOL)validateDefinition:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastmoddate;



//- (BOOL)validateLastmoddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* loincCode;



//- (BOOL)validateLoincCode:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* prompt;



//- (BOOL)validatePrompt:(id*)value_ error:(NSError**)error_;





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





@property (nonatomic, strong) NSString* wmwoundposition_id;



//- (BOOL)validateWmwoundposition_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *locationJoins;

- (NSMutableSet*)locationJoinsSet;




@property (nonatomic, strong) NSSet *positionValues;

- (NSMutableSet*)positionValuesSet;





@end

@interface _WMWoundPosition (CoreDataGeneratedAccessors)

- (void)addLocationJoins:(NSSet*)value_;
- (void)removeLocationJoins:(NSSet*)value_;
- (void)addLocationJoinsObject:(WMWoundLocationPositionJoin*)value_;
- (void)removeLocationJoinsObject:(WMWoundLocationPositionJoin*)value_;

- (void)addPositionValues:(NSSet*)value_;
- (void)removePositionValues:(NSSet*)value_;
- (void)addPositionValuesObject:(WMWoundPositionValue*)value_;
- (void)removePositionValuesObject:(WMWoundPositionValue*)value_;

@end

@interface _WMWoundPosition (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCommonTitle;
- (void)setPrimitiveCommonTitle:(NSString*)value;




- (NSDate*)primitiveCreateddate;
- (void)setPrimitiveCreateddate:(NSDate*)value;




- (NSString*)primitiveDefinition;
- (void)setPrimitiveDefinition:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSDate*)primitiveLastmoddate;
- (void)setPrimitiveLastmoddate:(NSDate*)value;




- (NSString*)primitiveLoincCode;
- (void)setPrimitiveLoincCode:(NSString*)value;




- (NSString*)primitivePrompt;
- (void)setPrimitivePrompt:(NSString*)value;




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




- (NSString*)primitiveWmwoundposition_id;
- (void)setPrimitiveWmwoundposition_id:(NSString*)value;





- (NSMutableSet*)primitiveLocationJoins;
- (void)setPrimitiveLocationJoins:(NSMutableSet*)value;



- (NSMutableSet*)primitivePositionValues;
- (void)setPrimitivePositionValues:(NSMutableSet*)value;


@end
