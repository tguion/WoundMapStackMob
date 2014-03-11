// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMNavigationTrack.h instead.

#import <CoreData/CoreData.h>


extern const struct WMNavigationTrackAttributes {
	__unsafe_unretained NSString *activeFlag;
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *desc;
	__unsafe_unretained NSString *disabledFlag;
	__unsafe_unretained NSString *displayTitle;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *icon;
	__unsafe_unretained NSString *sortRank;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *updatedAt;
} WMNavigationTrackAttributes;

extern const struct WMNavigationTrackRelationships {
	__unsafe_unretained NSString *stages;
} WMNavigationTrackRelationships;

extern const struct WMNavigationTrackFetchedProperties {
} WMNavigationTrackFetchedProperties;

@class WMNavigationStage;













@interface WMNavigationTrackID : NSManagedObjectID {}
@end

@interface _WMNavigationTrack : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMNavigationTrackID*)objectID;





@property (nonatomic, strong) NSNumber* activeFlag;



@property BOOL activeFlagValue;
- (BOOL)activeFlagValue;
- (void)setActiveFlagValue:(BOOL)value_;

//- (BOOL)validateActiveFlag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* desc;



//- (BOOL)validateDesc:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* disabledFlag;



@property BOOL disabledFlagValue;
- (BOOL)disabledFlagValue;
- (void)setDisabledFlagValue:(BOOL)value_;

//- (BOOL)validateDisabledFlag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* displayTitle;



//- (BOOL)validateDisplayTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* icon;



//- (BOOL)validateIcon:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sortRank;



@property int16_t sortRankValue;
- (int16_t)sortRankValue;
- (void)setSortRankValue:(int16_t)value_;

//- (BOOL)validateSortRank:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *stages;

- (NSMutableSet*)stagesSet;





@end

@interface _WMNavigationTrack (CoreDataGeneratedAccessors)

- (void)addStages:(NSSet*)value_;
- (void)removeStages:(NSSet*)value_;
- (void)addStagesObject:(WMNavigationStage*)value_;
- (void)removeStagesObject:(WMNavigationStage*)value_;

@end

@interface _WMNavigationTrack (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveActiveFlag;
- (void)setPrimitiveActiveFlag:(NSNumber*)value;

- (BOOL)primitiveActiveFlagValue;
- (void)setPrimitiveActiveFlagValue:(BOOL)value_;




- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSString*)primitiveDesc;
- (void)setPrimitiveDesc:(NSString*)value;




- (NSNumber*)primitiveDisabledFlag;
- (void)setPrimitiveDisabledFlag:(NSNumber*)value;

- (BOOL)primitiveDisabledFlagValue;
- (void)setPrimitiveDisabledFlagValue:(BOOL)value_;




- (NSString*)primitiveDisplayTitle;
- (void)setPrimitiveDisplayTitle:(NSString*)value;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSString*)primitiveIcon;
- (void)setPrimitiveIcon:(NSString*)value;




- (NSNumber*)primitiveSortRank;
- (void)setPrimitiveSortRank:(NSNumber*)value;

- (int16_t)primitiveSortRankValue;
- (void)setPrimitiveSortRankValue:(int16_t)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;





- (NSMutableSet*)primitiveStages;
- (void)setPrimitiveStages:(NSMutableSet*)value;


@end
