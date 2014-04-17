#import "_WMBradenScale.h"
#import "WoundCareProtocols.h"

extern NSString * const kBradenScaleTitle;

@class WMPatient;

@interface WMBradenScale : _WMBradenScale {}

+ (WMBradenScale *)createNewBradenScaleForPatient:(WMPatient *)patient handler:(WMProcessCallback)handler;

+ (WMBradenScale *)latestBradenScale:(WMPatient *)patient create:(BOOL)create;
+ (WMBradenScale *)latestCompleteBradenScale:(WMPatient *)patient;
+ (NSDate *)lastCompleteBradenScaleDataModified:(WMPatient *)patient;
+ (NSArray *)sortedScoredBradenScales:(WMPatient *)patient;
+ (NSInteger)closeBradenScalesCreatedBefore:(NSDate *)date
                                    patient:(WMPatient *)patient;
+ (void)deleteIncompleteClosedBradenScales:(WMPatient *)patient;

@property (readonly, nonatomic) BOOL isClosed;
@property (readonly, nonatomic) BOOL isScored;
@property (readonly, nonatomic) BOOL isScoredCalculated;
@property (readonly, nonatomic) NSString *scoreMessage;

- (NSArray *)sortedSections;
- (void)updateScoreFromSections;

@end
