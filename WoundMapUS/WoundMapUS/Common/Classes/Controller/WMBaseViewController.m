//
//  WMBaseViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/12/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBaseViewController.h"
#import "WMProgressViewHUD.h"
#import "StackMob.h"
#import "WMUserDefaultsManager.h"
#import "WMPatientManager.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"

@interface WMBaseViewController ()

@property (strong, nonatomic) NSManagedObjectID *patientObjectID;
@property (strong, nonatomic) NSManagedObjectID *woundObjectID;
@property (strong, nonatomic) NSManagedObjectID *woundPhotoObjectID;

@end

@implementation WMBaseViewController

#pragma mark - View

- (void)dealloc
{
    DLog(@"%@.dealloc", self);
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // listen for stuff
    [self registerForNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Fetch/Save Policy

- (void)setFetchPolicy:(SMFetchPolicy)fetchPolicy
{
    if (_fetchPolicy == fetchPolicy) {
        return;
    }
    // else
    _fetchPolicy = fetchPolicy;
    self.coreDataHelper.stackMobStore.fetchPolicy = fetchPolicy;
}

- (void)setSavePolicy:(SMSavePolicy)savePolicy
{
    if (_savePolicy == savePolicy) {
        return;
    }
    // else
    _savePolicy = savePolicy;
    self.coreDataHelper.stackMobStore.savePolicy = savePolicy;
}

#pragma mark - Core

- (BOOL)isIPadIdiom
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

// clear any strong references to views
- (void)clearViewReferences
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    self.tableView = nil;
    [self hideProgressView];
}

- (void)clearDataCache
{
    _patientObjectID = nil;
    _woundObjectID = nil;
    _woundPhotoObjectID = nil;
    _fetchedResultsController.delegate = nil;
    _fetchedResultsController = nil;
}

- (void)clearAllReferences
{
    [self clearViewReferences];
    [self clearDataCache];
    [self removeAllObservers];
}

- (void)removeAllObservers
{
    for (id observer in _persistantObservers) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }
    _persistantObservers = nil;
}

- (UITableViewCell *)cellForView:(UIView *)aView
{
	UIView *bView = aView.superview;
	while (nil != bView) {
		if ([bView isKindOfClass:[UITableViewCell class]]) {
			return (UITableViewCell *)bView;
		}
		// else
		bView = bView.superview;
	}
	// else
	return nil;
}

- (BOOL)isSearchActive
{
    return self.searchDisplayController.isActive;
}

- (UITableView *)activeTableView
{
    if (self.isSearchActive) {
        return self.searchDisplayController.searchResultsTableView;
    }
    // else
    return self.tableView;
}

#pragma mark - Progress view

- (WMProgressViewHUD *)progressView
{
    if (nil == _progressView) {
        _progressView = [[WMProgressViewHUD alloc] initWithFrame:CGRectZero];
    }
    return _progressView;
}

- (void)showProgressView
{
    if (nil != _progressView.superview) {
        return;
    }
    // else
    [self.view addSubview:self.progressView];
}

- (void)showProgressViewWithMessage:(NSString *)message
{
    if (nil == _progressView.superview) {
        [self.view addSubview:self.progressView];
    }
    _progressView.messageLabel.text = message;
}

- (void)hideProgressView
{
    if (nil == _progressView.superview) {
        // check for missed views
        for (UIView *view in self.view.subviews) {
            if ([view isKindOfClass:[WMProgressViewHUD class]]) {
                [view removeFromSuperview];
            }
        }
        _progressView = nil;
        return;
    }
    // else
    [_progressView removeFromSuperview];
    _progressView = nil;
}

#pragma mark - Notifications

- (void)registerForNotifications
{
    __weak __typeof(self) weakSelf = self;
    // check if we are already registered
    if (0 == [self.opaqueNotificationObservers count]) {
        // add observers
    }
    if (0 == [self.persistantObservers count]) {
        id observer = [[NSNotificationCenter defaultCenter] addObserverForName:kStackMobNetworkSynchFinishedNotification
                                                                        object:nil
                                                                         queue:[NSOperationQueue mainQueue]
                                                                    usingBlock:^(NSNotification *notification) {
                                                                        [weakSelf handleStackMobNetworkSynchFinished:notification];
                                                                    }];
        [self.persistantObservers addObject:observer];
    }
}

- (void)unregisterForNotifications
{
    // stop listening
    for (id observer in self.opaqueNotificationObservers) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }
    [self.opaqueNotificationObservers removeAllObjects];
}

#pragma mark - Notification handlers

// network synch with server has finished - subclasses may need to override 
- (void)handleStackMobNetworkSynchFinished:(NSNotification *)notification
{
    [self.tableView reloadData];
}

#pragma mark - Accessors

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (CoreDataHelper *)coreDataHelper
{
    return self.appDelegate.coreDataHelper;
}

- (NSManagedObjectContext *)managedObjectContext
{
    return [self.appDelegate.coreDataHelper.stackMobStore contextForCurrentThread];
}

- (NSPersistentStore *)store
{
//    NSArray *persistentStores = [self.appDelegate.coreDataHelper.stackMobStore.persistentStoreCoordinator persistentStores];
//    NSPersistentStore *store = [persistentStores firstObject];
//    NSAssert1([store isKindOfClass:[SMIncrementalStore class]], @"Unexpected class, expected SMIncrementalStore, found %@", store);
//    return store;
    return nil;
}

- (WMUserDefaultsManager *)userDefaultsManager
{
    return [WMUserDefaultsManager sharedInstance];
}

- (WMPatientManager *)patientManager
{
    return [WMPatientManager sharedInstance];
}

- (NSMutableArray *)opaqueNotificationObservers
{
    if (nil == _opaqueNotificationObservers) {
        _opaqueNotificationObservers = [[NSMutableArray alloc] initWithCapacity:16];
    }
    return _opaqueNotificationObservers;
}

- (NSMutableArray *)persistantObservers
{
    if (nil == _persistantObservers) {
        _persistantObservers = [[NSMutableArray alloc] initWithCapacity:4];
    }
    return _persistantObservers;
}

#pragma mark - Active data

- (WMPatient *)patient
{
    return self.appDelegate.patient;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - NSFetchedResultsController

- (NSString *)fetchedResultsControllerEntityName
{
	return nil;
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
	return nil;
}

- (NSArray *)fetchedResultsControllerAffectedStores
{
    return nil;
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
	return nil;
}

- (NSString *)fetchedResultsControllerSectionNameKeyPath
{
	return nil;
}

- (NSString *)fetchedResultsControllerCacheName
{
	return nil;
}

- (void)updateFetchRequest:(NSFetchRequest *)request
{
    
}

- (NSFetchedResultsController *)fetchedResultsController
{
	if (nil != _fetchedResultsController) {
		return _fetchedResultsController;
	}
	// else
	if (0 == [self.fetchedResultsControllerEntityName length]) {
		return nil;
	}
	// else
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:self.fetchedResultsControllerEntityName inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entityDescription];
	// set predicate
	fetchRequest.predicate = self.fetchedResultsControllerPredicate;
    // restrict to stores
    [fetchRequest setAffectedStores:self.fetchedResultsControllerAffectedStores];
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:40];
    // Edit the sort key as appropriate.
    [fetchRequest setSortDescriptors:self.fetchedResultsControllerSortDescriptors];
    // update for possible NSDictionaryResultType
    [self updateFetchRequest:fetchRequest];
    // Edit the section name key path and cache name if appropriate - nil for section name key path means "no sections".
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
																	 managedObjectContext:self.managedObjectContext
																	   sectionNameKeyPath:self.fetchedResultsControllerSectionNameKeyPath
																				cacheName:self.fetchedResultsControllerCacheName];
    if (fetchRequest.requestType == NSManagedObjectResultType) {
        _fetchedResultsController.delegate = self;
    }
	NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        [WMUtilities logError:error];
    }
	[self performSelector:@selector(fetchedResultsControllerDidFetch) withObject:nil afterDelay:0.0];
	return _fetchedResultsController;
}

- (void)fetchedResultsControllerDidFetch
{
}

- (void)nilFetchedResultsController
{
    _fetchedResultsController = nil;
}

- (void)refetchDataForTableView
{
    _fetchedResultsController = nil;
    [self.activeTableView reloadData];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */

#pragma mark - IndexPath Adjustments

- (NSIndexPath *)indexPathTableToFetchedResultsController:(NSIndexPath *)indexPath
{
	return indexPath;
}

- (NSIndexPath *)indexPathFetchedResultsControllerToTable:(NSIndexPath *)indexPath
{
	return  indexPath;
}

- (NSUInteger)sectionIndexFetchedResultsControllerToTable:(NSUInteger)sectionIndex
{
	return sectionIndex;
}

- (NSUInteger)sectionIndexTableToFetchedResultsController:(NSUInteger)sectionIndex
{
	return sectionIndex;
}

@end
