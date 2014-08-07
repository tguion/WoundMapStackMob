// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMPatientLocation.h instead.

#import <CoreData/CoreData.h>


extern const struct WMPatientLocationAttributes {
	__unsafe_unretained NSString *facility;
	__unsafe_unretained NSString *location;
	__unsafe_unretained NSString *room;
	__unsafe_unretained NSString *unit;
} WMPatientLocationAttributes;

extern const struct WMPatientLocationRelationships {
	__unsafe_unretained NSString *patient;
} WMPatientLocationRelationships;

extern const struct WMPatientLocationFetchedProperties {
} WMPatientLocationFetchedProperties;

@class WMPatient;






@interface WMPatientLocationID : NSManagedObjectID {}
@end

@interface _WMPatientLocation : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMPatientLocationID*)objectID;





@property (nonatomic, strong) NSString* facility;



//- (BOOL)validateFacility:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* location;



//- (BOOL)validateLocation:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* room;



//- (BOOL)validateRoom:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* unit;



//- (BOOL)validateUnit:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMPatient *patient;

//- (BOOL)validatePatient:(id*)value_ error:(NSError**)error_;





@end

@interface _WMPatientLocation (CoreDataGeneratedAccessors)

@end

@interface _WMPatientLocation (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveFacility;
- (void)setPrimitiveFacility:(NSString*)value;




- (NSString*)primitiveLocation;
- (void)setPrimitiveLocation:(NSString*)value;




- (NSString*)primitiveRoom;
- (void)setPrimitiveRoom:(NSString*)value;




- (NSString*)primitiveUnit;
- (void)setPrimitiveUnit:(NSString*)value;





- (WMPatient*)primitivePatient;
- (void)setPrimitivePatient:(WMPatient*)value;


@end
