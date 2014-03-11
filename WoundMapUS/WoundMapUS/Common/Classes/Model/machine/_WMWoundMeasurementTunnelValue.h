// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundMeasurementTunnelValue.h instead.

#import <CoreData/CoreData.h>
#import "WMWoundMeasurementValue.h"

extern const struct WMWoundMeasurementTunnelValueAttributes {
	__unsafe_unretained NSString *fromOClockValue;
	__unsafe_unretained NSString *sectionTitle;
	__unsafe_unretained NSString *sortRank;
} WMWoundMeasurementTunnelValueAttributes;

extern const struct WMWoundMeasurementTunnelValueRelationships {
} WMWoundMeasurementTunnelValueRelationships;

extern const struct WMWoundMeasurementTunnelValueFetchedProperties {
} WMWoundMeasurementTunnelValueFetchedProperties;






@interface WMWoundMeasurementTunnelValueID : NSManagedObjectID {}
@end

@interface _WMWoundMeasurementTunnelValue : WMWoundMeasurementValue {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMWoundMeasurementTunnelValueID*)objectID;





@property (nonatomic, strong) NSNumber* fromOClockValue;



@property int16_t fromOClockValueValue;
- (int16_t)fromOClockValueValue;
- (void)setFromOClockValueValue:(int16_t)value_;

//- (BOOL)validateFromOClockValue:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* sectionTitle;



//- (BOOL)validateSectionTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sortRank;



@property int16_t sortRankValue;
- (int16_t)sortRankValue;
- (void)setSortRankValue:(int16_t)value_;

//- (BOOL)validateSortRank:(id*)value_ error:(NSError**)error_;






@end

@interface _WMWoundMeasurementTunnelValue (CoreDataGeneratedAccessors)

@end

@interface _WMWoundMeasurementTunnelValue (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveFromOClockValue;
- (void)setPrimitiveFromOClockValue:(NSNumber*)value;

- (int16_t)primitiveFromOClockValueValue;
- (void)setPrimitiveFromOClockValueValue:(int16_t)value_;




- (NSString*)primitiveSectionTitle;
- (void)setPrimitiveSectionTitle:(NSString*)value;




- (NSNumber*)primitiveSortRank;
- (void)setPrimitiveSortRank:(NSNumber*)value;

- (int16_t)primitiveSortRankValue;
- (void)setPrimitiveSortRankValue:(int16_t)value_;




@end
