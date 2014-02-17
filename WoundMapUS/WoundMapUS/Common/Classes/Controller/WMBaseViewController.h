//
//  WMBaseViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/12/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "StackMob.h"

@class WCAppDelegate, CoreDataHelper, WMUserDefaultsManager, WMPatientManager;
@class WMPatient;
@class WMProgressViewHUD;

@interface WMBaseViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic) SMFetchPolicy fetchPolicy;
@property (nonatomic) SMSavePolicy savePolicy;

@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (readonly, nonatomic) BOOL isIPadIdiom;

@property (readonly, nonatomic) UITableView *activeTableView;
@property (readonly, nonatomic) BOOL isSearchActive;

@property (readonly, nonatomic) WMUserDefaultsManager *userDefaultsManager;
@property (readonly, nonatomic) WMPatientManager *patientManager;

@property (readonly, nonatomic) CoreDataHelper *coreDataHelper;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) NSPersistentStore *store;

@property (strong, nonatomic) NSMutableArray *opaqueNotificationObservers;  // observers that do away when the view dissappears
@property (strong, nonatomic) NSMutableArray *persistantObservers;          // observers that do no go away when the view controller disappears

@property (readonly, nonatomic) WMPatient *patient;                         // active patient

- (void)clearViewReferences NS_REQUIRES_SUPER;                              // clear all references to views
- (void)clearDataCache NS_REQUIRES_SUPER;                                   // clear all cached data for new or nil document
- (void)clearAllReferences NS_REQUIRES_SUPER;                               // clear all references and all observers

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (readonly, nonatomic) NSString *fetchedResultsControllerEntityName;
@property (readonly, nonatomic) NSPredicate *fetchedResultsControllerPredicate;
@property (readonly, nonatomic) NSArray *fetchedResultsControllerAffectedStores;
@property (readonly, nonatomic) NSArray *fetchedResultsControllerSortDescriptors;
@property (readonly, nonatomic) NSString *fetchedResultsControllerSectionNameKeyPath;
@property (readonly, nonatomic) NSString *fetchedResultsControllerCacheName;
- (void)updateFetchRequest:(NSFetchRequest *)request;                       // update specific properties of fetch request
- (void)fetchedResultsControllerDidFetch;                                   // called when frc finishes fetching Core Data
- (void)nilFetchedResultsController;                                        // nil the reference _fetchedResultsController
- (void)refetchDataForTableView;                                            // nil the reference _fetchedResultsController and reload activeTableView

// adjustments to conform NSFetchedResultsController to UITableViewDelegate/Datasource
- (NSIndexPath *)indexPathTableToFetchedResultsController:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathFetchedResultsControllerToTable:(NSIndexPath *)indexPath;
- (NSUInteger)sectionIndexFetchedResultsControllerToTable:(NSUInteger)sectionIndex;
- (NSUInteger)sectionIndexTableToFetchedResultsController:(NSUInteger)sectionIndex;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

- (UITableViewCell *)cellForView:(UIView *)aView;

@property (strong, nonatomic) WMProgressViewHUD *progressView;
- (void)showProgressView;
- (void)showProgressViewWithMessage:(NSString *)message;
- (void)hideProgressView;

- (void)handleStackMobNetworkSynchFinished:(NSNotification *)notification NS_REQUIRES_SUPER;

@end
