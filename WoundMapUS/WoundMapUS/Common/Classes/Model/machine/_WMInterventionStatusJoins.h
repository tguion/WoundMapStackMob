// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMInterventionStatusJoins.h instead.

#import <CoreData/CoreData.h>


extern const struct WMInterventionStatusJoinsAttributes {
} WMInterventionStatusJoinsAttributes;

extern const struct WMInterventionStatusJoinsRelationships {
	__unsafe_unretained NSString *fromStatus;
	__unsafe_unretained NSString *toStatus;
} WMInterventionStatusJoinsRelationships;

extern const struct WMInterventionStatusJoinsFetchedProperties {
} WMInterventionStatusJoinsFetchedProperties;

@class WMInterventionStatus;
@class WMInterventionStatus;


@interface WMInterventionStatusJoinsID : NSManagedObjectID {}
@end

@interface _WMInterventionStatusJoins : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMInterventionStatusJoinsID*)objectID;





@property (nonatomic, strong) WMInterventionStatus *fromStatus;

//- (BOOL)validateFromStatus:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMInterventionStatus *toStatus;

//- (BOOL)validateToStatus:(id*)value_ error:(NSError**)error_;





@end

@interface _WMInterventionStatusJoins (CoreDataGeneratedAccessors)

@end

@interface _WMInterventionStatusJoins (CoreDataGeneratedPrimitiveAccessors)



- (WMInterventionStatus*)primitiveFromStatus;
- (void)setPrimitiveFromStatus:(WMInterventionStatus*)value;



- (WMInterventionStatus*)primitiveToStatus;
- (void)setPrimitiveToStatus:(WMInterventionStatus*)value;


@end
