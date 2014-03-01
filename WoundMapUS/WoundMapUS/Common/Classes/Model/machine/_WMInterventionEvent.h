// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WMInterventionEvent.h instead.

#import <CoreData/CoreData.h>


extern const struct WMInterventionEventAttributes {
	__unsafe_unretained NSString *changeType;
	__unsafe_unretained NSString *createddate;
	__unsafe_unretained NSString *dateEvent;
	__unsafe_unretained NSString *datePushed;
	__unsafe_unretained NSString *lastmoddate;
	__unsafe_unretained NSString *path;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *valueFrom;
	__unsafe_unretained NSString *valueTo;
	__unsafe_unretained NSString *wminterventionevent_id;
} WMInterventionEventAttributes;

extern const struct WMInterventionEventRelationships {
	__unsafe_unretained NSString *eventType;
	__unsafe_unretained NSString *participant;
} WMInterventionEventRelationships;

extern const struct WMInterventionEventFetchedProperties {
} WMInterventionEventFetchedProperties;

@class WMInterventionEventType;
@class WMParticipant;












@interface WMInterventionEventID : NSManagedObjectID {}
@end

@interface _WMInterventionEvent : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WMInterventionEventID*)objectID;





@property (nonatomic, strong) NSNumber* changeType;



@property int16_t changeTypeValue;
- (int16_t)changeTypeValue;
- (void)setChangeTypeValue:(int16_t)value_;

//- (BOOL)validateChangeType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* createddate;



//- (BOOL)validateCreateddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateEvent;



//- (BOOL)validateDateEvent:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* datePushed;



//- (BOOL)validateDatePushed:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastmoddate;



//- (BOOL)validateLastmoddate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* path;



//- (BOOL)validatePath:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* valueFrom;



//- (BOOL)validateValueFrom:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* valueTo;



//- (BOOL)validateValueTo:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wminterventionevent_id;



//- (BOOL)validateWminterventionevent_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) WMInterventionEventType *eventType;

//- (BOOL)validateEventType:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) WMParticipant *participant;

//- (BOOL)validateParticipant:(id*)value_ error:(NSError**)error_;





@end

@interface _WMInterventionEvent (CoreDataGeneratedAccessors)

@end

@interface _WMInterventionEvent (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveChangeType;
- (void)setPrimitiveChangeType:(NSNumber*)value;

- (int16_t)primitiveChangeTypeValue;
- (void)setPrimitiveChangeTypeValue:(int16_t)value_;




- (NSDate*)primitiveCreateddate;
- (void)setPrimitiveCreateddate:(NSDate*)value;




- (NSDate*)primitiveDateEvent;
- (void)setPrimitiveDateEvent:(NSDate*)value;




- (NSDate*)primitiveDatePushed;
- (void)setPrimitiveDatePushed:(NSDate*)value;




- (NSDate*)primitiveLastmoddate;
- (void)setPrimitiveLastmoddate:(NSDate*)value;




- (NSString*)primitivePath;
- (void)setPrimitivePath:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSString*)primitiveValueFrom;
- (void)setPrimitiveValueFrom:(NSString*)value;




- (NSString*)primitiveValueTo;
- (void)setPrimitiveValueTo:(NSString*)value;




- (NSString*)primitiveWminterventionevent_id;
- (void)setPrimitiveWminterventionevent_id:(NSString*)value;





- (WMInterventionEventType*)primitiveEventType;
- (void)setPrimitiveEventType:(WMInterventionEventType*)value;



- (WMParticipant*)primitiveParticipant;
- (void)setPrimitiveParticipant:(WMParticipant*)value;


@end
