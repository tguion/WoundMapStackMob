// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMMedicalHistoryGroup.h instead.

#import <CoreData/CoreData.h>


extern const struct WMMedicalHistoryGroupAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *updatedAt;
} WMMedicalHistoryGroupAttributes;

extern const struct WMMedicalHistoryGroupRelationships {
	__unsafe_unretained NSString *patient;
	__unsafe_unretained NSString *values;
} WMMedicalHistoryGroupRelationships;

extern const struct WMMedicalHistoryGroupFetchedProperties {
} WMMedicalHistoryGroupFetchedProperties;

@class WMPatient;
@class WMMedicalHistoryValue;






@interface WMMedicalHistoryGroupID : NSManagedObjectID {}
@end

@interface _WMMedicalHistoryGroup : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMMedicalHistoryGroupID*)objectID;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMPatient *patient;

//- (BOOL)validatePatient:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *values;

- (NSMutableSet*)valuesSet;





@end

@interface _WMMedicalHistoryGroup (CoreDataGeneratedAccessors)

- (void)addValues:(NSSet*)value_;
- (void)removeValues:(NSSet*)value_;
- (void)addValuesObject:(WMMedicalHistoryValue*)value_;
- (void)removeValuesObject:(WMMedicalHistoryValue*)value_;

@end

@interface _WMMedicalHistoryGroup (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;





- (WMPatient*)primitivePatient;
- (void)setPrimitivePatient:(WMPatient*)value;



- (NSMutableSet*)primitiveValues;
- (void)setPrimitiveValues:(NSMutableSet*)value;


@end
