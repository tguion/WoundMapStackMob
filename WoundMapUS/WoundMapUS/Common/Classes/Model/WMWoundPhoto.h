#import "_WMWoundPhoto.h"
#import "WMFFManagedObject.h"

@class WMWound, WMPhoto, WMWoundMeasurementGroup;

typedef enum {
    PhotoTypeOriginal,
} PhotoType;

typedef enum {
    WoundPhotoThumbnailTypeMini,
    WoundPhotoThumbnailTypeThumbnail,
    WoundPhotoThumbnailTypeThumbnailLarge,
} WoundPhotoThumbnailType;

@interface WMWoundPhoto : _WMWoundPhoto <WMFFManagedObject> {}

+ (WMWoundPhoto *)createWoundPhotoForWound:(WMWound *)wound;

+ (NSArray *)sortedWoundPhotosForWound:(WMWound *)wound;

+ (void)updateFetchRequestForDictionaryType:(NSFetchRequest *)request thumbnailType:(WoundPhotoThumbnailType)woundPhotoThumbnailType;

@property (nonatomic) BOOL landscapeOrientation;                // YES if device was in landscape when photo taken
@property (nonatomic) BOOL tilingHasStarted;                    // YES if tiling has started
@property (readonly, nonatomic) BOOL waitingForTilingToFinish;  // YES is tiling is enabled and not finished

@property (readonly, nonatomic) WMWoundMeasurementGroup *measurementGroup;  // latest active
@property (readonly, nonatomic) WMPhoto *photo;
@property (readonly, nonatomic) NSString *photoLabelText;
@property (nonatomic) CGPoint translation;
@property (nonatomic) CGAffineTransform transform;
@property (readonly, nonatomic) BOOL hasTransform;
@property (readonly, nonatomic) BOOL isTransformIdentity;
@property (nonatomic) CGSize transformBoundsSize;
@property (nonatomic) BOOL tilesCreatedForOriginalImage;
@property (nonatomic) BOOL photoDeletedPerTeamPolicy;

- (WMPhoto *)fetchOrCreatePhotoForType:(PhotoType)photoType;
- (UIImage *)tileImageForScale:(NSInteger)scale row:(NSInteger)row column:(NSInteger)column;

- (CGAffineTransform)transformForSize:(CGSize)aSize;
- (void)updateTranslation:(CGPoint)translation;
- (void)updateRotation:(CGFloat)rotation;
- (void)updateScale:(CGFloat)factor;
- (void)resetTransform;

@end
