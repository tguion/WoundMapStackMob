// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMDeviceInterventionEvent.h instead.

#import <CoreData/CoreData.h>
#import "WMInterventionEvent.h"

extern const struct WMDeviceInterventionEventAttributes {
	__unsafe_unretained NSString *wmdeviceinterventionevent_id;
} WMDeviceInterventionEventAttributes;

extern const struct WMDeviceInterventionEventRelationships {
	__unsafe_unretained NSString *deviceGroup;
} WMDeviceInterventionEventRelationships;

extern const struct WMDeviceInterventionEventFetchedProperties {
} WMDeviceInterventionEventFetchedProperties;

@class WMDeviceGroup;



@interface WMDeviceInterventionEventID : NSManagedObjectID {}
@end

@interface _WMDeviceInterventionEvent : WMInterventionEvent {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMDeviceInterventionEventID*)objectID;





@property (nonatomic, strong) NSString* wmdeviceinterventionevent_id;



//- (BOOL)validateWmdeviceinterventionevent_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMDeviceGroup *deviceGroup;

//- (BOOL)validateDeviceGroup:(id*)value_ error:(NSError**)error_;





@end

@interface _WMDeviceInterventionEvent (CoreDataGeneratedAccessors)

@end

@interface _WMDeviceInterventionEvent (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveWmdeviceinterventionevent_id;
- (void)setPrimitiveWmdeviceinterventionevent_id:(NSString*)value;





- (WMDeviceGroup*)primitiveDeviceGroup;
- (void)setPrimitiveDeviceGroup:(WMDeviceGroup*)value;


@end
