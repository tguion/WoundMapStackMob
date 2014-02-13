// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMTelecom.h instead.

#import <CoreData/CoreData.h>


extern const struct WMTelecomAttributes {
	__unsafe_unretained NSString *createddate;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *use;
	__unsafe_unretained NSString *value;
	__unsafe_unretained NSString *wmtelecom_id;
} WMTelecomAttributes;

extern const struct WMTelecomRelationships {
	__unsafe_unretained NSString *person;
	__unsafe_unretained NSString *telecomType;
} WMTelecomRelationships;

extern const struct WMTelecomFetchedProperties {
} WMTelecomFetchedProperties;

@class WMPerson;
@class WMTelecomType;








@interface WMTelecomID : NSManagedObjectID {}
@end

@interface _WMTelecom : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMTelecomID*)objectID;





@property (nonatomic, strong) NSDate* createddate;



//- (BOOL)validateCreateddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastmoddate;



//- (BOOL)validateLastmoddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* use;



//- (BOOL)validateUse:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* value;



//- (BOOL)validateValue:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wmtelecom_id;



//- (BOOL)validateWmtelecom_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMPerson *person;

//- (BOOL)validatePerson:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMTelecomType *telecomType;

//- (BOOL)validateTelecomType:(id*)value_ error:(NSError**)error_;





@end

@interface _WMTelecom (CoreDataGeneratedAccessors)

@end

@interface _WMTelecom (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreateddate;
- (void)setPrimitiveCreateddate:(NSDate*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSDate*)primitiveLastmoddate;
- (void)setPrimitiveLastmoddate:(NSDate*)value;




- (NSString*)primitiveUse;
- (void)setPrimitiveUse:(NSString*)value;




- (NSString*)primitiveValue;
- (void)setPrimitiveValue:(NSString*)value;




- (NSString*)primitiveWmtelecom_id;
- (void)setPrimitiveWmtelecom_id:(NSString*)value;





- (WMPerson*)primitivePerson;
- (void)setPrimitivePerson:(WMPerson*)value;



- (WMTelecomType*)primitiveTelecomType;
- (void)setPrimitiveTelecomType:(WMTelecomType*)value;


@end
