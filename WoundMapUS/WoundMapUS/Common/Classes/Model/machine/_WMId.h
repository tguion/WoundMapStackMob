// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMId.h instead.

#import <CoreData/CoreData.h>


extern const struct WMIdAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *extension;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *root;
	__unsafe_unretained NSString *updatedAt;
} WMIdAttributes;

extern const struct WMIdRelationships {
	__unsafe_unretained NSString *organization;
	__unsafe_unretained NSString *patient;
} WMIdRelationships;

extern const struct WMIdFetchedProperties {
} WMIdFetchedProperties;

@class WMOrganization;
@class WMPatient;








@interface WMIdID : NSManagedObjectID {}
@end

@interface _WMId : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMIdID*)objectID;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* extension;



//- (BOOL)validateExtension:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* root;



//- (BOOL)validateRoot:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMOrganization *organization;

//- (BOOL)validateOrganization:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMPatient *patient;

//- (BOOL)validatePatient:(id*)value_ error:(NSError**)error_;





@end

@interface _WMId (CoreDataGeneratedAccessors)

@end

@interface _WMId (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSString*)primitiveExtension;
- (void)setPrimitiveExtension:(NSString*)value;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSString*)primitiveRoot;
- (void)setPrimitiveRoot:(NSString*)value;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;





- (WMOrganization*)primitiveOrganization;
- (void)setPrimitiveOrganization:(WMOrganization*)value;



- (WMPatient*)primitivePatient;
- (void)setPrimitivePatient:(WMPatient*)value;


@end
