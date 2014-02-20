// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMInstruction.h instead.

#import <CoreData/CoreData.h>


extern const struct WMInstructionAttributes {
	__unsafe_unretained NSString *contentFileExtension;
	__unsafe_unretained NSString *contentFileName;
	__unsafe_unretained NSString *createddate;
	__unsafe_unretained NSString *desc;
	__unsafe_unretained NSString *flags;
	__unsafe_unretained NSString *iconFileName;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *sortRank;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *wminstruction_id;
} WMInstructionAttributes;

extern const struct WMInstructionRelationships {
} WMInstructionRelationships;

extern const struct WMInstructionFetchedProperties {
} WMInstructionFetchedProperties;













@interface WMInstructionID : NSManagedObjectID {}
@end

@interface _WMInstruction : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMInstructionID*)objectID;





@property (nonatomic, strong) NSString* contentFileExtension;



//- (BOOL)validateContentFileExtension:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* contentFileName;



//- (BOOL)validateContentFileName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* createddate;



//- (BOOL)validateCreateddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* desc;



//- (BOOL)validateDesc:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* flags;



@property int32_t flagsValue;
- (int32_t)flagsValue;
- (void)setFlagsValue:(int32_t)value_;

//- (BOOL)validateFlags:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* iconFileName;



//- (BOOL)validateIconFileName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastmoddate;



//- (BOOL)validateLastmoddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sortRank;



@property int16_t sortRankValue;
- (int16_t)sortRankValue;
- (void)setSortRankValue:(int16_t)value_;

//- (BOOL)validateSortRank:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wminstruction_id;



//- (BOOL)validateWminstruction_id:(id*)value_ error:(NSError**)error_;






@end

@interface _WMInstruction (CoreDataGeneratedAccessors)

@end

@interface _WMInstruction (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveContentFileExtension;
- (void)setPrimitiveContentFileExtension:(NSString*)value;




- (NSString*)primitiveContentFileName;
- (void)setPrimitiveContentFileName:(NSString*)value;




- (NSDate*)primitiveCreateddate;
- (void)setPrimitiveCreateddate:(NSDate*)value;




- (NSString*)primitiveDesc;
- (void)setPrimitiveDesc:(NSString*)value;




- (NSNumber*)primitiveFlags;
- (void)setPrimitiveFlags:(NSNumber*)value;

- (int32_t)primitiveFlagsValue;
- (void)setPrimitiveFlagsValue:(int32_t)value_;




- (NSString*)primitiveIconFileName;
- (void)setPrimitiveIconFileName:(NSString*)value;




- (NSDate*)primitiveLastmoddate;
- (void)setPrimitiveLastmoddate:(NSDate*)value;




- (NSNumber*)primitiveSortRank;
- (void)setPrimitiveSortRank:(NSNumber*)value;

- (int16_t)primitiveSortRankValue;
- (void)setPrimitiveSortRankValue:(int16_t)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSString*)primitiveWminstruction_id;
- (void)setPrimitiveWminstruction_id:(NSString*)value;




@end
