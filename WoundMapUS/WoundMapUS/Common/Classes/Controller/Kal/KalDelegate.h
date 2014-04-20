//
//  KalDelegate.h
//  WoundCare
//
//  Created by Todd Guion on 8/12/11.
//  Copyright 2011 etreasure consulting LLC. All rights reserved.
//

#import "TableViewDelegateDataSource.h"
#import "Kal.h"

@class KalDelegate;
@class WMWound, WMWoundPhoto;

@protocol KalDelegateDelegate <NSObject>

@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) WMWound *wound;

- (WMWoundPhoto *)selectedWoundPhoto:(KalDelegate *)kalDelegate;
- (void)kalDelegate:(KalDelegate *)kalDelegate didLoadWoundPhotosForTable:(NSArray *)woundPhotos;
- (void)kalDelegate:(KalDelegate *)kalDelegate didSelectWoundPhoto:(WMWoundPhoto *)woundPhoto;
- (void)kalDelegate:(KalDelegate *)kalDelegate didSelectWoundPhotoObjectID:(NSManagedObjectID *)woundPhotoObjectID;
- (void)kalDelegateDidCancel:(KalDelegate *)kalDelegate;
@end

@interface KalDelegate : TableViewDelegateDataSource <KalDataSource>

@property (weak, nonatomic) id<KalDelegateDelegate>delegate;

- (id)initWithDelegate:(id<KalDelegateDelegate>)delegate;

@end
