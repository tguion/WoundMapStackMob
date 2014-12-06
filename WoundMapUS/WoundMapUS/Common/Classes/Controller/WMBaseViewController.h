//
//  WMBaseViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/12/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//  NS_DESIGNATED_INITIALIZER

#import "WMFatFractalManager.h"
#import <StoreKit/StoreKit.h>

extern BOOL const kPresentIAPController;    // DEPLOYMENT

typedef void (^IAPPresentViewControllerAcceptHandler)(SKPaymentTransaction *transaction);
typedef void (^IAPPresentViewControllerDeclineHandler)(void);


@class WCAppDelegate, CoreDataHelper, WMUserDefaultsManager;
@class WMPatient, WMWound, WMWoundPhoto, WMNavigationTrack, WMNavigationStage;
@class WMProgressViewHUD;

@interface WMBaseViewController : UITableViewController <NSFetchedResultsControllerDelegate>

/// Amount to inset content in this view controller. By default, this value will be calculated based on whether the view for this view controller intersects the status bar, navigation bar, and tab bar.
/// The contentInsets are also updated if the keyboard is displayed and its frame intersects with the frame of this controller's view.
@property (nonatomic) UIEdgeInsets contentInsets;

@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (readonly, nonatomic) BOOL isIPadIdiom;

@property (readonly, nonatomic) UITableView *activeTableView;
@property (readonly, nonatomic) BOOL isSearchActive;

@property (readonly, nonatomic) WMUserDefaultsManager *userDefaultsManager;

@property (readonly, nonatomic) CoreDataHelper *coreDataHelper;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) NSPersistentStore *store;

@property (readonly, nonatomic) NSArray *backendSeedEntityNames;            // implement for each view controller to make sure we have the seed data from back end

@property (strong, nonatomic) NSMutableArray *opaqueNotificationObservers;  // observers that do away when the view dissappears
@property (strong, nonatomic) NSMutableArray *persistantObservers;          // observers that do no go away when the view controller disappears
- (void)registerForNotifications;
- (void)unregisterForNotifications;

@property (readonly, nonatomic) WMPatient *patient;                         // active patient
@property (readonly, nonatomic) WMWound *wound;                             // active wound
@property (readonly, nonatomic) WMWoundPhoto *woundPhoto;                   // active woundPhoto

- (void)clearViewReferences NS_REQUIRES_SUPER;                              // clear all references to views
- (void)clearDataCache NS_REQUIRES_SUPER;                                   // clear all cached data for new or nil document
- (void)clearAllReferences NS_REQUIRES_SUPER;                               // clear all references and all observers

- (void)acquireBackendDataForEntityNames:(NSArray *)entityNames;
- (void)acquireBackendDataForEntityName:(NSString *)entityName;

@property (readonly, nonatomic) NSFetchRequest *fetchRequestForFetchedResultsController;
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
- (void)refetchDataForCoreTableView;                                        // nil the reference _fetchedResultsController and reload tableView
- (void)refetchDataForTableView;                                            // nil the reference _fetchedResultsController and reload activeTableView
- (void)refreshTable;                                                       // refetch using FatFractal
@property (readonly, nonatomic) NSArray *ffQuery;                           // query string that fetches same as predicate from FatFractal
@property (strong, nonatomic) WMObjectCallback refreshCompletionHandler;    // block to call after table auto refreshes

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

@property (strong, nonatomic) IBOutlet UIToolbar *inputAccessoryView;

- (void)patientNavigationDataChangedOnDevice;

- (void)handleParticipantLoggedOut;

- (void)handleApplicationWillResignActiveNotification NS_REQUIRES_SUPER;
- (void)handlePatientChanged:(WMPatient *)patient NS_REQUIRES_SUPER;
- (void)handleWoundChanged:(WMWound *)wound NS_REQUIRES_SUPER;
- (void)handleWoundPhotoChanged:(WMWoundPhoto *)woundPhoto NS_REQUIRES_SUPER;
- (void)handleNavigationTrackChanged:(WMNavigationTrack *)navigationTrack NS_REQUIRES_SUPER;
- (void)handleNavigationStageChanged:(WMNavigationStage *)navigationStage NS_REQUIRES_SUPER;
- (void)handleBackendDeletedObjectIds:(NSArray *)objectIDs;
- (void)handleTeamInvitationUpdated:(NSString *)teamInvitationGUID;
- (void)handleTeamMemberAdded:(NSString *)teamGUID;
- (void)handlePatientReferralUpdated:(NSString *)patientGUID;
- (void)handleContentUpdatedFromCloud:(NSDictionary *)map userInfo:(NSDictionary *)userInfo;

- (BOOL)presentIAPViewControllerForProductIdentifier:(NSString *)productIdentifier
                                        successBlock:(IAPPresentViewControllerAcceptHandler)successBlock
                                       proceedAlways:(BOOL)proceedAlways
                                          withObject:(id)object;
- (BOOL)presentIAPViewControllerForProductIdentifier:(NSString *)productIdentifier
                                        successBlock:(IAPPresentViewControllerAcceptHandler)successBlock
                                       proceedAlways:(BOOL)proceedAlways
                                          withObject:(id)object
                                            quantity:(NSInteger)quantity;
- (BOOL)presentIAPViewControllerForProductIdentifier:(NSString *)productIdentifier
                                        successBlock:(IAPPresentViewControllerAcceptHandler)successBlock
                                          withObject:(id)object;

@end
