// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMPerson.h instead.

#import <CoreData/CoreData.h>


extern const struct WMPersonAttributes {
	__unsafe_unretained NSString *createddate;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *nameFamily;
	__unsafe_unretained NSString *nameGiven;
	__unsafe_unretained NSString *namePrefix;
	__unsafe_unretained NSString *nameSuffix;
	__unsafe_unretained NSString *wmperson_id;
} WMPersonAttributes;

extern const struct WMPersonRelationships {
	__unsafe_unretained NSString *addresses;
	__unsafe_unretained NSString *patient;
	__unsafe_unretained NSString *telecoms;
} WMPersonRelationships;

extern const struct WMPersonFetchedProperties {
} WMPersonFetchedProperties;

@class WMAddress;
@class WMPatient;
@class WMTelecom;









@interface WMPersonID : NSManagedObjectID {}
@end

@interface _WMPerson : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMPersonID*)objectID;





@property (nonatomic, strong) NSDate* createddate;



//- (BOOL)validateCreateddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastmoddate;



//- (BOOL)validateLastmoddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* nameFamily;



//- (BOOL)validateNameFamily:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* nameGiven;



//- (BOOL)validateNameGiven:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* namePrefix;



//- (BOOL)validateNamePrefix:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* nameSuffix;



//- (BOOL)validateNameSuffix:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wmperson_id;



//- (BOOL)validateWmperson_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *addresses;

- (NSMutableSet*)addressesSet;




@property (nonatomic, strong) WMPatient *patient;

//- (BOOL)validatePatient:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *telecoms;

- (NSMutableSet*)telecomsSet;





@end

@interface _WMPerson (CoreDataGeneratedAccessors)

- (void)addAddresses:(NSSet*)value_;
- (void)removeAddresses:(NSSet*)value_;
- (void)addAddressesObject:(WMAddress*)value_;
- (void)removeAddressesObject:(WMAddress*)value_;

- (void)addTelecoms:(NSSet*)value_;
- (void)removeTelecoms:(NSSet*)value_;
- (void)addTelecomsObject:(WMTelecom*)value_;
- (void)removeTelecomsObject:(WMTelecom*)value_;

@end

@interface _WMPerson (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreateddate;
- (void)setPrimitiveCreateddate:(NSDate*)value;




- (NSDate*)primitiveLastmoddate;
- (void)setPrimitiveLastmoddate:(NSDate*)value;




- (NSString*)primitiveNameFamily;
- (void)setPrimitiveNameFamily:(NSString*)value;




- (NSString*)primitiveNameGiven;
- (void)setPrimitiveNameGiven:(NSString*)value;




- (NSString*)primitiveNamePrefix;
- (void)setPrimitiveNamePrefix:(NSString*)value;




- (NSString*)primitiveNameSuffix;
- (void)setPrimitiveNameSuffix:(NSString*)value;




- (NSString*)primitiveWmperson_id;
- (void)setPrimitiveWmperson_id:(NSString*)value;





- (NSMutableSet*)primitiveAddresses;
- (void)setPrimitiveAddresses:(NSMutableSet*)value;



- (WMPatient*)primitivePatient;
- (void)setPrimitivePatient:(WMPatient*)value;



- (NSMutableSet*)primitiveTelecoms;
- (void)setPrimitiveTelecoms:(NSMutableSet*)value;


@end
