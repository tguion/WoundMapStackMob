// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMId.h instead.

#import <CoreData/CoreData.h>


extern const struct WMIdAttributes {
	__unsafe_unretained NSString *createdate;
	__unsafe_unretained NSString *extension;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *root;
	__unsafe_unretained NSString *wmid_id;
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





@property (nonatomic, strong) NSDate* createdate;



//- (BOOL)validateCreatedate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* extension;



//- (BOOL)validateExtension:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastmoddate;



//- (BOOL)validateLastmoddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* root;



//- (BOOL)validateRoot:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wmid_id;



//- (BOOL)validateWmid_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMOrganization *organization;

//- (BOOL)validateOrganization:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMPatient *patient;

//- (BOOL)validatePatient:(id*)value_ error:(NSError**)error_;





@end

@interface _WMId (CoreDataGeneratedAccessors)

@end

@interface _WMId (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreatedate;
- (void)setPrimitiveCreatedate:(NSDate*)value;




- (NSString*)primitiveExtension;
- (void)setPrimitiveExtension:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSDate*)primitiveLastmoddate;
- (void)setPrimitiveLastmoddate:(NSDate*)value;




- (NSString*)primitiveRoot;
- (void)setPrimitiveRoot:(NSString*)value;




- (NSString*)primitiveWmid_id;
- (void)setPrimitiveWmid_id:(NSString*)value;





- (WMOrganization*)primitiveOrganization;
- (void)setPrimitiveOrganization:(WMOrganization*)value;



- (WMPatient*)primitivePatient;
- (void)setPrimitivePatient:(WMPatient*)value;


@end
