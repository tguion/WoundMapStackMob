// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMCarePlanInterventionEvent.h instead.

#import <CoreData/CoreData.h>
#import "WMInterventionEvent.h"

extern const struct WMCarePlanInterventionEventAttributes {
	__unsafe_unretained NSString *wmcareplaninterventionevent_id;
} WMCarePlanInterventionEventAttributes;

extern const struct WMCarePlanInterventionEventRelationships {
	__unsafe_unretained NSString *carePlanGroup;
} WMCarePlanInterventionEventRelationships;

extern const struct WMCarePlanInterventionEventFetchedProperties {
} WMCarePlanInterventionEventFetchedProperties;

@class WMCarePlanGroup;



@interface WMCarePlanInterventionEventID : NSManagedObjectID {}
@end

@interface _WMCarePlanInterventionEvent : WMInterventionEvent {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMCarePlanInterventionEventID*)objectID;





@property (nonatomic, strong) NSString* wmcareplaninterventionevent_id;



//- (BOOL)validateWmcareplaninterventionevent_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMCarePlanGroup *carePlanGroup;

//- (BOOL)validateCarePlanGroup:(id*)value_ error:(NSError**)error_;





@end

@interface _WMCarePlanInterventionEvent (CoreDataGeneratedAccessors)

@end

@interface _WMCarePlanInterventionEvent (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveWmcareplaninterventionevent_id;
- (void)setPrimitiveWmcareplaninterventionevent_id:(NSString*)value;





- (WMCarePlanGroup*)primitiveCarePlanGroup;
- (void)setPrimitiveCarePlanGroup:(WMCarePlanGroup*)value;


@end
