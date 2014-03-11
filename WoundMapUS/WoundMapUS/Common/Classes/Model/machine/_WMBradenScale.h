// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMBradenScale.h instead.

#import <CoreData/CoreData.h>


extern const struct WMBradenScaleAttributes {
	__unsafe_unretained NSString *closedFlag;
	__unsafe_unretained NSString *completeFlag;
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *score;
	__unsafe_unretained NSString *updatedAt;
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





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* score;



@property int16_t scoreValue;
- (int16_t)scoreValue;
- (void)setScoreValue:(int16_t)value_;

//- (BOOL)validateScore:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





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




- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSNumber*)primitiveScore;
- (void)setPrimitiveScore:(NSNumber*)value;

- (int16_t)primitiveScoreValue;
- (void)setPrimitiveScoreValue:(int16_t)value_;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;





- (WMPatient*)primitivePatient;
- (void)setPrimitivePatient:(WMPatient*)value;



- (NSMutableSet*)primitiveSections;
- (void)setPrimitiveSections:(NSMutableSet*)value;


@end
