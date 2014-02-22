// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWound.h instead.

#import <CoreData/CoreData.h>


extern const struct WMWoundAttributes {
	__unsafe_unretained NSString *createddate;
	__unsafe_unretained NSString *dateCreated;
	__unsafe_unretained NSString *desc;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *sortRank;
	__unsafe_unretained NSString *wmwound_id;
	__unsafe_unretained NSString *woundLocationValue;
	__unsafe_unretained NSString *woundTypeValue;
} WMWoundAttributes;

extern const struct WMWoundRelationships {
	__unsafe_unretained NSString *patient;
	__unsafe_unretained NSString *photos;
	__unsafe_unretained NSString *woundType;
} WMWoundRelationships;

extern const struct WMWoundFetchedProperties {
} WMWoundFetchedProperties;

@class WMPatient;
@class WMWoundPhoto;
@class WMWoundType;












@interface WMWoundID : NSManagedObjectID {}
@end

@interface _WMWound : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMWoundID*)objectID;





@property (nonatomic, strong) NSDate* createddate;



//- (BOOL)validateCreateddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateCreated;



//- (BOOL)validateDateCreated:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* desc;



//- (BOOL)validateDesc:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastmoddate;



//- (BOOL)validateLastmoddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sortRank;



@property int16_t sortRankValue;
- (int16_t)sortRankValue;
- (void)setSortRankValue:(int16_t)value_;

//- (BOOL)validateSortRank:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wmwound_id;



//- (BOOL)validateWmwound_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* woundLocationValue;



//- (BOOL)validateWoundLocationValue:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* woundTypeValue;



//- (BOOL)validateWoundTypeValue:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMPatient *patient;

//- (BOOL)validatePatient:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *photos;

- (NSMutableSet*)photosSet;




@property (nonatomic, strong) WMWoundType *woundType;

//- (BOOL)validateWoundType:(id*)value_ error:(NSError**)error_;





@end

@interface _WMWound (CoreDataGeneratedAccessors)

- (void)addPhotos:(NSSet*)value_;
- (void)removePhotos:(NSSet*)value_;
- (void)addPhotosObject:(WMWoundPhoto*)value_;
- (void)removePhotosObject:(WMWoundPhoto*)value_;

@end

@interface _WMWound (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreateddate;
- (void)setPrimitiveCreateddate:(NSDate*)value;




- (NSDate*)primitiveDateCreated;
- (void)setPrimitiveDateCreated:(NSDate*)value;




- (NSString*)primitiveDesc;
- (void)setPrimitiveDesc:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSDate*)primitiveLastmoddate;
- (void)setPrimitiveLastmoddate:(NSDate*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveSortRank;
- (void)setPrimitiveSortRank:(NSNumber*)value;

- (int16_t)primitiveSortRankValue;
- (void)setPrimitiveSortRankValue:(int16_t)value_;




- (NSString*)primitiveWmwound_id;
- (void)setPrimitiveWmwound_id:(NSString*)value;




- (NSString*)primitiveWoundLocationValue;
- (void)setPrimitiveWoundLocationValue:(NSString*)value;




- (NSString*)primitiveWoundTypeValue;
- (void)setPrimitiveWoundTypeValue:(NSString*)value;





- (WMPatient*)primitivePatient;
- (void)setPrimitivePatient:(WMPatient*)value;



- (NSMutableSet*)primitivePhotos;
- (void)setPrimitivePhotos:(NSMutableSet*)value;



- (WMWoundType*)primitiveWoundType;
- (void)setPrimitiveWoundType:(WMWoundType*)value;


@end
