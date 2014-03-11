// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMFFMetadata.h instead.

#import <CoreData/CoreData.h>


extern const struct WMFFMetadataAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *createdBy;
	__unsafe_unretained NSString *ffRL;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *ffUserCanEdit;
	__unsafe_unretained NSString *guid;
	__unsafe_unretained NSString *objVersion;
	__unsafe_unretained NSString *updatedAt;
	__unsafe_unretained NSString *updatedBy;
} WMFFMetadataAttributes;

extern const struct WMFFMetadataRelationships {
} WMFFMetadataRelationships;

extern const struct WMFFMetadataFetchedProperties {
} WMFFMetadataFetchedProperties;












@interface WMFFMetadataID : NSManagedObjectID {}
@end

@interface _WMFFMetadata : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMFFMetadataID*)objectID;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* createdBy;



//- (BOOL)validateCreatedBy:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffRL;



//- (BOOL)validateFfRL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* ffUserCanEdit;



@property BOOL ffUserCanEditValue;
- (BOOL)ffUserCanEditValue;
- (void)setFfUserCanEditValue:(BOOL)value_;

//- (BOOL)validateFfUserCanEdit:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* guid;



//- (BOOL)validateGuid:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* objVersion;



@property int16_t objVersionValue;
- (int16_t)objVersionValue;
- (void)setObjVersionValue:(int16_t)value_;

//- (BOOL)validateObjVersion:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* updatedBy;



//- (BOOL)validateUpdatedBy:(id*)value_ error:(NSError**)error_;






@end

@interface _WMFFMetadata (CoreDataGeneratedAccessors)

@end

@interface _WMFFMetadata (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSString*)primitiveCreatedBy;
- (void)setPrimitiveCreatedBy:(NSString*)value;




- (NSString*)primitiveFfRL;
- (void)setPrimitiveFfRL:(NSString*)value;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSNumber*)primitiveFfUserCanEdit;
- (void)setPrimitiveFfUserCanEdit:(NSNumber*)value;

- (BOOL)primitiveFfUserCanEditValue;
- (void)setPrimitiveFfUserCanEditValue:(BOOL)value_;




- (NSString*)primitiveGuid;
- (void)setPrimitiveGuid:(NSString*)value;




- (NSNumber*)primitiveObjVersion;
- (void)setPrimitiveObjVersion:(NSNumber*)value;

- (int16_t)primitiveObjVersionValue;
- (void)setPrimitiveObjVersionValue:(int16_t)value_;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;




- (NSString*)primitiveUpdatedBy;
- (void)setPrimitiveUpdatedBy:(NSString*)value;




@end
