// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMInterventionStatusJoin.h instead.

#import <CoreData/CoreData.h>


extern const struct WMInterventionStatusJoinAttributes {
	__unsafe_unretained NSString *createddate;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *wmintervetionstatusjoin_id;
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





@property (nonatomic, strong) NSDate* createddate;



//- (BOOL)validateCreateddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastmoddate;



//- (BOOL)validateLastmoddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wmintervetionstatusjoin_id;



//- (BOOL)validateWmintervetionstatusjoin_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMInterventionStatus *fromStatus;

//- (BOOL)validateFromStatus:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMInterventionStatus *toStatus;

//- (BOOL)validateToStatus:(id*)value_ error:(NSError**)error_;





@end

@interface _WMInterventionStatusJoin (CoreDataGeneratedAccessors)

@end

@interface _WMInterventionStatusJoin (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreateddate;
- (void)setPrimitiveCreateddate:(NSDate*)value;




- (NSDate*)primitiveLastmoddate;
- (void)setPrimitiveLastmoddate:(NSDate*)value;




- (NSString*)primitiveWmintervetionstatusjoin_id;
- (void)setPrimitiveWmintervetionstatusjoin_id:(NSString*)value;





- (WMInterventionStatus*)primitiveFromStatus;
- (void)setPrimitiveFromStatus:(WMInterventionStatus*)value;



- (WMInterventionStatus*)primitiveToStatus;
- (void)setPrimitiveToStatus:(WMInterventionStatus*)value;


@end
