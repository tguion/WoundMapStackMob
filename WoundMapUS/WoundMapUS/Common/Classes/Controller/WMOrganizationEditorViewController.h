//
//  WMOrganizationEditorViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 3/30/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMOrganizationEditorViewController, WMOrganization;

@protocol OrganizationEditorViewControllerDelegate <NSObject>

@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)organizationEditorViewController:(WMOrganizationEditorViewController *)viewController didEditOrganization:(WMOrganization *)organization;
- (void)organizationEditorViewControllerDidCancel:(WMOrganizationEditorViewController *)viewController;

@end

@interface WMOrganizationEditorViewController : WMBaseViewController

@property (weak, nonatomic) id<OrganizationEditorViewControllerDelegate> delegate;
@property (strong, nonatomic) WMOrganization *organization;

@end
