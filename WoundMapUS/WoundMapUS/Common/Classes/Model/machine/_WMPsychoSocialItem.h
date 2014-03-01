// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMPsychoSocialItem.h instead.

#import <CoreData/CoreData.h>


extern const struct WMPsychoSocialItemAttributes {
	__unsafe_unretained NSString *createddate;
	__unsafe_unretained NSString *definition;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *iapIdentifier;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *loincCode;
	__unsafe_unretained NSString *options;
	__unsafe_unretained NSString *prefixTitle;
	__unsafe_unretained NSString *score;
	__unsafe_unretained NSString *sectionTitle;
	__unsafe_unretained NSString *snomedCID;
	__unsafe_unretained NSString *snomedFSN;
	__unsafe_unretained NSString *sortRank;
	__unsafe_unretained NSString *subitemPrompt;
	__unsafe_unretained NSString *subtitle;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *valueTypeCode;
	__unsafe_unretained NSString *wmpsychosocialitem_id;
} WMPsychoSocialItemAttributes;

extern const struct WMPsychoSocialItemRelationships {
	__unsafe_unretained NSString *parentItem;
	__unsafe_unretained NSString *subitems;
	__unsafe_unretained NSString *values;
	__unsafe_unretained NSString *woundTypes;
} WMPsychoSocialItemRelationships;

extern const struct WMPsychoSocialItemFetchedProperties {
} WMPsychoSocialItemFetchedProperties;

@class WMPsychoSocialItem;
@class WMPsychoSocialItem;
@class WMPsychoSocialValue;
@class WMWoundType;




















@interface WMPsychoSocialItemID : NSManagedObjectID {}
@end

@interface _WMPsychoSocialItem : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMPsychoSocialItemID*)objectID;





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





@property (nonatomic, strong) NSString* options;



//- (BOOL)validateOptions:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* prefixTitle;



//- (BOOL)validatePrefixTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* score;



@property int16_t scoreValue;
- (int16_t)scoreValue;
- (void)setScoreValue:(int16_t)value_;

//- (BOOL)validateScore:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* sectionTitle;



//- (BOOL)validateSectionTitle:(id*)value_ error:(NSError**)error_;





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





@property (nonatomic, strong) NSString* subitemPrompt;



//- (BOOL)validateSubitemPrompt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* subtitle;



//- (BOOL)validateSubtitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* valueTypeCode;



@property int16_t valueTypeCodeValue;
- (int16_t)valueTypeCodeValue;
- (void)setValueTypeCodeValue:(int16_t)value_;

//- (BOOL)validateValueTypeCode:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wmpsychosocialitem_id;



//- (BOOL)validateWmpsychosocialitem_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMPsychoSocialItem *parentItem;

//- (BOOL)validateParentItem:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *subitems;

- (NSMutableSet*)subitemsSet;




@property (nonatomic, strong) NSSet *values;

- (NSMutableSet*)valuesSet;




@property (nonatomic, strong) NSSet *woundTypes;

- (NSMutableSet*)woundTypesSet;





@end

@interface _WMPsychoSocialItem (CoreDataGeneratedAccessors)

- (void)addSubitems:(NSSet*)value_;
- (void)removeSubitems:(NSSet*)value_;
- (void)addSubitemsObject:(WMPsychoSocialItem*)value_;
- (void)removeSubitemsObject:(WMPsychoSocialItem*)value_;

- (void)addValues:(NSSet*)value_;
- (void)removeValues:(NSSet*)value_;
- (void)addValuesObject:(WMPsychoSocialValue*)value_;
- (void)removeValuesObject:(WMPsychoSocialValue*)value_;

- (void)addWoundTypes:(NSSet*)value_;
- (void)removeWoundTypes:(NSSet*)value_;
- (void)addWoundTypesObject:(WMWoundType*)value_;
- (void)removeWoundTypesObject:(WMWoundType*)value_;

@end

@interface _WMPsychoSocialItem (CoreDataGeneratedPrimitiveAccessors)


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




- (NSString*)primitiveOptions;
- (void)setPrimitiveOptions:(NSString*)value;




- (NSString*)primitivePrefixTitle;
- (void)setPrimitivePrefixTitle:(NSString*)value;




- (NSNumber*)primitiveScore;
- (void)setPrimitiveScore:(NSNumber*)value;

- (int16_t)primitiveScoreValue;
- (void)setPrimitiveScoreValue:(int16_t)value_;




- (NSString*)primitiveSectionTitle;
- (void)setPrimitiveSectionTitle:(NSString*)value;




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




- (NSString*)primitiveSubitemPrompt;
- (void)setPrimitiveSubitemPrompt:(NSString*)value;




- (NSString*)primitiveSubtitle;
- (void)setPrimitiveSubtitle:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSNumber*)primitiveValueTypeCode;
- (void)setPrimitiveValueTypeCode:(NSNumber*)value;

- (int16_t)primitiveValueTypeCodeValue;
- (void)setPrimitiveValueTypeCodeValue:(int16_t)value_;




- (NSString*)primitiveWmpsychosocialitem_id;
- (void)setPrimitiveWmpsychosocialitem_id:(NSString*)value;





- (WMPsychoSocialItem*)primitiveParentItem;
- (void)setPrimitiveParentItem:(WMPsychoSocialItem*)value;



- (NSMutableSet*)primitiveSubitems;
- (void)setPrimitiveSubitems:(NSMutableSet*)value;



- (NSMutableSet*)primitiveValues;
- (void)setPrimitiveValues:(NSMutableSet*)value;



- (NSMutableSet*)primitiveWoundTypes;
- (void)setPrimitiveWoundTypes:(NSMutableSet*)value;


@end
