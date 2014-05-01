//
//  WMWoundPhotoCollectionViewCell.m
//  WoundCarePhoto
//
//  Created by Todd Guion on 6/25/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import "WMWoundPhotoCollectionViewCell.h"
#import "WMWoundPhoto.h"
#import "WMPhoto.h"
#import "WMPhotoManager.h"
#import "WMDesignUtilities.h"
#import "WMFatFractal.h"
#import "Faulter.h"
#import "WCAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

#define LABEL_WIDTH 160.0

@interface WMWoundPhotoCollectionViewCell()

@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation WMWoundPhotoCollectionViewCell

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        // initialize imageView
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        UIImageView *anImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, height)];
        anImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        anImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:anImageView];
        _imageView = anImageView;
        // initialize label
        CGRect aFrame = CGRectMake((width - LABEL_WIDTH)/2.0, height-17.0, LABEL_WIDTH, 17.0);
        UILabel *aLabel = [[UILabel alloc] initWithFrame:aFrame];
        aLabel.backgroundColor = [UIColor clearColor];
        aLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        aLabel.layer.cornerRadius = 6.0;
        aLabel.layer.backgroundColor = [WMDesignUtilities semiTransparentDateLabelBackgroundColor].CGColor;
        aLabel.textAlignment = NSTextAlignmentCenter;
        aLabel.font = [UIFont systemFontOfSize:11.0];
        [self.contentView addSubview:aLabel];
        _dateLabel = aLabel;
        // initialize selected background view
        UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:frame];
        selectedBackgroundView.layer.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.25f alpha:0.50].CGColor;
        self.selectedBackgroundView = selectedBackgroundView;
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (nil == newSuperview) {
        _woundPhotoObjectID = nil;
    }
}

- (void)setWoundPhotoObjectID:(NSManagedObjectID *)woundPhotoObjectID
{
    if (_woundPhotoObjectID == woundPhotoObjectID) {
        return;
    }
    // else
    [self willChangeValueForKey:@"woundPhotoObjectID"];
    _woundPhotoObjectID = woundPhotoObjectID;
    [self didChangeValueForKey:@"woundPhotoObjectID"];
    if (nil == woundPhotoObjectID) {
        self.imageView.hidden = YES;
        self.dateLabel.hidden = YES;
    } else {
        self.imageView.hidden = NO;
        self.dateLabel.hidden = NO;
        NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_defaultContext];
        WMWoundPhoto *woundPhoto = (WMWoundPhoto *)[managedObjectContext objectWithID:woundPhotoObjectID];
        self.dateLabel.text = [NSDateFormatter localizedStringFromDate:woundPhoto.createdAt
                                                             dateStyle:NSDateFormatterMediumStyle
                                                             timeStyle:NSDateFormatterMediumStyle];
        __weak __typeof(&*self)weakSelf = self;
        dispatch_block_t block = ^{
            weakSelf.imageView.image = woundPhoto.thumbnail;
            [Faulter faultObjectWithID:woundPhotoObjectID inContext:managedObjectContext];
        };
        UIImage *image = woundPhoto.thumbnail;
        if (nil == image) {
            UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            activityIndicatorView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
            [self addSubview:activityIndicatorView];
            [activityIndicatorView startAnimating];
            WMFatFractal *ff = [WMFatFractal sharedInstance];
            [ff loadBlobsForObj:woundPhoto onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                [activityIndicatorView removeFromSuperview];
                id data = woundPhoto.thumbnail;
                if ([data isKindOfClass:[NSData class]]) {
                    woundPhoto.thumbnail = [UIImage imageWithData:data];
                }
                data = woundPhoto.thumbnailLarge;
                if ([data isKindOfClass:[NSData class]]) {
                    woundPhoto.thumbnailLarge = [UIImage imageWithData:data];
                }
                data = woundPhoto.thumbnailMini;
                if ([data isKindOfClass:[NSData class]]) {
                    woundPhoto.thumbnailMini = [UIImage imageWithData:data];
                }
                [managedObjectContext MR_saveToPersistentStoreAndWait];
                block();
            }];
        } else {
            block();
        }
    }
    [self setNeedsDisplay];
}

@end
