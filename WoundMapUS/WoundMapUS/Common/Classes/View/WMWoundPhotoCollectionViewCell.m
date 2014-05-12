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
#import "WMUtilities.h"
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
        __block NSInteger counter = 3;
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        __weak __typeof(&*self)weakSelf = self;
        dispatch_block_t block = ^{
            if (--counter == 0) {
                [managedObjectContext MR_saveToPersistentStoreAndWait];
                [activityIndicatorView removeFromSuperview];
                weakSelf.imageView.image = woundPhoto.thumbnail;
                [Faulter faultObjectWithID:woundPhotoObjectID inContext:managedObjectContext];
            }
        };
        if (nil == woundPhoto.thumbnail) {
            // put in temp image
            activityIndicatorView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
            [self addSubview:activityIndicatorView];
            [activityIndicatorView startAnimating];
            self.imageView.image = [UIImage imageNamed:@"user_iPad"];// TODO replace with placeholder image
            WMFatFractal *ff = [WMFatFractal sharedInstance];
            [[[ff newReadRequest] prepareGetFromUri:[NSString stringWithFormat:@"%@/%@", woundPhoto.ffUrl, WMWoundPhotoAttributes.thumbnail]] executeAsyncWithBlock:^(FFReadResponse *response) {
                NSData *photoData = [response rawResponseData];
                if (response.httpResponse.statusCode > 300) {
                    DLog(@"Attempt to download photo statusCode: %ld", (long)response.httpResponse.statusCode);
                } else {
                    woundPhoto.thumbnail = [[UIImage alloc] initWithData:photoData];
                    block();
                }
            }];
            [[[ff newReadRequest] prepareGetFromUri:[NSString stringWithFormat:@"%@/%@", woundPhoto.ffUrl, WMWoundPhotoAttributes.thumbnailLarge]] executeAsyncWithBlock:^(FFReadResponse *response) {
                NSData *photoData = [response rawResponseData];
                if (response.httpResponse.statusCode > 300) {
                    DLog(@"Attempt to download photo statusCode: %ld", (long)response.httpResponse.statusCode);
                } else {
                    woundPhoto.thumbnailLarge = [[UIImage alloc] initWithData:photoData];
                    block();
                }
            }];
            [[[ff newReadRequest] prepareGetFromUri:[NSString stringWithFormat:@"%@/%@", woundPhoto.ffUrl, WMWoundPhotoAttributes.thumbnailMini]] executeAsyncWithBlock:^(FFReadResponse *response) {
                NSData *photoData = [response rawResponseData];
                if (response.httpResponse.statusCode > 300) {
                    DLog(@"Attempt to download photo statusCode: %ld", (long)response.httpResponse.statusCode);
                } else {
                    woundPhoto.thumbnailMini = [[UIImage alloc] initWithData:photoData];
                    block();
                }
            }];
        } else {
            self.imageView.image = woundPhoto.thumbnail;
            [Faulter faultObjectWithID:woundPhotoObjectID inContext:managedObjectContext];
        }
    }
    [self setNeedsDisplay];
}

@end
