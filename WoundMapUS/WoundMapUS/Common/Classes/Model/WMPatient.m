#import "WMPatient.h"
#import "WMNavigationTrack.h"
#import "WMNavigationStage.h"
#import "WMMedicalHistoryGroup.h"
#import "WMParticipant.h"
#import "WMPerson.h"
#import "WMId.h"
#import "WMWound.h"
#import "WMWoundPhoto.h"
#import "WMPatientReferral.h"
#import "WMBradenScale.h"
#import "WMCarePlanGroup.h"
#import "WMCarePlanValue.h"
#import "WMDeviceGroup.h"
#import "WMDeviceValue.h"
#import "WMMedicalHistoryValue.h"
#import "WMMedicationGroup.h"
#import "WMNutritionGroup.h"
#import "WMNutritionValue.h"
#import "WMPsychoSocialGroup.h"
#import "WMPsychoSocialValue.h"
#import "WMSkinAssessmentGroup.h"
#import "WMSkinAssessmentValue.h"
#import "WMWoundMeasurementGroup.h"
#import "WMWoundMeasurementValue.h"
#import "WMWoundTreatmentGroup.h"
#import "WMWoundTreatmentValue.h"
#import "WMUtilities.h"
#import "WMFatFractal.h"

typedef enum {
    PatientFlagsFaceDetectionFailed         = 0,
    PatientFlagsFacePhotoTaken              = 1,
    PatientFlagsIsDeleting                  = 2,
} PatientFlags;

@interface WMPatient ()

@end


@implementation WMPatient {
    FFUserGroup *_consultantGroup;
}

@dynamic managedObjectContext, objectID;

static NSMutableDictionary *ffUrl2ConsultingGroupMap;

+ (void)initialize {
    if (self == [WMPatient class]) {
        ffUrl2ConsultingGroupMap = [[NSMutableDictionary alloc] init];
    }
}

+ (NSArray *)toManyRelationshipNames
{
    return @[WMPatientRelationships.bradenScales,
             WMPatientRelationships.carePlanGroups,
             WMPatientRelationships.deviceGroups,
             WMPatientRelationships.ids,
             WMPatientRelationships.medicationGroups,
             WMPatientRelationships.medicalHistoryGroups,
             WMPatientRelationships.patientConsultants,
             WMPatientRelationships.psychosocialGroups,
             WMPatientRelationships.skinAssessmentGroups,
             WMPatientRelationships.wounds];
}

// DEPLOYMENT: watch for additional relationships
+ (NSSet *)relationshipNamesAffectingCompassStatus
{
    static NSMutableSet *RelationshipNamesAffectingCompassStatus = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RelationshipNamesAffectingCompassStatus = [[NSMutableSet alloc] init];
        [RelationshipNamesAffectingCompassStatus addObjectsFromArray:@[[WMPatient entityName],
                                                                       [WMBradenScale entityName],
                                                                       [WMCarePlanGroup entityName],
                                                                       [WMCarePlanValue entityName],
                                                                       [WMDeviceGroup entityName],
                                                                       [WMDeviceValue entityName],
                                                                       [WMMedicalHistoryGroup entityName],
                                                                       [WMMedicalHistoryValue entityName],
                                                                       [WMMedicationGroup entityName],
                                                                       [WMNutritionGroup entityName],
                                                                       [WMNutritionValue entityName],
                                                                       [WMPsychoSocialGroup entityName],
                                                                       [WMPsychoSocialValue entityName],
                                                                       [WMSkinAssessmentGroup entityName],
                                                                       [WMSkinAssessmentValue entityName],
                                                                       [WMWound entityName],
                                                                       [WMWoundMeasurementGroup entityName],
                                                                       [WMWoundMeasurementValue entityName],
                                                                       [WMWoundTreatmentGroup entityName],
                                                                       [WMWoundTreatmentValue entityName]]];
    });
    return RelationshipNamesAffectingCompassStatus;
}

+ (NSInteger)patientCount:(NSManagedObjectContext *)managedObjectContext
{
    return [WMPatient MR_countOfEntitiesWithContext:managedObjectContext];
}

+ (NSInteger)patientCount:(NSManagedObjectContext *)managedObjectContext onDevice:(NSString *)deviceId
{
    return [WMPatient MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"%K == %@", WMPatientAttributes.createdOnDeviceId, deviceId] inContext:managedObjectContext];
}

+ (WMPatient *)patientForPatientFFURL:(NSString *)ffUrl managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    return [WMPatient MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"ffUrl == %@", ffUrl] inContext:managedObjectContext];
}

+ (WMPatient *)lastModifiedActivePatient:(NSManagedObjectContext *)managedObjectContext
{
    return [WMPatient MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"archivedFlag == NO"]
                                       sortedBy:@"updatedAt"
                                      ascending:NO
                                      inContext:managedObjectContext];
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

- (void)willTurnIntoFault
{
    if (_consultantGroup && self.ffUrl && !self.isDeleting) {
        [ffUrl2ConsultingGroupMap setObject:_consultantGroup forKey:self.ffUrl];
    }
}

- (void)prepareForDeletion
{
    [super prepareForDeletion];
    if (self.ffUrl) {
        [ffUrl2ConsultingGroupMap removeObjectForKey:self.ffUrl];
    }
}

+ (FFUserGroup *)consultantGroup:(NSString *)guid
{
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    FFUserGroup *consultantGroup = [[FFUserGroup alloc] initWithFF:ff];
    [consultantGroup setGroupName:guid];
    return consultantGroup;
}

// we loose this property when self is faulted
- (FFUserGroup *)consultantGroup
{
    if (nil == _consultantGroup) {
        if (self.ffUrl) {
            _consultantGroup = [ffUrl2ConsultingGroupMap objectForKey:self.ffUrl];
        } else {
            WMFatFractal *ff = [WMFatFractal sharedInstance];
            _consultantGroup = [[FFUserGroup alloc] initWithFF:ff];
            [_consultantGroup setGroupName:[[NSUUID UUID] UUIDString]];
        }
    }
    return _consultantGroup;
}

- (void)setConsultantGroup:(FFUserGroup *)consultantGroup
{
    if (_consultantGroup == consultantGroup) {
        return;
    }
    // else
    _consultantGroup = consultantGroup;
    if (_consultantGroup && self.ffUrl) {
        [ffUrl2ConsultingGroupMap setObject:_consultantGroup forKey:self.ffUrl];
    }
}

- (NSString *)lastNameFirstName
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:2];
    if ([self.person.nameFamily length] > 0) {
        [array addObject:self.person.nameFamily];
    }
    if ([self.person.nameGiven length] > 0) {
        [array addObject:self.person.nameGiven];
    }
    if ([array count] == 0 && [self.ids count] > 0) {
        [array addObject:[[[self.ids valueForKeyPath:@"extension"] allObjects] componentsJoinedByString:@","]];
    }
    if ([array count] == 0) {
        [array addObject:@"New Patient"];
    }
    return [array componentsJoinedByString:@", "];
}

- (NSString *)lastNameFirstNameOrAnonymous
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:2];
    if ([self.person.nameFamily length] > 0) {
        [array addObject:self.person.nameFamily];
    }
    if ([self.person.nameGiven length] > 0) {
        [array addObject:self.person.nameGiven];
    }
    if ([array count] == 0) {
        [array addObject:@"Anonymous"];
    }
    return [array componentsJoinedByString:@", "];
}

- (NSString *)identifierEMR
{
    return [[[self valueForKeyPath:@"ids.extension"] allObjects] componentsJoinedByString:@"."];
}

- (NSInteger)genderIndex
{
    NSInteger genderIndex = UISegmentedControlNoSegment;
    if ([@"M" isEqualToString:self.gender]) {
        genderIndex = 0;
    } else if ([@"F" isEqualToString:self.gender]) {
        genderIndex = 1;
    } else if ([@"U" isEqualToString:self.gender]) {
        genderIndex = 2;
    }
    return genderIndex;
}

- (UIImage *)thumbnailImage
{
    if (nil != self.thumbnail) {
        return self.thumbnail;
    }
    // else
    return [WMPatient missingThumbnailImage];
}

- (NSString *)updatePatientStatusMessages
{
    NSMutableArray *strings = [[NSMutableArray alloc] initWithCapacity:4];
    // wounds/photos
    NSArray *wounds = self.sortedWounds;
    if ([wounds count] > 1) {
        NSDate *date1 = nil;
        NSDate *date2 = nil;
        NSInteger woundPhotoCount = 0;
        for (WMWound *wound in wounds) {
            woundPhotoCount += wound.woundPhotosCount;
            NSDictionary *minimumMaximumDates = wound.minimumAndMaximumWoundPhotoDates;
            NSDate *date = minimumMaximumDates[@"minDate"];
            if (nil == date1 || [date compare:date1] == NSOrderedAscending) {
                date1 = date;
            }
            date = minimumMaximumDates[@"maxDate"];
            if (nil == date2 || [date compare:date2] == NSOrderedDescending) {
                date2 = date;
            }
        }
        if (nil == date1) {
            [strings addObject:[NSString stringWithFormat:@"Wounds: %lu, photos: none", (unsigned long)[wounds count]]];
            
        } else {
            [strings addObject:[NSString stringWithFormat:@"Wounds: %lu, photos: %ld (%@-%@)",
                                (unsigned long)[wounds count],
                                (long)woundPhotoCount,
                                [NSDateFormatter localizedStringFromDate:date1
                                                               dateStyle:NSDateFormatterShortStyle
                                                               timeStyle:NSDateFormatterNoStyle],
                                [NSDateFormatter localizedStringFromDate:date2
                                                               dateStyle:NSDateFormatterShortStyle
                                                               timeStyle:NSDateFormatterNoStyle]]];
        }
    } else if ([wounds count] == 1) {
        WMWound *wound = [wounds lastObject];
        NSInteger count = wound.woundPhotosCount;
        NSDictionary *minimumMaximumDates = wound.minimumAndMaximumWoundPhotoDates;
        if (0 == count) {
            [strings addObject:[NSString stringWithFormat:@"Wound %@ 0 photos", wound.shortName]];
        } else if (1 == count) {
            NSDate *date = minimumMaximumDates[@"minDate"];
            [strings addObject:[NSString stringWithFormat:@"%@ 1 photo (%@)", wound.shortName, [NSDateFormatter localizedStringFromDate:date
                                                                                                                              dateStyle:NSDateFormatterShortStyle
                                                                                                                              timeStyle:NSDateFormatterNoStyle]]];
        } else {
            NSDate *date1 = minimumMaximumDates[@"minDate"];//[woundPhotos valueForKeyPath:@"@min.dateCreated"];
            NSDate *date2 = minimumMaximumDates[@"maxDate"];//[woundPhotos valueForKeyPath:@"@max.dateCreated"];
            [strings addObject:[NSString stringWithFormat:@"%@ %ld photos (%@-%@)",
                                wound.shortName,
                                (long)count,
                                [NSDateFormatter localizedStringFromDate:date1
                                                               dateStyle:NSDateFormatterShortStyle
                                                               timeStyle:NSDateFormatterNoStyle],
                                [NSDateFormatter localizedStringFromDate:date2
                                                               dateStyle:NSDateFormatterShortStyle
                                                               timeStyle:NSDateFormatterNoStyle]]];
        }
    } else {
        [strings addObject:@"No wounds identified"];
    }
    self.patientStatusMessages = [strings componentsJoinedByString:@"|"];
    return self.patientStatusMessages;
}

+ (UIImage *)missingThumbnailImage
{
    NSString *avitarFileName = @"user_";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        avitarFileName = [avitarFileName stringByAppendingString:@"iPad"];
    } else {
        avitarFileName = [avitarFileName stringByAppendingString:@"iPhone"];
    }
    return [UIImage imageNamed:avitarFileName];
}

- (WMMedicalHistoryGroup *)lastActiveMedicalHistoryGroup
{
    return [WMMedicalHistoryGroup MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@", self]
                                                   sortedBy:WMMedicalHistoryGroupAttributes.updatedAt
                                                  ascending:NO
                                                  inContext:[self managedObjectContext]];
}

- (WMWound *)lastActiveWound
{
    return [self.sortedWounds firstObject];
}

- (NSArray *)sortedWounds
{
    return [[self.wounds allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]]];
}

- (NSInteger)woundCount
{
    return [WMWound MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"patient == %@", self] inContext:[self managedObjectContext]];
}

- (BOOL)hasMultipleWounds
{
    return [self.wounds count] > 1;
}

- (NSInteger)photosCount
{
    return [WMWoundPhoto MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"wound.patient == %@", self] inContext:[self managedObjectContext]];
}

- (NSInteger)photoBlobCount
{
    return [WMWoundPhoto MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"wound.patient == %@ AND %K != nil", self, WMWoundPhotoAttributes.thumbnailMini] inContext:[self managedObjectContext]];
}

- (BOOL)faceDetectionFailed
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:PatientFlagsFaceDetectionFailed];
}

- (void)setFaceDetectionFailed:(BOOL)faceDetectionFailed
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:PatientFlagsFaceDetectionFailed to:faceDetectionFailed]);
}

- (BOOL)facePhotoTaken
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:PatientFlagsFacePhotoTaken];
}

- (void)setFacePhotoTaken:(BOOL)facePhotoTaken
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:PatientFlagsFacePhotoTaken to:facePhotoTaken]);
}

- (BOOL)isDeleting
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:PatientFlagsIsDeleting];
}

- (void)setIsDeleting:(BOOL)isDeleting
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:PatientFlagsIsDeleting to:isDeleting]);
}

- (BOOL)dayOrMoreSinceCreated
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:1];
    return [[NSDate date] compare:[calendar dateByAddingComponents:components toDate:self.createdAt options:0]] == NSOrderedDescending;
}

- (BOOL)hasPatientDetails
{
    return ([self.person.addresses count] || [self.person.telecoms count] || [self.medicalHistoryGroups count] || self.surgicalHistory || self.relevantMedications);
}

- (WMPatientReferral *)patientReferral
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    return [WMPatientReferral MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"%K == %@", WMPatientReferralRelationships.patient, self]
                                               sortedBy:WMPatientReferralAttributes.createdAt
                                              ascending:NO
                                              inContext:managedObjectContext];
}

- (WMPatientReferral *)patientReferralForReferree:(WMParticipant *)referee
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    return [WMPatientReferral MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"%K == %@ AND %K == %@ AND %K = nil", WMPatientReferralRelationships.patient, self, WMPatientReferralRelationships.referree, referee, WMPatientReferralAttributes.dateAccepted]
                                               sortedBy:WMPatientReferralAttributes.createdAt
                                              ascending:NO
                                              inContext:managedObjectContext];
}

- (BOOL)updateNavigationToTeam:(WMTeam *)team patient2StageMap:(NSDictionary *)patient2StageMap
{
    NSParameterAssert(team);
    // when creating team, we may have deleted non-team track/stage/node
    WMNavigationStage *stage = self.stage;
    NSString *trackTitle = stage.track.title;
    NSString *stageTitle = stage.title;
    if (nil == stageTitle) {
        NSString *string = patient2StageMap[self.ffUrl];
        NSArray *trackStageArray = [string componentsSeparatedByString:@"|"];
        trackTitle = trackStageArray[0];
        stageTitle = trackStageArray[1];
    }
    NSParameterAssert(stageTitle);
    if (nil == stage.track.team) {
        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        NSError *localError = nil;
        WMNavigationTrack *track = [WMNavigationTrack MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"team == %@ AND title == %@", team, trackTitle] inContext:managedObjectContext];
        if (nil == track) {
            [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMNavigationTrack entityName]] error:&localError];
            if (localError) {
                [WMUtilities logError:localError];
            }
            track = [WMNavigationTrack MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"team == %@ AND title == %@", team, trackTitle] inContext:managedObjectContext];
        }
        NSParameterAssert(track);
        WMNavigationStage *stage = [WMNavigationStage MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"track == %@ AND title == %@", track, stageTitle] inContext:managedObjectContext];
        if (nil == stage) {
            [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMNavigationStage entityName]] error:&localError];
            if (localError) {
                [WMUtilities logError:localError];
            }
            stage = [WMNavigationStage MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"track == %@ AND title == %@", track, stageTitle] inContext:managedObjectContext];
        }
        NSParameterAssert(stage);
        self.stage = stage;
        self.team = team;
        return YES;
    }
    // else
    return NO;
}

#pragma mark - WMFFManagedObject

- (id<WMFFManagedObject>)aggregator
{
    return nil;
}
- (BOOL)requireUpdatesFromCloud
{
    return YES;
}

#pragma mark - FatFractal

+ (NSSet *)attributeNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[@"acquiredByConsultantValue",
                                                            @"archivedFlagValue",
                                                            @"flagsValue",
                                                            @"thumbnail",
                                                            @"managedObjectContext",
                                                            @"objectID",
                                                            @"thumbnailImage",
                                                            @"lastNameFirstName",
                                                            @"lastNameFirstNameOrAnonymous",
                                                            @"identifierEMR",
                                                            @"facePhotoTaken",
                                                            @"faceDetectionFailed",
                                                            @"genderIndex",
                                                            @"lastActiveWound",
                                                            @"hasMultipleWounds",
                                                            @"sortedWounds",
                                                            @"woundCount",
                                                            @"photosCount",
                                                            @"dayOrMoreSinceCreated",
                                                            @"lastActiveMedicalHistoryGroup",
                                                            @"hasPatientDetails",
                                                            @"photoBlobCount",
                                                            @"isDeleting",
                                                            @"patientReferral",
                                                            @"requireUpdatesFromCloud",
                                                            @"aggregator"]];
    });
    return PropertyNamesNotToSerialize;
}

+ (NSSet *)relationshipNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[]];
    });
    return PropertyNamesNotToSerialize;
}

- (BOOL)ff_shouldSerialize:(NSString *)propertyName
{
    if ([[WMPatient attributeNamesNotToSerialize] containsObject:propertyName] || [[WMPatient relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMPatient relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end
