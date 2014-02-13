// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMAddress.h instead.

#import <CoreData/CoreData.h>


extern const struct WMAddressAttributes {
	__unsafe_unretained NSString *city;
	__unsafe_unretained NSString *country;
	__unsafe_unretained NSString *createddate;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *postalCode;
	__unsafe_unretained NSString *state;
	__unsafe_unretained NSString *streetAddressLine;
	__unsafe_unretained NSString *streetAddressLine1;
	__unsafe_unretained NSString *wmaddress_id;
} WMAddressAttributes;

extern const struct WMAddressRelationships {
	__unsafe_unretained NSString *organization;
	__unsafe_unretained NSString *person;
} WMAddressRelationships;

extern const struct WMAddressFetchedProperties {
} WMAddressFetchedProperties;

@class WMOrganization;
@class WMPerson;











@interface WMAddressID : NSManagedObjectID {}
@end

@interface _WMAddress : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMAddressID*)objectID;





@property (nonatomic, strong) NSString* city;



//- (BOOL)validateCity:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* country;



//- (BOOL)validateCountry:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* createddate;



//- (BOOL)validateCreateddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastmoddate;



//- (BOOL)validateLastmoddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* postalCode;



//- (BOOL)validatePostalCode:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* state;



//- (BOOL)validateState:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* streetAddressLine;



//- (BOOL)validateStreetAddressLine:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* streetAddressLine1;



//- (BOOL)validateStreetAddressLine1:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wmaddress_id;



//- (BOOL)validateWmaddress_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMOrganization *organization;

//- (BOOL)validateOrganization:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMPerson *person;

//- (BOOL)validatePerson:(id*)value_ error:(NSError**)error_;





@end

@interface _WMAddress (CoreDataGeneratedAccessors)

@end

@interface _WMAddress (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCity;
- (void)setPrimitiveCity:(NSString*)value;




- (NSString*)primitiveCountry;
- (void)setPrimitiveCountry:(NSString*)value;




- (NSDate*)primitiveCreateddate;
- (void)setPrimitiveCreateddate:(NSDate*)value;




- (NSDate*)primitiveLastmoddate;
- (void)setPrimitiveLastmoddate:(NSDate*)value;




- (NSString*)primitivePostalCode;
- (void)setPrimitivePostalCode:(NSString*)value;




- (NSString*)primitiveState;
- (void)setPrimitiveState:(NSString*)value;




- (NSString*)primitiveStreetAddressLine;
- (void)setPrimitiveStreetAddressLine:(NSString*)value;




- (NSString*)primitiveStreetAddressLine1;
- (void)setPrimitiveStreetAddressLine1:(NSString*)value;




- (NSString*)primitiveWmaddress_id;
- (void)setPrimitiveWmaddress_id:(NSString*)value;





- (WMOrganization*)primitiveOrganization;
- (void)setPrimitiveOrganization:(WMOrganization*)value;



- (WMPerson*)primitivePerson;
- (void)setPrimitivePerson:(WMPerson*)value;


@end
