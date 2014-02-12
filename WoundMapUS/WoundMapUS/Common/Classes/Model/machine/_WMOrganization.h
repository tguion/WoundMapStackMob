// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMOrganization.h instead.

#import <CoreData/CoreData.h>


extern const struct WMOrganizationAttributes {
	__unsafe_unretained NSString *createdate;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *wmorganization_id;
} WMOrganizationAttributes;

extern const struct WMOrganizationRelationships {
	__unsafe_unretained NSString *addresses;
	__unsafe_unretained NSString *ids;
} WMOrganizationRelationships;

extern const struct WMOrganizationFetchedProperties {
} WMOrganizationFetchedProperties;

@class WMAddress;
@class WMId;






@interface WMOrganizationID : NSManagedObjectID {}
@end

@interface _WMOrganization : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMOrganizationID*)objectID;





@property (nonatomic, strong) NSDate* createdate;



//- (BOOL)validateCreatedate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastmoddate;



//- (BOOL)validateLastmoddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wmorganization_id;



//- (BOOL)validateWmorganization_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *addresses;

- (NSMutableSet*)addressesSet;




@property (nonatomic, strong) NSSet *ids;

- (NSMutableSet*)idsSet;





@end

@interface _WMOrganization (CoreDataGeneratedAccessors)

- (void)addAddresses:(NSSet*)value_;
- (void)removeAddresses:(NSSet*)value_;
- (void)addAddressesObject:(WMAddress*)value_;
- (void)removeAddressesObject:(WMAddress*)value_;

- (void)addIds:(NSSet*)value_;
- (void)removeIds:(NSSet*)value_;
- (void)addIdsObject:(WMId*)value_;
- (void)removeIdsObject:(WMId*)value_;

@end

@interface _WMOrganization (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreatedate;
- (void)setPrimitiveCreatedate:(NSDate*)value;




- (NSDate*)primitiveLastmoddate;
- (void)setPrimitiveLastmoddate:(NSDate*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveWmorganization_id;
- (void)setPrimitiveWmorganization_id:(NSString*)value;





- (NSMutableSet*)primitiveAddresses;
- (void)setPrimitiveAddresses:(NSMutableSet*)value;



- (NSMutableSet*)primitiveIds;
- (void)setPrimitiveIds:(NSMutableSet*)value;


@end
