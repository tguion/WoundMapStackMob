//
//  WMBaseViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/12/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "StackMob.h"

@class WCAppDelegate, CoreDataHelper;

@interface WMBaseViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic) SMFetchPolicy fetchPolicy;
@property (nonatomic) SMSavePolicy savePolicy;

@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (readonly, nonatomic) BOOL isIPadIdiom;

@property (readonly, nonatomic) CoreDataHelper *coreDataHelper;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) NSPersistentStore *store;

@property (strong, nonatomic) NSMutableArray *opaqueNotificationObservers;  // observers that do away when the view dissappears
@property (strong, nonatomic) NSMutableArray *persistantObservers;          // observers that do no go away when the view controller disappears

- (void)clearDataCache;                                                         // clear all cached data for new or nil document
- (void)clearAllReferences;                                                     // clear all references and all observers

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (readonly, nonatomic) NSString *fetchedResultsControllerEntityName;
@property (readonly, nonatomic) NSPredicate *fetchedResultsControllerPredicate;
@property (readonly, nonatomic) NSArray *fetchedResultsControllerAffectedStores;
@property (readonly, nonatomic) NSArray *fetchedResultsControllerSortDescriptors;
@property (readonly, nonatomic) NSString *fetchedResultsControllerSectionNameKeyPath;
@property (readonly, nonatomic) NSString *fetchedResultsControllerCacheName;
- (void)updateFetchRequest:(NSFetchRequest *)request;   // update specific properties of fetch request
- (void)fetchedResultsControllerDidFetch;               // called when frc finishes fetching Core Data
- (void)nilFetchedResultsController;                    // nil the reference _fetchedResultsController

// adjustments to conform NSFetchedResultsController to UITableViewDelegate/Datasource
- (NSIndexPath *)indexPathTableToFetchedResultsController:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathFetchedResultsControllerToTable:(NSIndexPath *)indexPath;
- (NSUInteger)sectionIndexFetchedResultsControllerToTable:(NSUInteger)sectionIndex;
- (NSUInteger)sectionIndexTableToFetchedResultsController:(NSUInteger)sectionIndex;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
