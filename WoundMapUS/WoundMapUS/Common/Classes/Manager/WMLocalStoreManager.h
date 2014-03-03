//
//  WMLocalStoreManager.h
//  WoundMapUS
//
//  Created by Todd Guion on 3/3/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WMBradenCare, IAPProduct;

@interface WMLocalStoreManager : NSObject

+ (WMLocalStoreManager *)sharedInstance;

- (void)seedLocalDatabase;

@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) NSPersistentStore *store;

- (WMBradenCare *)bradenCareForSectionTitle:(NSString *)sectionTitle
                                      score:(NSInteger)score;

- (IAPProduct *)iapProductForIdentifier:(NSString *)identifier;

@end
