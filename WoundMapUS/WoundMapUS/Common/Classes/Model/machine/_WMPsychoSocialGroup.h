// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMPsychoSocialGroup.h instead.

#import <CoreData/CoreData.h>


extern const struct WMPsychoSocialGroupAttributes {
	__unsafe_unretained NSString *closedFlag;
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *datePushed;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *updatedAt;
} WMPsychoSocialGroupAttributes;

extern const struct WMPsychoSocialGroupRelationships {
	__unsafe_unretained NSString *interventionEvents;
	__unsafe_unretained NSString *patient;
	__unsafe_unretained NSString *status;
	__unsafe_unretained NSString *values;
} WMPsychoSocialGroupRelationships;

extern const struct WMPsychoSocialGroupFetchedProperties {
} WMPsychoSocialGroupFetchedProperties;

@class WMPsychoSocialIntEvent;
@class WMPatient;
@class WMInterventionStatus;
@class WMPsychoSocialValue;








@interface WMPsychoSocialGroupID : NSManagedObjectID {}
@end

@interface _WMPsychoSocialGroup : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMPsychoSocialGroupID*)objectID;





@property (nonatomic, strong) NSNumber* closedFlag;



@property BOOL closedFlagValue;
- (BOOL)closedFlagValue;
- (void)setClosedFlagValue:(BOOL)value_;

//- (BOOL)validateClosedFlag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* datePushed;



//- (BOOL)validateDatePushed:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *interventionEvents;

- (NSMutableSet*)interventionEventsSet;




@property (nonatomic, strong) WMPatient *patient;

//- (BOOL)validatePatient:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMInterventionStatus *status;

//- (BOOL)validateStatus:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *values;

- (NSMutableSet*)valuesSet;





@end

@interface _WMPsychoSocialGroup (CoreDataGeneratedAccessors)

- (void)addInterventionEvents:(NSSet*)value_;
- (void)removeInterventionEvents:(NSSet*)value_;
- (void)addInterventionEventsObject:(WMPsychoSocialIntEvent*)value_;
- (void)removeInterventionEventsObject:(WMPsychoSocialIntEvent*)value_;

- (void)addValues:(NSSet*)value_;
- (void)removeValues:(NSSet*)value_;
- (void)addValuesObject:(WMPsychoSocialValue*)value_;
- (void)removeValuesObject:(WMPsychoSocialValue*)value_;

@end

@interface _WMPsychoSocialGroup (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveClosedFlag;
- (void)setPrimitiveClosedFlag:(NSNumber*)value;

- (BOOL)primitiveClosedFlagValue;
- (void)setPrimitiveClosedFlagValue:(BOOL)value_;




- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSDate*)primitiveDatePushed;
- (void)setPrimitiveDatePushed:(NSDate*)value;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;





- (NSMutableSet*)primitiveInterventionEvents;
- (void)setPrimitiveInterventionEvents:(NSMutableSet*)value;



- (WMPatient*)primitivePatient;
- (void)setPrimitivePatient:(WMPatient*)value;



- (WMInterventionStatus*)primitiveStatus;
- (void)setPrimitiveStatus:(WMInterventionStatus*)value;



- (NSMutableSet*)primitiveValues;
- (void)setPrimitiveValues:(NSMutableSet*)value;


@end
