// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundMeasurementUnderValue.h instead.

#import <CoreData/CoreData.h>
#import "WMWoundMeasurementTunnelValue.h"

extern const struct WMWoundMeasurementUnderValueAttributes {
	__unsafe_unretained NSString *toOClockValue;
} WMWoundMeasurementUnderValueAttributes;

extern const struct WMWoundMeasurementUnderValueRelationships {
} WMWoundMeasurementUnderValueRelationships;

extern const struct WMWoundMeasurementUnderValueFetchedProperties {
} WMWoundMeasurementUnderValueFetchedProperties;




@interface WMWoundMeasurementUnderValueID : NSManagedObjectID {}
@end

@interface _WMWoundMeasurementUnderValue : WMWoundMeasurementTunnelValue {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMWoundMeasurementUnderValueID*)objectID;





@property (nonatomic, strong) NSNumber* toOClockValue;



@property int16_t toOClockValueValue;
- (int16_t)toOClockValueValue;
- (void)setToOClockValueValue:(int16_t)value_;

//- (BOOL)validateToOClockValue:(id*)value_ error:(NSError**)error_;






@end

@interface _WMWoundMeasurementUnderValue (CoreDataGeneratedAccessors)

@end

@interface _WMWoundMeasurementUnderValue (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveToOClockValue;
- (void)setPrimitiveToOClockValue:(NSNumber*)value;

- (int16_t)primitiveToOClockValueValue;
- (void)setPrimitiveToOClockValueValue:(int16_t)value_;




@end
