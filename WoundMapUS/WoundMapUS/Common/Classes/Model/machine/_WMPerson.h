// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMPerson.h instead.

#import <CoreData/CoreData.h>


extern const struct WMPersonAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *nameFamily;
	__unsafe_unretained NSString *nameGiven;
	__unsafe_unretained NSString *namePrefix;
	__unsafe_unretained NSString *nameSuffix;
	__unsafe_unretained NSString *updatedAt;
} WMPersonAttributes;

extern const struct WMPersonRelationships {
	__unsafe_unretained NSString *addresses;
	__unsafe_unretained NSString *participant;
	__unsafe_unretained NSString *patient;
	__unsafe_unretained NSString *telecoms;
} WMPersonRelationships;

extern const struct WMPersonFetchedProperties {
} WMPersonFetchedProperties;

@class WMAddress;
@class WMParticipant;
@class WMPatient;
@class WMTelecom;









@interface WMPersonID : NSManagedObjectID {}
@end

@interface _WMPerson : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMPersonID*)objectID;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* nameFamily;



//- (BOOL)validateNameFamily:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* nameGiven;



//- (BOOL)validateNameGiven:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* namePrefix;



//- (BOOL)validateNamePrefix:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* nameSuffix;



//- (BOOL)validateNameSuffix:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *addresses;

- (NSMutableSet*)addressesSet;




@property (nonatomic, strong) WMParticipant *participant;

//- (BOOL)validateParticipant:(id*)value_ error:(NSError**)error_;




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


- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSString*)primitiveNameFamily;
- (void)setPrimitiveNameFamily:(NSString*)value;




- (NSString*)primitiveNameGiven;
- (void)setPrimitiveNameGiven:(NSString*)value;




- (NSString*)primitiveNamePrefix;
- (void)setPrimitiveNamePrefix:(NSString*)value;




- (NSString*)primitiveNameSuffix;
- (void)setPrimitiveNameSuffix:(NSString*)value;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;





- (NSMutableSet*)primitiveAddresses;
- (void)setPrimitiveAddresses:(NSMutableSet*)value;



- (WMParticipant*)primitiveParticipant;
- (void)setPrimitiveParticipant:(WMParticipant*)value;



- (WMPatient*)primitivePatient;
- (void)setPrimitivePatient:(WMPatient*)value;



- (NSMutableSet*)primitiveTelecoms;
- (void)setPrimitiveTelecoms:(NSMutableSet*)value;


@end
