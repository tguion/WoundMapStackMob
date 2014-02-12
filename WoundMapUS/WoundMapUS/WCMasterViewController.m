//
//  WCMasterViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/9/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WCMasterViewController.h"
#import "WCDetailViewController.h"
#import "WMUsersViewController.h"
#import "WMPatient.h"
#import "WMPerson.h"
#import "CoreDataHelper.h"
#import "WCAppDelegate.h"

@interface WCMasterViewController () <UserSignInDelegate>
@property (readonly, nonatomic) WCAppDelegate *appDelegate;
@property (readonly, nonatomic) WMUsersViewController *usersViewController;

- (void)refreshTable;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation WCMasterViewController

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (NSManagedObjectContext *)managedObjectContext
{
    return [self.appDelegate.coreDataHelper.stackMobStore contextForCurrentThread];
}

- (NSPersistentStore *)store
{
    NSArray *persistentStores = [self.appDelegate.coreDataHelper.stackMobStore.persistentStoreCoordinator persistentStores];
    // must be SMIncrementalStore
    return [persistentStores firstObject];
}

- (WMUsersViewController *)usersViewController
{
    WMUsersViewController *usersViewController = [[WMUsersViewController alloc] initWithNibName:@"WMUsersViewController" bundle:nil];
    usersViewController.delegate = self;
    return usersViewController;
}

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // set the policies
    self.fetchPolicy = SMFetchPolicyTryNetworkElseCache;
    self.savePolicy = SMSavePolicyNetworkThenCache;
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPatient:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (WCDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    // initialize our refresh control and assign the refreshTable method to get called when the refresh is initiated. Then we initiate the refresh process.
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    self.refreshControl  = refreshControl;
    [refreshControl beginRefreshing];
    // synchronize with StackMob
    [self.appDelegate.coreDataHelper.stackMobStore syncWithServer];
    [self refreshTable];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // execute fetch on cloud
    self.appDelegate.coreDataHelper.stackMobStore.fetchPolicy = SMFetchPolicyTryNetworkElseCache;
    [self refreshTable];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // check if logged in
    if (nil == self.appDelegate.user) {
        WMUsersViewController *usersViewController = self.usersViewController;
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:usersViewController]
                           animated:YES
                         completion:^{
                             // nothing
                         }];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // change back to default fetch policy
    // execute fetch on cloud
    self.appDelegate.coreDataHelper.stackMobStore.fetchPolicy = SMFetchPolicyCacheOnly;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core

/*
 Responsible for fetching all todo objects from StackMob and reloading the table view.
 */
- (void)refreshTable
{
    NSManagedObjectContext *context = self.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"WMPatient"];
    [fetchRequest setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"lastmoddate" ascending:NO]]];
    [context executeFetchRequest:fetchRequest onSuccess:^(NSArray *results) {
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    } onFailure:^(NSError *error) {
        [self.refreshControl endRefreshing];
        NSLog(@"An error %@, %@", error, [error userInfo]);
    }];
}

#pragma mark - Actions

// navigate to edit patient view controller with createPatientFlag YES
- (IBAction)addPatient:(id)sender
{
    NSManagedObjectContext *stackMobContext = self.managedObjectContext;
    WMPatient *patient = [WMPatient instanceWithManagedObjectContext:stackMobContext persistentStore:self.store];
    patient.person.nameFamily = [NSString stringWithFormat:@"Patient%d", [self.fetchedResultsController.fetchedObjects count]];
    // Save the context
    NSLog(@"Saving patient");
    [stackMobContext saveOnSuccess:^{
        NSLog(@"SAVED changes to StackMob store (in the background)");
    } onFailure:^(NSError *error) {
        NSLog(@"FAILED to save changes to StackMob store (in the background): %@", error);
    }];
}

#pragma mark - UserSignInDelegate

- (void)userSignInViewController:(WMUserSignInViewController *)viewController didSignInUser:(User *)user
{
    self.appDelegate.user = user;
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

- (void)userSignInViewControllerDidCancel:(WMUserSignInViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // delay until we are signed in as team member
    if (nil == self.appDelegate.user) {
        return 0;
    }
    // else
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WMPatient *patient = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    if (NO) {
        // add an image to check how Amazon S3 works CuriousFrog.jpg
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSString *pathToImageFile = [bundle pathForResource:@"CuriousFrog" ofType:@"jpg"];
        NSData *theData = [NSData dataWithContentsOfFile:pathToImageFile];
        NSString *picData = [SMBinaryDataConversion stringForBinaryData:theData name:@"WoundMapPatientPhoto" contentType:@"image/jpg"];
        patient.thumbnail = picData;
        NSManagedObjectContext *stackMobContext = self.managedObjectContext;
        [stackMobContext saveOnSuccess:^{
            [stackMobContext refreshObject:patient mergeChanges:YES];
        } onFailure:^(NSError *error) {
            // Error
            NSLog(@"error here: %@", error);
        }];
    } else {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.detailViewController.patient = patient;
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        WMPatient *patient = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setPatient:patient];
    }
}

#pragma mark - NSFetchedResultsController

- (NSString *)fetchedResultsControllerEntityName
{
	return @"WMPatient";
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
    return @[[[NSSortDescriptor alloc] initWithKey:@"lastmoddate" ascending:NO]];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    WMPatient *patient = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = patient.person.nameFamily;
}

@end
