// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundPhoto.h instead.

#import <CoreData/CoreData.h>


extern const struct WMWoundPhotoAttributes {
	__unsafe_unretained NSString *comments;
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *imageHeight;
	__unsafe_unretained NSString *imageOrientation;
	__unsafe_unretained NSString *imageWidth;
	__unsafe_unretained NSString *metadata;
	__unsafe_unretained NSString *thumbnail;
	__unsafe_unretained NSString *thumbnailLarge;
	__unsafe_unretained NSString *thumbnailMini;
	__unsafe_unretained NSString *transformAsString;
	__unsafe_unretained NSString *transformRotation;
	__unsafe_unretained NSString *transformScale;
	__unsafe_unretained NSString *transformSizeAsString;
	__unsafe_unretained NSString *transformTranslationX;
	__unsafe_unretained NSString *transformTranslationY;
	__unsafe_unretained NSString *updatedAt;
} WMWoundPhotoAttributes;

extern const struct WMWoundPhotoRelationships {
	__unsafe_unretained NSString *measurementGroups;
	__unsafe_unretained NSString *photos;
	__unsafe_unretained NSString *wound;
} WMWoundPhotoRelationships;

extern const struct WMWoundPhotoFetchedProperties {
} WMWoundPhotoFetchedProperties;

@class WMWoundMeasurementGroup;
@class WMPhoto;
@class WMWound;




















@interface WMWoundPhotoID : NSManagedObjectID {}
@end

@interface _WMWoundPhoto : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMWoundPhotoID*)objectID;





@property (nonatomic, strong) NSString* comments;



//- (BOOL)validateComments:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* imageHeight;



@property float imageHeightValue;
- (float)imageHeightValue;
- (void)setImageHeightValue:(float)value_;

//- (BOOL)validateImageHeight:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* imageOrientation;



@property int16_t imageOrientationValue;
- (int16_t)imageOrientationValue;
- (void)setImageOrientationValue:(int16_t)value_;

//- (BOOL)validateImageOrientation:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* imageWidth;



@property float imageWidthValue;
- (float)imageWidthValue;
- (void)setImageWidthValue:(float)value_;

//- (BOOL)validateImageWidth:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* metadata;



//- (BOOL)validateMetadata:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* thumbnail;



//- (BOOL)validateThumbnail:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* thumbnailLarge;



//- (BOOL)validateThumbnailLarge:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* thumbnailMini;



//- (BOOL)validateThumbnailMini:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* transformAsString;



//- (BOOL)validateTransformAsString:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* transformRotation;



@property float transformRotationValue;
- (float)transformRotationValue;
- (void)setTransformRotationValue:(float)value_;

//- (BOOL)validateTransformRotation:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* transformScale;



@property float transformScaleValue;
- (float)transformScaleValue;
- (void)setTransformScaleValue:(float)value_;

//- (BOOL)validateTransformScale:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* transformSizeAsString;



//- (BOOL)validateTransformSizeAsString:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* transformTranslationX;



@property float transformTranslationXValue;
- (float)transformTranslationXValue;
- (void)setTransformTranslationXValue:(float)value_;

//- (BOOL)validateTransformTranslationX:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* transformTranslationY;



@property float transformTranslationYValue;
- (float)transformTranslationYValue;
- (void)setTransformTranslationYValue:(float)value_;

//- (BOOL)validateTransformTranslationY:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *measurementGroups;

- (NSMutableSet*)measurementGroupsSet;




@property (nonatomic, strong) NSSet *photos;

- (NSMutableSet*)photosSet;




@property (nonatomic, strong) WMWound *wound;

//- (BOOL)validateWound:(id*)value_ error:(NSError**)error_;





@end

@interface _WMWoundPhoto (CoreDataGeneratedAccessors)

- (void)addMeasurementGroups:(NSSet*)value_;
- (void)removeMeasurementGroups:(NSSet*)value_;
- (void)addMeasurementGroupsObject:(WMWoundMeasurementGroup*)value_;
- (void)removeMeasurementGroupsObject:(WMWoundMeasurementGroup*)value_;

- (void)addPhotos:(NSSet*)value_;
- (void)removePhotos:(NSSet*)value_;
- (void)addPhotosObject:(WMPhoto*)value_;
- (void)removePhotosObject:(WMPhoto*)value_;

@end

@interface _WMWoundPhoto (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveComments;
- (void)setPrimitiveComments:(NSString*)value;




- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSNumber*)primitiveImageHeight;
- (void)setPrimitiveImageHeight:(NSNumber*)value;

- (float)primitiveImageHeightValue;
- (void)setPrimitiveImageHeightValue:(float)value_;




- (NSNumber*)primitiveImageOrientation;
- (void)setPrimitiveImageOrientation:(NSNumber*)value;

- (int16_t)primitiveImageOrientationValue;
- (void)setPrimitiveImageOrientationValue:(int16_t)value_;




- (NSNumber*)primitiveImageWidth;
- (void)setPrimitiveImageWidth:(NSNumber*)value;

- (float)primitiveImageWidthValue;
- (void)setPrimitiveImageWidthValue:(float)value_;




- (NSString*)primitiveMetadata;
- (void)setPrimitiveMetadata:(NSString*)value;




- (NSString*)primitiveThumbnail;
- (void)setPrimitiveThumbnail:(NSString*)value;




- (NSString*)primitiveThumbnailLarge;
- (void)setPrimitiveThumbnailLarge:(NSString*)value;




- (NSString*)primitiveThumbnailMini;
- (void)setPrimitiveThumbnailMini:(NSString*)value;




- (NSString*)primitiveTransformAsString;
- (void)setPrimitiveTransformAsString:(NSString*)value;




- (NSNumber*)primitiveTransformRotation;
- (void)setPrimitiveTransformRotation:(NSNumber*)value;

- (float)primitiveTransformRotationValue;
- (void)setPrimitiveTransformRotationValue:(float)value_;




- (NSNumber*)primitiveTransformScale;
- (void)setPrimitiveTransformScale:(NSNumber*)value;

- (float)primitiveTransformScaleValue;
- (void)setPrimitiveTransformScaleValue:(float)value_;




- (NSString*)primitiveTransformSizeAsString;
- (void)setPrimitiveTransformSizeAsString:(NSString*)value;




- (NSNumber*)primitiveTransformTranslationX;
- (void)setPrimitiveTransformTranslationX:(NSNumber*)value;

- (float)primitiveTransformTranslationXValue;
- (void)setPrimitiveTransformTranslationXValue:(float)value_;




- (NSNumber*)primitiveTransformTranslationY;
- (void)setPrimitiveTransformTranslationY:(NSNumber*)value;

- (float)primitiveTransformTranslationYValue;
- (void)setPrimitiveTransformTranslationYValue:(float)value_;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;





- (NSMutableSet*)primitiveMeasurementGroups;
- (void)setPrimitiveMeasurementGroups:(NSMutableSet*)value;



- (NSMutableSet*)primitivePhotos;
- (void)setPrimitivePhotos:(NSMutableSet*)value;



- (WMWound*)primitiveWound;
- (void)setPrimitiveWound:(WMWound*)value;


@end
