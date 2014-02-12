//
//  WCDetailViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/9/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WMPatient;
@class WCPatientPhotoImageView;

@interface WCDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) WMPatient *patient;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet WCPatientPhotoImageView *thumbnailImageView;

@end
