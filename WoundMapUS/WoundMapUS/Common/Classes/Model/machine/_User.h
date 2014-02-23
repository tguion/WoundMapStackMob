// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.h instead.

#import <CoreData/CoreData.h>
#import "StackMob.h"

extern const struct UserAttributes {
	__unsafe_unretained NSString *createdate;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *username;
} UserAttributes;

extern const struct UserRelationships {
	__unsafe_unretained NSString *consultingGroup;
	__unsafe_unretained NSString *iapProducts;
	__unsafe_unretained NSString *patientConsultants;
} UserRelationships;

extern const struct UserFetchedProperties {
} UserFetchedProperties;

@class WMConsultingGroup;
@class IAPProduct;
@class WMPatientConsultant;





@interface UserID : NSManagedObjectID {}
@end

@interface _User : SMUserManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (UserID*)objectID;





@property (nonatomic, strong) NSDate* createdate;



//- (BOOL)validateCreatedate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastmoddate;



//- (BOOL)validateLastmoddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* username;



//- (BOOL)validateUsername:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMConsultingGroup *consultingGroup;

//- (BOOL)validateConsultingGroup:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *iapProducts;

- (NSMutableSet*)iapProductsSet;




@property (nonatomic, strong) NSSet *patientConsultants;

- (NSMutableSet*)patientConsultantsSet;





@end

@interface _User (CoreDataGeneratedAccessors)

- (void)addIapProducts:(NSSet*)value_;
- (void)removeIapProducts:(NSSet*)value_;
- (void)addIapProductsObject:(IAPProduct*)value_;
- (void)removeIapProductsObject:(IAPProduct*)value_;

- (void)addPatientConsultants:(NSSet*)value_;
- (void)removePatientConsultants:(NSSet*)value_;
- (void)addPatientConsultantsObject:(WMPatientConsultant*)value_;
- (void)removePatientConsultantsObject:(WMPatientConsultant*)value_;

@end

@interface _User (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreatedate;
- (void)setPrimitiveCreatedate:(NSDate*)value;




- (NSDate*)primitiveLastmoddate;
- (void)setPrimitiveLastmoddate:(NSDate*)value;




- (NSString*)primitiveUsername;
- (void)setPrimitiveUsername:(NSString*)value;





- (WMConsultingGroup*)primitiveConsultingGroup;
- (void)setPrimitiveConsultingGroup:(WMConsultingGroup*)value;



- (NSMutableSet*)primitiveIapProducts;
- (void)setPrimitiveIapProducts:(NSMutableSet*)value;



- (NSMutableSet*)primitivePatientConsultants;
- (void)setPrimitivePatientConsultants:(NSMutableSet*)value;


@end
