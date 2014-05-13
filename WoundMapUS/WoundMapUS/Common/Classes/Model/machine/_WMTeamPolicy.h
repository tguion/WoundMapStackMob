// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMTeamPolicy.h instead.

#import <CoreData/CoreData.h>


extern const struct WMTeamPolicyAttributes {
	__unsafe_unretained NSString *createdAt;
	__unsafe_unretained NSString *deletePhotoBlobs;
	__unsafe_unretained NSString *ffUrl;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *numberOfMonthsToDeletePhotoBlobs;
	__unsafe_unretained NSString *updatedAt;
} WMTeamPolicyAttributes;

extern const struct WMTeamPolicyRelationships {
	__unsafe_unretained NSString *team;
} WMTeamPolicyRelationships;

extern const struct WMTeamPolicyFetchedProperties {
} WMTeamPolicyFetchedProperties;

@class WMTeam;








@interface WMTeamPolicyID : NSManagedObjectID {}
@end

@interface _WMTeamPolicy : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMTeamPolicyID*)objectID;





@property (nonatomic, strong) NSDate* createdAt;



//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* deletePhotoBlobs;



@property BOOL deletePhotoBlobsValue;
- (BOOL)deletePhotoBlobsValue;
- (void)setDeletePhotoBlobsValue:(BOOL)value_;

//- (BOOL)validateDeletePhotoBlobs:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* ffUrl;



//- (BOOL)validateFfUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* numberOfMonthsToDeletePhotoBlobs;



@property int16_t numberOfMonthsToDeletePhotoBlobsValue;
- (int16_t)numberOfMonthsToDeletePhotoBlobsValue;
- (void)setNumberOfMonthsToDeletePhotoBlobsValue:(int16_t)value_;

//- (BOOL)validateNumberOfMonthsToDeletePhotoBlobs:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updatedAt;



//- (BOOL)validateUpdatedAt:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMTeam *team;

//- (BOOL)validateTeam:(id*)value_ error:(NSError**)error_;





@end

@interface _WMTeamPolicy (CoreDataGeneratedAccessors)

@end

@interface _WMTeamPolicy (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSNumber*)primitiveDeletePhotoBlobs;
- (void)setPrimitiveDeletePhotoBlobs:(NSNumber*)value;

- (BOOL)primitiveDeletePhotoBlobsValue;
- (void)setPrimitiveDeletePhotoBlobsValue:(BOOL)value_;




- (NSString*)primitiveFfUrl;
- (void)setPrimitiveFfUrl:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSNumber*)primitiveNumberOfMonthsToDeletePhotoBlobs;
- (void)setPrimitiveNumberOfMonthsToDeletePhotoBlobs:(NSNumber*)value;

- (int16_t)primitiveNumberOfMonthsToDeletePhotoBlobsValue;
- (void)setPrimitiveNumberOfMonthsToDeletePhotoBlobsValue:(int16_t)value_;




- (NSDate*)primitiveUpdatedAt;
- (void)setPrimitiveUpdatedAt:(NSDate*)value;





- (WMTeam*)primitiveTeam;
- (void)setPrimitiveTeam:(WMTeam*)value;


@end
