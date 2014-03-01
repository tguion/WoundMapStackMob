// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMSkinAssessmentInterventionEvent.h instead.

#import <CoreData/CoreData.h>
#import "WMInterventionEvent.h"

extern const struct WMSkinAssessmentInterventionEventAttributes {
	__unsafe_unretained NSString *wmskinassessmentinterventionevent_id;
} WMSkinAssessmentInterventionEventAttributes;

extern const struct WMSkinAssessmentInterventionEventRelationships {
	__unsafe_unretained NSString *skinAssessmentGroup;
} WMSkinAssessmentInterventionEventRelationships;

extern const struct WMSkinAssessmentInterventionEventFetchedProperties {
} WMSkinAssessmentInterventionEventFetchedProperties;

@class WMSkinAssessmentGroup;



@interface WMSkinAssessmentInterventionEventID : NSManagedObjectID {}
@end

@interface _WMSkinAssessmentInterventionEvent : WMInterventionEvent {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMSkinAssessmentInterventionEventID*)objectID;





@property (nonatomic, strong) NSString* wmskinassessmentinterventionevent_id;



//- (BOOL)validateWmskinassessmentinterventionevent_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMSkinAssessmentGroup *skinAssessmentGroup;

//- (BOOL)validateSkinAssessmentGroup:(id*)value_ error:(NSError**)error_;





@end

@interface _WMSkinAssessmentInterventionEvent (CoreDataGeneratedAccessors)

@end

@interface _WMSkinAssessmentInterventionEvent (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveWmskinassessmentinterventionevent_id;
- (void)setPrimitiveWmskinassessmentinterventionevent_id:(NSString*)value;





- (WMSkinAssessmentGroup*)primitiveSkinAssessmentGroup;
- (void)setPrimitiveSkinAssessmentGroup:(WMSkinAssessmentGroup*)value;


@end
