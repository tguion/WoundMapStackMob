// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMSkinAssessmentCategory.h instead.

#import <CoreData/CoreData.h>


extern const struct WMSkinAssessmentCategoryAttributes {
	__unsafe_unretained NSString *createddate;
	__unsafe_unretained NSString *definition;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *iapIdentifier;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *loincCode;
	__unsafe_unretained NSString *section;
	__unsafe_unretained NSString *snomedCID;
	__unsafe_unretained NSString *snomedFSN;
	__unsafe_unretained NSString *sortRank;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *wmskinassessmentcategory_id;
} WMSkinAssessmentCategoryAttributes;

extern const struct WMSkinAssessmentCategoryRelationships {
	__unsafe_unretained NSString *assessments;
	__unsafe_unretained NSString *woundTypes;
} WMSkinAssessmentCategoryRelationships;

extern const struct WMSkinAssessmentCategoryFetchedProperties {
} WMSkinAssessmentCategoryFetchedProperties;

@class WMSkinAssessment;
@class WMWoundType;














@interface WMSkinAssessmentCategoryID : NSManagedObjectID {}
@end

@interface _WMSkinAssessmentCategory : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMSkinAssessmentCategoryID*)objectID;





@property (nonatomic, strong) NSDate* createddate;



//- (BOOL)validateCreateddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* definition;



//- (BOOL)validateDefinition:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* iapIdentifier;



//- (BOOL)validateIapIdentifier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastmoddate;



//- (BOOL)validateLastmoddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* loincCode;



//- (BOOL)validateLoincCode:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* section;



//- (BOOL)validateSection:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* snomedCID;



@property int64_t snomedCIDValue;
- (int64_t)snomedCIDValue;
- (void)setSnomedCIDValue:(int64_t)value_;

//- (BOOL)validateSnomedCID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* snomedFSN;



//- (BOOL)validateSnomedFSN:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sortRank;



@property int16_t sortRankValue;
- (int16_t)sortRankValue;
- (void)setSortRankValue:(int16_t)value_;

//- (BOOL)validateSortRank:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wmskinassessmentcategory_id;



//- (BOOL)validateWmskinassessmentcategory_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *assessments;

- (NSMutableSet*)assessmentsSet;




@property (nonatomic, strong) NSSet *woundTypes;

- (NSMutableSet*)woundTypesSet;





@end

@interface _WMSkinAssessmentCategory (CoreDataGeneratedAccessors)

- (void)addAssessments:(NSSet*)value_;
- (void)removeAssessments:(NSSet*)value_;
- (void)addAssessmentsObject:(WMSkinAssessment*)value_;
- (void)removeAssessmentsObject:(WMSkinAssessment*)value_;

- (void)addWoundTypes:(NSSet*)value_;
- (void)removeWoundTypes:(NSSet*)value_;
- (void)addWoundTypesObject:(WMWoundType*)value_;
- (void)removeWoundTypesObject:(WMWoundType*)value_;

@end

@interface _WMSkinAssessmentCategory (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreateddate;
- (void)setPrimitiveCreateddate:(NSDate*)value;




- (NSString*)primitiveDefinition;
- (void)setPrimitiveDefinition:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSString*)primitiveIapIdentifier;
- (void)setPrimitiveIapIdentifier:(NSString*)value;




- (NSDate*)primitiveLastmoddate;
- (void)setPrimitiveLastmoddate:(NSDate*)value;




- (NSString*)primitiveLoincCode;
- (void)setPrimitiveLoincCode:(NSString*)value;




- (NSString*)primitiveSection;
- (void)setPrimitiveSection:(NSString*)value;




- (NSNumber*)primitiveSnomedCID;
- (void)setPrimitiveSnomedCID:(NSNumber*)value;

- (int64_t)primitiveSnomedCIDValue;
- (void)setPrimitiveSnomedCIDValue:(int64_t)value_;




- (NSString*)primitiveSnomedFSN;
- (void)setPrimitiveSnomedFSN:(NSString*)value;




- (NSNumber*)primitiveSortRank;
- (void)setPrimitiveSortRank:(NSNumber*)value;

- (int16_t)primitiveSortRankValue;
- (void)setPrimitiveSortRankValue:(int16_t)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSString*)primitiveWmskinassessmentcategory_id;
- (void)setPrimitiveWmskinassessmentcategory_id:(NSString*)value;





- (NSMutableSet*)primitiveAssessments;
- (void)setPrimitiveAssessments:(NSMutableSet*)value;



- (NSMutableSet*)primitiveWoundTypes;
- (void)setPrimitiveWoundTypes:(NSMutableSet*)value;


@end
