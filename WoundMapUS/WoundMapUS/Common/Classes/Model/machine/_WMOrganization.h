// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMOrganization.h instead.

#import <CoreData/CoreData.h>


extern const struct WMOrganizationAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *updatedAt;
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





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





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


- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;





- (NSMutableSet*)primitiveAddresses;
- (void)setPrimitiveAddresses:(NSMutableSet*)value;



- (NSMutableSet*)primitiveIds;
- (void)setPrimitiveIds:(NSMutableSet*)value;


@end
