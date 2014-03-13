// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMConsultingGroup.h instead.

#import <CoreData/CoreData.h>


extern const struct WMConsultingGroupAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *updatedAt;
} WMConsultingGroupAttributes;

extern const struct WMConsultingGroupRelationships {
	__unsafe_unretained NSString *team;
} WMConsultingGroupRelationships;

extern const struct WMConsultingGroupFetchedProperties {
} WMConsultingGroupFetchedProperties;

@class WMTeam;







@interface WMConsultingGroupID : NSManagedObjectID {}
@end

@interface _WMConsultingGroup : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMConsultingGroupID*)objectID;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMTeam *team;

//- (BOOL)validateTeam:(id*)value_ error:(NSError**)error_;





@end

@interface _WMConsultingGroup (CoreDataGeneratedAccessors)

@end

@interface _WMConsultingGroup (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;





- (WMTeam*)primitiveTeam;
- (void)setPrimitiveTeam:(WMTeam*)value;


@end
