// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundPositionValue.h instead.

#import <CoreData/CoreData.h>


extern const struct WMWoundPositionValueAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *updatedAt;
	__unsafe_unretained NSString *value;
} WMWoundPositionValueAttributes;

extern const struct WMWoundPositionValueRelationships {
	__unsafe_unretained NSString *wound;
	__unsafe_unretained NSString *woundPosition;
} WMWoundPositionValueRelationships;

extern const struct WMWoundPositionValueFetchedProperties {
} WMWoundPositionValueFetchedProperties;

@class WMWound;
@class WMWoundPosition;








@interface WMWoundPositionValueID : NSManagedObjectID {}
@end

@interface _WMWoundPositionValue : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMWoundPositionValueID*)objectID;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* value;



//- (BOOL)validateValue:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMWound *wound;

//- (BOOL)validateWound:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMWoundPosition *woundPosition;

//- (BOOL)validateWoundPosition:(id*)value_ error:(NSError**)error_;





@end

@interface _WMWoundPositionValue (CoreDataGeneratedAccessors)

@end

@interface _WMWoundPositionValue (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;




- (NSString*)primitiveValue;
- (void)setPrimitiveValue:(NSString*)value;





- (WMWound*)primitiveWound;
- (void)setPrimitiveWound:(WMWound*)value;



- (WMWoundPosition*)primitiveWoundPosition;
- (void)setPrimitiveWoundPosition:(WMWoundPosition*)value;


@end
