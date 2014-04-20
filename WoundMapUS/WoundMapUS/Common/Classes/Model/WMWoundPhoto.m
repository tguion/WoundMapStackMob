#import "WMWoundPhoto.h"
#import "WMWound.h"
#import "WMPhoto.h"
#import "WMWoundMeasurementGroup.h"
#import "WMWoundMeasurementValue.h"
#import "WMUtilities.h"

#define kTiledImageRowCount 8
#define kTiledImageColumnCount 8

typedef enum {
    WoundPhotoFlagsTilesCreatedOriginal             = 0,
    WoundPhotoFlagsTilesCreatedTrueSee              = 1,
    WoundPhotoFlagsDeviceLandscape                  = 2,
    WoundPhotoFlagsTilingHasStarted                 = 3,
} WoundPhotoFlags;

@interface WMWoundPhoto ()

// Private interface goes here.

@end


@implementation WMWoundPhoto

- (BOOL)landscapeOrientation
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:WoundPhotoFlagsDeviceLandscape];
}

- (void)setLandscapeOrientation:(BOOL)landscapeOrientation
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:WoundPhotoFlagsDeviceLandscape to:landscapeOrientation]);
}

- (BOOL)tilesCreatedForOriginalImage
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:WoundPhotoFlagsTilesCreatedOriginal];
}

- (void)setTilesCreatedForOriginalImage:(BOOL)tilesCreatedForOriginalImage
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:WoundPhotoFlagsTilesCreatedOriginal to:tilesCreatedForOriginalImage]);
}

- (BOOL)tilingHasStarted
{
    return [WMUtilities isBitSetForValue:[self.flags intValue] atPosition:WoundPhotoFlagsTilingHasStarted];
}

- (void)setTilingHasStarted:(BOOL)tilingHasStarted
{
    self.flags = @([WMUtilities updateBitForValue:[self.flags intValue] atPosition:WoundPhotoFlagsTilingHasStarted to:tilingHasStarted]);
}

- (BOOL)waitingForTilingToFinish
{
    return self.tilingHasStarted && !self.tilesCreatedForOriginalImage;
}

- (WMWoundMeasurementGroup *)measurementGroup
{
    return [WMWoundMeasurementGroup woundMeasurementGroupForWoundPhoto:self];
}

+ (WMWoundPhoto *)createWoundPhotoForWound:(WMWound *)wound
{
    NSManagedObjectContext *managedObjectContext = [wound managedObjectContext];
    WMWoundPhoto *woundPhoto = [WMWoundPhoto MR_createInContext:managedObjectContext];
    woundPhoto.wound = wound;
    return woundPhoto;
}

+ (NSArray *)sortedWoundPhotosForWound:(WMWound *)wound
{
    return [WMWoundPhoto MR_findAllSortedBy:WMWoundPhotoAttributes.createdAt ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"wound == %@", wound] inContext:[wound managedObjectContext]];
}

+ (void)updateFetchRequestForDictionaryType:(NSFetchRequest *)request thumbnailType:(WoundPhotoThumbnailType)woundPhotoThumbnailType
{
    NSExpressionDescription* objectIdDesc = [[NSExpressionDescription alloc] init];
    objectIdDesc.name = @"objectID";
    objectIdDesc.expression = [NSExpression expressionForEvaluatedObject];
    objectIdDesc.expressionResultType = NSObjectIDAttributeType;
    
    [request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    NSString *thumbnailAttributeName = nil;
    switch (woundPhotoThumbnailType) {
        case WoundPhotoThumbnailTypeMini:
            thumbnailAttributeName = @"thumbnailMini";
            break;
        case WoundPhotoThumbnailTypeThumbnail:
            thumbnailAttributeName = @"thumbnail";
            break;
        case WoundPhotoThumbnailTypeThumbnailLarge:
            thumbnailAttributeName = @"thumbnailLarge";
            break;
    }
    [request setPropertiesToFetch:@[objectIdDesc, @"createdAt", @"imageWidth", @"imageHeight", thumbnailAttributeName]];
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.createdAt = [NSDate date];
    self.updatedAt = [NSDate date];
}

- (WMPhoto *)fetchOrCreatePhotoForType:(PhotoType)photoType
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    WMPhoto *photo = nil;
    switch (photoType) {
        case PhotoTypeOriginal: {
            photo = self.photo;
            if (nil == photo) {
                photo = [WMPhoto MR_createInContext:managedObjectContext];
                photo.originalFlag = [NSNumber numberWithBool:YES];
                [self addPhotosObject:photo];
            }
            break;
        }
    }
    return photo;
}

- (UIImage *)tileImageForScale:(NSInteger)scale row:(NSInteger)row column:(NSInteger)column
{
    // look at relationship first
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"scale == %d AND row == %d AND column == %d AND tileFlag == YES", scale, row, column];
    NSArray *array = [[self.photos allObjects] filteredArrayUsingPredicate:predicate];
    if ([array count] > 0) {
        WMPhoto *photo = [array lastObject];
        return photo.photo;
    }
    // else search database
    predicate = [NSPredicate predicateWithFormat:@"woundPhoto == %@ AND scale == %d AND row == %d AND column == %d AND tileFlag == YES", self, scale, row, column];
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"WCPhoto" inManagedObjectContext:managedObjectContext]];
    [request setPredicate:predicate];
    NSError *error = nil;
    array = [managedObjectContext executeFetchRequest:request error:&error];
    if (nil != error) {
        [WMUtilities logError:error];
        abort();
    }
    // else
    WMPhoto *photo = [array lastObject];
    return photo.photo;
}

- (WMPhoto *)photo
{
    return [WMPhoto MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"woundPhoto == %@ AND originalFlag == YES", self] inContext:[self managedObjectContext]];
}

- (NSString *)photoLabelText
{
    NSString *text = nil;
    NSString *length = self.measurementGroup.measurementValueLength.value;
    NSString *width = self.measurementGroup.measurementValueWidth.value;
    NSString *depth = self.measurementGroup.measurementValueDepth.value;
    if (nil == length) {
        text = @"Not measured";
    } else {
        CGFloat area = [width floatValue] * [length floatValue];
        text = [NSString stringWithFormat:@"%@ x %@ (%0.2f cm\u00B2)", width, length, area];
        if (nil != depth) {
            text = [text stringByAppendingFormat:@" Depth:%@ cm", depth];
        }
    }
    return text;
}

- (CGPoint)translation
{
    return CGPointMake([self.transformTranslationX floatValue], [self.transformTranslationY floatValue]);
}

- (void)setTranslation:(CGPoint)translation
{
    self.transformTranslationX = [NSNumber numberWithFloat:translation.x];
    self.transformTranslationY = [NSNumber numberWithFloat:translation.y];
}

- (void)updateTranslation:(CGPoint)translation
{
    self.transformTranslationX = [NSNumber numberWithFloat:self.translation.x + translation.x];
    self.transformTranslationY = [NSNumber numberWithFloat:self.translation.y + translation.y];
}

- (void)updateRotation:(CGFloat)rotation
{
    self.transformRotation = [NSNumber numberWithFloat:[self.transformRotation floatValue] + rotation];
}

- (void)updateScale:(CGFloat)factor
{
    self.transformScale = [NSNumber numberWithFloat:[self.transformScale floatValue] * factor];
}

- (CGAffineTransform)transform
{
    if (0 == [self.transformAsString length]) {
        return CGAffineTransformIdentity;
    }
    // else
    return CGAffineTransformFromString(self.transformAsString);
}

- (void)setTransform:(CGAffineTransform)transform
{
    if (CGAffineTransformIsIdentity(transform)) {
        self.transformAsString = nil;
    } else {
        self.transformAsString = NSStringFromCGAffineTransform(transform);
    }
}

- (CGAffineTransform)transformForSize:(CGSize)aSize
{
    if (self.isTransformIdentity) {
        return CGAffineTransformIdentity;
    }
    // else adjust the translate part of the transform
    if (CGSizeEqualToSize(aSize, self.transformBoundsSize)) {
        // nothing to adjust
        return self.transform;
    }
    // else must adjust the translation to account for different size of bounds
    CGSize transformBoundsSize = self.transformBoundsSize;
    CGFloat w0 = transformBoundsSize.width;
    CGFloat h0 = transformBoundsSize.height;
    CGFloat w1 = aSize.width;
    CGFloat h1 = aSize.height;
    CGFloat scale = w1/w0;
    CGAffineTransform transform = self.transform;
    CGFloat tx = transform.tx;
    CGFloat ty = transform.ty;
    BOOL scaleUp = (w1 > w0);   // assume same orientation
    if (scaleUp) {
        tx = roundf(tx * w1/w0);
        ty = roundf(ty * h1/h0);
    } else {
        tx = roundf(tx * (scale - 1.0));
        ty = roundf(ty * (scale - 1.0));
    }
    return CGAffineTransformTranslate(transform, tx, ty);
}

- (CGSize)transformBoundsSize
{
    if ([self.transformSizeAsString length] > 0) {
        return CGSizeFromString(self.transformSizeAsString);
    }
    // else
    return CGSizeZero;
}

- (void)setTransformBoundsSize:(CGSize)transformBoundsSize
{
    self.transformSizeAsString = NSStringFromCGSize(transformBoundsSize);
}

- (BOOL)hasTransform
{
    return [self.transformScale floatValue] != 1.0 || [self.transformRotation floatValue] != 0.0 || [self.transformTranslationX floatValue] != 0.0 || [self.transformTranslationY floatValue] != 0.0;
}

- (BOOL)isTransformIdentity
{
    if ([self.transformAsString length] == 0) {
        return YES;
    }
    // else
    return CGAffineTransformIsIdentity(self.transform);
}

- (void)resetTransform
{
    self.transformAsString = nil;
    self.transformScale = [NSNumber numberWithFloat:1.0];
    self.transformTranslationX = [NSNumber numberWithFloat:0.0];
    self.transformTranslationY = [NSNumber numberWithFloat:0.0];
    self.transformRotation = [NSNumber numberWithFloat:0.0];
}

#pragma mark - FatFractal

+ (NSSet *)attributeNamesNotToSerialize
{
    static NSSet *PropertyNamesNotToSerialize = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PropertyNamesNotToSerialize = [NSSet setWithArray:@[WMWoundPhotoAttributes.thumbnail,
                                                            WMWoundPhotoAttributes.thumbnailLarge,
                                                            WMWoundPhotoAttributes.thumbnailMini,
                                                            @"flagsValue",
                                                            @"imageHeightValue",
                                                            @"imageOrientationValue",
                                                            @"imageWidthValue",
                                                            @"transformRotationValue",
                                                            @"transformScaleValue",
                                                            @"transformTranslationXValue",
                                                            @"transformTranslationYValue",
                                                            @"landscapeOrientation",
                                                            @"tilingHasStarted",
                                                            @"waitingForTilingToFinish",
                                                            @"measurementGroup",
                                                            @"photo",
                                                            @"photoLabelText",
                                                            @"translation",
                                                            @"transform",
                                                            @"hasTransform",
                                                            @"isTransformIdentity",
                                                            @"transformBoundsSize",
                                                            @"tilesCreatedForOriginalImage"]];
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
    if ([[WMWoundPhoto attributeNamesNotToSerialize] containsObject:propertyName] || [[WMWoundPhoto relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

- (BOOL)ff_shouldSerializeAsSetOfReferences:(NSString *)propertyName {
    if ([[WMWoundPhoto relationshipNamesNotToSerialize] containsObject:propertyName]) {
        return NO;
    }
    // else
    return YES;
}

@end
