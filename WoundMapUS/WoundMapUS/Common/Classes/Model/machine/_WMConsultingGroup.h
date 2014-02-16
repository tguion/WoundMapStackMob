// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMConsultingGroup.h instead.

#import <CoreData/CoreData.h>


extern const struct WMConsultingGroupAttributes {
	__unsafe_unretained NSString *createddate;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *wmconsultinggroup_id;
} WMConsultingGroupAttributes;

extern const struct WMConsultingGroupRelationships {
	__unsafe_unretained NSString *stackMobUser;
} WMConsultingGroupRelationships;

extern const struct WMConsultingGroupFetchedProperties {
} WMConsultingGroupFetchedProperties;

@class User;







@interface WMConsultingGroupID : NSManagedObjectID {}
@end

@interface _WMConsultingGroup : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMConsultingGroupID*)objectID;





@property (nonatomic, strong) NSDate* createddate;



//- (BOOL)validateCreateddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastmoddate;



//- (BOOL)validateLastmoddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wmconsultinggroup_id;



//- (BOOL)validateWmconsultinggroup_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) User *stackMobUser;

//- (BOOL)validateStackMobUser:(id*)value_ error:(NSError**)error_;





@end

@interface _WMConsultingGroup (CoreDataGeneratedAccessors)

@end

@interface _WMConsultingGroup (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreateddate;
- (void)setPrimitiveCreateddate:(NSDate*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSDate*)primitiveLastmoddate;
- (void)setPrimitiveLastmoddate:(NSDate*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveWmconsultinggroup_id;
- (void)setPrimitiveWmconsultinggroup_id:(NSString*)value;





- (User*)primitiveStackMobUser;
- (void)setPrimitiveStackMobUser:(User*)value;


@end
