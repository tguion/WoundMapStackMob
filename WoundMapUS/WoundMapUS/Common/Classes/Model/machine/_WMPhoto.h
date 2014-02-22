// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMPhoto.h instead.

#import <CoreData/CoreData.h>


extern const struct WMPhotoAttributes {
	__unsafe_unretained NSString *column;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *originalFlag;
	__unsafe_unretained NSString *photo;
	__unsafe_unretained NSString *row;
	__unsafe_unretained NSString *scale;
	__unsafe_unretained NSString *sortRank;
	__unsafe_unretained NSString *tileFlag;
} WMPhotoAttributes;

extern const struct WMPhotoRelationships {
	__unsafe_unretained NSString *woundPhoto;
} WMPhotoRelationships;

extern const struct WMPhotoFetchedProperties {
} WMPhotoFetchedProperties;

@class WMWoundPhoto;










@interface WMPhotoID : NSManagedObjectID {}
@end

@interface _WMPhoto : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMPhotoID*)objectID;





@property (nonatomic, strong) NSNumber* column;



@property int16_t columnValue;
- (int16_t)columnValue;
- (void)setColumnValue:(int16_t)value_;

//- (BOOL)validateColumn:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* originalFlag;



@property BOOL originalFlagValue;
- (BOOL)originalFlagValue;
- (void)setOriginalFlagValue:(BOOL)value_;

//- (BOOL)validateOriginalFlag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* photo;



//- (BOOL)validatePhoto:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* row;



@property int16_t rowValue;
- (int16_t)rowValue;
- (void)setRowValue:(int16_t)value_;

//- (BOOL)validateRow:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* scale;



@property int16_t scaleValue;
- (int16_t)scaleValue;
- (void)setScaleValue:(int16_t)value_;

//- (BOOL)validateScale:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sortRank;



@property int16_t sortRankValue;
- (int16_t)sortRankValue;
- (void)setSortRankValue:(int16_t)value_;

//- (BOOL)validateSortRank:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* tileFlag;



@property BOOL tileFlagValue;
- (BOOL)tileFlagValue;
- (void)setTileFlagValue:(BOOL)value_;

//- (BOOL)validateTileFlag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMWoundPhoto *woundPhoto;

//- (BOOL)validateWoundPhoto:(id*)value_ error:(NSError**)error_;





@end

@interface _WMPhoto (CoreDataGeneratedAccessors)

@end

@interface _WMPhoto (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveColumn;
- (void)setPrimitiveColumn:(NSNumber*)value;

- (int16_t)primitiveColumnValue;
- (void)setPrimitiveColumnValue:(int16_t)value_;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSNumber*)primitiveOriginalFlag;
- (void)setPrimitiveOriginalFlag:(NSNumber*)value;

- (BOOL)primitiveOriginalFlagValue;
- (void)setPrimitiveOriginalFlagValue:(BOOL)value_;




- (NSString*)primitivePhoto;
- (void)setPrimitivePhoto:(NSString*)value;




- (NSNumber*)primitiveRow;
- (void)setPrimitiveRow:(NSNumber*)value;

- (int16_t)primitiveRowValue;
- (void)setPrimitiveRowValue:(int16_t)value_;




- (NSNumber*)primitiveScale;
- (void)setPrimitiveScale:(NSNumber*)value;

- (int16_t)primitiveScaleValue;
- (void)setPrimitiveScaleValue:(int16_t)value_;




- (NSNumber*)primitiveSortRank;
- (void)setPrimitiveSortRank:(NSNumber*)value;

- (int16_t)primitiveSortRankValue;
- (void)setPrimitiveSortRankValue:(int16_t)value_;




- (NSNumber*)primitiveTileFlag;
- (void)setPrimitiveTileFlag:(NSNumber*)value;

- (BOOL)primitiveTileFlagValue;
- (void)setPrimitiveTileFlagValue:(BOOL)value_;





- (WMWoundPhoto*)primitiveWoundPhoto;
- (void)setPrimitiveWoundPhoto:(WMWoundPhoto*)value;


@end
