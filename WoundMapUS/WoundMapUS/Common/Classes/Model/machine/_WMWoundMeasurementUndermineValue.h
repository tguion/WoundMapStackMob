// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundMeasurementUndermineValue.h instead.

#import <CoreData/CoreData.h>
#import "WMWoundMeasurementTunnelValue.h"

extern const struct WMWoundMeasurementUndermineValueAttributes {
	__unsafe_unretained NSString *toOClockValue;
	__unsafe_unretained NSString *wmwoundmeasurementunderminevalue_id;
} WMWoundMeasurementUndermineValueAttributes;

extern const struct WMWoundMeasurementUndermineValueRelationships {
} WMWoundMeasurementUndermineValueRelationships;

extern const struct WMWoundMeasurementUndermineValueFetchedProperties {
} WMWoundMeasurementUndermineValueFetchedProperties;





@interface WMWoundMeasurementUndermineValueID : NSManagedObjectID {}
@end

@interface _WMWoundMeasurementUndermineValue : WMWoundMeasurementTunnelValue {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMWoundMeasurementUndermineValueID*)objectID;





@property (nonatomic, strong) NSNumber* toOClockValue;



@property int16_t toOClockValueValue;
- (int16_t)toOClockValueValue;
- (void)setToOClockValueValue:(int16_t)value_;

//- (BOOL)validateToOClockValue:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wmwoundmeasurementunderminevalue_id;



//- (BOOL)validateWmwoundmeasurementunderminevalue_id:(id*)value_ error:(NSError**)error_;






@end

@interface _WMWoundMeasurementUndermineValue (CoreDataGeneratedAccessors)

@end

@interface _WMWoundMeasurementUndermineValue (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveToOClockValue;
- (void)setPrimitiveToOClockValue:(NSNumber*)value;

- (int16_t)primitiveToOClockValueValue;
- (void)setPrimitiveToOClockValueValue:(int16_t)value_;




- (NSString*)primitiveWmwoundmeasurementunderminevalue_id;
- (void)setPrimitiveWmwoundmeasurementunderminevalue_id:(NSString*)value;




@end
