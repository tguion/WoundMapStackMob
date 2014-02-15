// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMConsultingGroup.h instead.

#import <CoreData/CoreData.h>


extern const struct WMConsultingGroupAttributes {
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *name;
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





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) User *stackMobUser;

//- (BOOL)validateStackMobUser:(id*)value_ error:(NSError**)error_;





@end

@interface _WMConsultingGroup (CoreDataGeneratedAccessors)

@end

@interface _WMConsultingGroup (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (User*)primitiveStackMobUser;
- (void)setPrimitiveStackMobUser:(User*)value;


@end
