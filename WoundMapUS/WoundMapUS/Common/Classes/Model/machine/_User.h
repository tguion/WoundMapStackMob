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
	__unsafe_unretained NSString *consultingPatients;
} UserRelationships;

extern const struct UserFetchedProperties {
} UserFetchedProperties;

@class WMConsultingGroup;
@class WMPatient;





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




@property (nonatomic, strong) NSSet *consultingPatients;

- (NSMutableSet*)consultingPatientsSet;





@end

@interface _User (CoreDataGeneratedAccessors)

- (void)addConsultingPatients:(NSSet*)value_;
- (void)removeConsultingPatients:(NSSet*)value_;
- (void)addConsultingPatientsObject:(WMPatient*)value_;
- (void)removeConsultingPatientsObject:(WMPatient*)value_;

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



- (NSMutableSet*)primitiveConsultingPatients;
- (void)setPrimitiveConsultingPatients:(NSMutableSet*)value;


@end
