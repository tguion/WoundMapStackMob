// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMBradenScale.h instead.

#import <CoreData/CoreData.h>


extern const struct WMBradenScaleAttributes {
	__unsafe_unretained NSString *closedFlag;
	__unsafe_unretained NSString *completeFlag;
	__unsafe_unretained NSString *createddate;
	__unsafe_unretained NSString *dateCreated;
	__unsafe_unretained NSString *dateModified;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *score;
	__unsafe_unretained NSString *wmbradenscale_id;
} WMBradenScaleAttributes;

extern const struct WMBradenScaleRelationships {
	__unsafe_unretained NSString *patient;
	__unsafe_unretained NSString *sections;
} WMBradenScaleRelationships;

extern const struct WMBradenScaleFetchedProperties {
} WMBradenScaleFetchedProperties;

@class WMPatient;
@class WMBradenSection;











@interface WMBradenScaleID : NSManagedObjectID {}
@end

@interface _WMBradenScale : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMBradenScaleID*)objectID;





@property (nonatomic, strong) NSNumber* closedFlag;



@property BOOL closedFlagValue;
- (BOOL)closedFlagValue;
- (void)setClosedFlagValue:(BOOL)value_;

//- (BOOL)validateClosedFlag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* completeFlag;



@property BOOL completeFlagValue;
- (BOOL)completeFlagValue;
- (void)setCompleteFlagValue:(BOOL)value_;

//- (BOOL)validateCompleteFlag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* createddate;



//- (BOOL)validateCreateddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateCreated;



//- (BOOL)validateDateCreated:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateModified;



//- (BOOL)validateDateModified:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastmoddate;



//- (BOOL)validateLastmoddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* score;



@property int16_t scoreValue;
- (int16_t)scoreValue;
- (void)setScoreValue:(int16_t)value_;

//- (BOOL)validateScore:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wmbradenscale_id;



//- (BOOL)validateWmbradenscale_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMPatient *patient;

//- (BOOL)validatePatient:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *sections;

- (NSMutableSet*)sectionsSet;





@end

@interface _WMBradenScale (CoreDataGeneratedAccessors)

- (void)addSections:(NSSet*)value_;
- (void)removeSections:(NSSet*)value_;
- (void)addSectionsObject:(WMBradenSection*)value_;
- (void)removeSectionsObject:(WMBradenSection*)value_;

@end

@interface _WMBradenScale (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveClosedFlag;
- (void)setPrimitiveClosedFlag:(NSNumber*)value;

- (BOOL)primitiveClosedFlagValue;
- (void)setPrimitiveClosedFlagValue:(BOOL)value_;




- (NSNumber*)primitiveCompleteFlag;
- (void)setPrimitiveCompleteFlag:(NSNumber*)value;

- (BOOL)primitiveCompleteFlagValue;
- (void)setPrimitiveCompleteFlagValue:(BOOL)value_;




- (NSDate*)primitiveCreateddate;
- (void)setPrimitiveCreateddate:(NSDate*)value;




- (NSDate*)primitiveDateCreated;
- (void)setPrimitiveDateCreated:(NSDate*)value;




- (NSDate*)primitiveDateModified;
- (void)setPrimitiveDateModified:(NSDate*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSDate*)primitiveLastmoddate;
- (void)setPrimitiveLastmoddate:(NSDate*)value;




- (NSNumber*)primitiveScore;
- (void)setPrimitiveScore:(NSNumber*)value;

- (int16_t)primitiveScoreValue;
- (void)setPrimitiveScoreValue:(int16_t)value_;




- (NSString*)primitiveWmbradenscale_id;
- (void)setPrimitiveWmbradenscale_id:(NSString*)value;





- (WMPatient*)primitivePatient;
- (void)setPrimitivePatient:(WMPatient*)value;



- (NSMutableSet*)primitiveSections;
- (void)setPrimitiveSections:(NSMutableSet*)value;


@end
