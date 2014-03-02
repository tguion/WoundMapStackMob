// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMSkinAssessmentIntEvent.h instead.

#import <CoreData/CoreData.h>
#import "WMInterventionEvent.h"

extern const struct WMSkinAssessmentIntEventAttributes {
	__unsafe_unretained NSString *wmskinassessmentinterventionevent_id;
} WMSkinAssessmentIntEventAttributes;

extern const struct WMSkinAssessmentIntEventRelationships {
	__unsafe_unretained NSString *skinAssessmentGroup;
} WMSkinAssessmentIntEventRelationships;

extern const struct WMSkinAssessmentIntEventFetchedProperties {
} WMSkinAssessmentIntEventFetchedProperties;

@class WMSkinAssessmentGroup;



@interface WMSkinAssessmentIntEventID : NSManagedObjectID {}
@end

@interface _WMSkinAssessmentIntEvent : WMInterventionEvent {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMSkinAssessmentIntEventID*)objectID;





@property (nonatomic, strong) NSString* wmskinassessmentinterventionevent_id;



//- (BOOL)validateWmskinassessmentinterventionevent_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMSkinAssessmentGroup *skinAssessmentGroup;

//- (BOOL)validateSkinAssessmentGroup:(id*)value_ error:(NSError**)error_;





@end

@interface _WMSkinAssessmentIntEvent (CoreDataGeneratedAccessors)

@end

@interface _WMSkinAssessmentIntEvent (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveWmskinassessmentinterventionevent_id;
- (void)setPrimitiveWmskinassessmentinterventionevent_id:(NSString*)value;





- (WMSkinAssessmentGroup*)primitiveSkinAssessmentGroup;
- (void)setPrimitiveSkinAssessmentGroup:(WMSkinAssessmentGroup*)value;


@end
