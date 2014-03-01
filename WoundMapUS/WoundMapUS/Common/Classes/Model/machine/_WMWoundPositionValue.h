// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundPositionValue.h instead.

#import <CoreData/CoreData.h>


extern const struct WMWoundPositionValueAttributes {
	__unsafe_unretained NSString *createddate;
	__unsafe_unretained NSString *dateCreated;
	__unsafe_unretained NSString *dateModified;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *value;
	__unsafe_unretained NSString *wmwoundpositionvalue_id;
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





@property (nonatomic, strong) NSDate* createddate;



//- (BOOL)validateCreateddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateCreated;



//- (BOOL)validateDateCreated:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateModified;



//- (BOOL)validateDateModified:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastmoddate;



//- (BOOL)validateLastmoddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* value;



//- (BOOL)validateValue:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wmwoundpositionvalue_id;



//- (BOOL)validateWmwoundpositionvalue_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMWound *wound;

//- (BOOL)validateWound:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMWoundPosition *woundPosition;

//- (BOOL)validateWoundPosition:(id*)value_ error:(NSError**)error_;





@end

@interface _WMWoundPositionValue (CoreDataGeneratedAccessors)

@end

@interface _WMWoundPositionValue (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreateddate;
- (void)setPrimitiveCreateddate:(NSDate*)value;




- (NSDate*)primitiveDateCreated;
- (void)setPrimitiveDateCreated:(NSDate*)value;




- (NSDate*)primitiveDateModified;
- (void)setPrimitiveDateModified:(NSDate*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSDate*)primitiveLastmoddate;
- (void)setPrimitiveLastmoddate:(NSDate*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSString*)primitiveValue;
- (void)setPrimitiveValue:(NSString*)value;




- (NSString*)primitiveWmwoundpositionvalue_id;
- (void)setPrimitiveWmwoundpositionvalue_id:(NSString*)value;





- (WMWound*)primitiveWound;
- (void)setPrimitiveWound:(WMWound*)value;



- (WMWoundPosition*)primitiveWoundPosition;
- (void)setPrimitiveWoundPosition:(WMWoundPosition*)value;


@end
