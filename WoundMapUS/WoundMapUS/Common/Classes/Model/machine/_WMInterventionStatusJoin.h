// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMInterventionStatusJoin.h instead.

#import <CoreData/CoreData.h>


extern const struct WMInterventionStatusJoinAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *updatedAt;
} WMInterventionStatusJoinAttributes;

extern const struct WMInterventionStatusJoinRelationships {
	__unsafe_unretained NSString *fromStatus;
	__unsafe_unretained NSString *toStatus;
} WMInterventionStatusJoinRelationships;

extern const struct WMInterventionStatusJoinFetchedProperties {
} WMInterventionStatusJoinFetchedProperties;

@class WMInterventionStatus;
@class WMInterventionStatus;





@interface WMInterventionStatusJoinID : NSManagedObjectID {}
@end

@interface _WMInterventionStatusJoin : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMInterventionStatusJoinID*)objectID;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMInterventionStatus *fromStatus;

//- (BOOL)validateFromStatus:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMInterventionStatus *toStatus;

//- (BOOL)validateToStatus:(id*)value_ error:(NSError**)error_;





@end

@interface _WMInterventionStatusJoin (CoreDataGeneratedAccessors)

@end

@interface _WMInterventionStatusJoin (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;





- (WMInterventionStatus*)primitiveFromStatus;
- (void)setPrimitiveFromStatus:(WMInterventionStatus*)value;



- (WMInterventionStatus*)primitiveToStatus;
- (void)setPrimitiveToStatus:(WMInterventionStatus*)value;


@end
