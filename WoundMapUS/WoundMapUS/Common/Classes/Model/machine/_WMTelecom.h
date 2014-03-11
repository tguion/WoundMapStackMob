// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMTelecom.h instead.

#import <CoreData/CoreData.h>


extern const struct WMTelecomAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *updatedAt;
	__unsafe_unretained NSString *use;
	__unsafe_unretained NSString *value;
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





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* use;



//- (BOOL)validateUse:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* value;



//- (BOOL)validateValue:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMPerson *person;

//- (BOOL)validatePerson:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMTelecomType *telecomType;

//- (BOOL)validateTelecomType:(id*)value_ error:(NSError**)error_;





@end

@interface _WMTelecom (CoreDataGeneratedAccessors)

@end

@interface _WMTelecom (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;




- (NSString*)primitiveUse;
- (void)setPrimitiveUse:(NSString*)value;




- (NSString*)primitiveValue;
- (void)setPrimitiveValue:(NSString*)value;





- (WMPerson*)primitivePerson;
- (void)setPrimitivePerson:(WMPerson*)value;



- (WMTelecomType*)primitiveTelecomType;
- (void)setPrimitiveTelecomType:(WMTelecomType*)value;


@end
