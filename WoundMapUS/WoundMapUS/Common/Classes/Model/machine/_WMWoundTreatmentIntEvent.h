// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMWoundTreatmentIntEvent.h instead.

#import <CoreData/CoreData.h>
#import "WMInterventionEvent.h"

extern const struct WMWoundTreatmentIntEventAttributes {
	__unsafe_unretained NSString *wmwoundtreatmentinterventionevent_id;
} WMWoundTreatmentIntEventAttributes;

extern const struct WMWoundTreatmentIntEventRelationships {
	__unsafe_unretained NSString *treatmentGroup;
} WMWoundTreatmentIntEventRelationships;

extern const struct WMWoundTreatmentIntEventFetchedProperties {
} WMWoundTreatmentIntEventFetchedProperties;

@class WMWoundTreatmentGroup;



@interface WMWoundTreatmentIntEventID : NSManagedObjectID {}
@end

@interface _WMWoundTreatmentIntEvent : WMInterventionEvent {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMWoundTreatmentIntEventID*)objectID;





@property (nonatomic, strong) NSString* wmwoundtreatmentinterventionevent_id;



//- (BOOL)validateWmwoundtreatmentinterventionevent_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMWoundTreatmentGroup *treatmentGroup;

//- (BOOL)validateTreatmentGroup:(id*)value_ error:(NSError**)error_;





@end

@interface _WMWoundTreatmentIntEvent (CoreDataGeneratedAccessors)

@end

@interface _WMWoundTreatmentIntEvent (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveWmwoundtreatmentinterventionevent_id;
- (void)setPrimitiveWmwoundtreatmentinterventionevent_id:(NSString*)value;





- (WMWoundTreatmentGroup*)primitiveTreatmentGroup;
- (void)setPrimitiveTreatmentGroup:(WMWoundTreatmentGroup*)value;


@end
