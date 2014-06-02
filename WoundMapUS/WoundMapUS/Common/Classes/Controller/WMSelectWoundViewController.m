//
//  WMSelectWoundViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMSelectWoundViewController.h"
#import "WMWoundDetailViewController.h"
#import "MBProgressHUD.h"
#import "WMPatient.h"
#import "WMWound.h"
#import "WMWoundType.h"
#import "WMWoundPhoto.h"
#import "WMUtilities.h"
#import "WMNavigationCoordinator.h"
#import "WMDesignUtilities.h"
#import "WMFatFractal.h"
#import "WMFatFractalManager.h"
#import "WCAppDelegate.h"

@interface WMSelectWoundViewController () <WoundDetailViewControllerDelegate>

@property (readonly, nonatomic) WMWoundDetailViewController *woundDetailViewController;
@property (nonatomic) BOOL didCancel;

- (IBAction)saveAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end

@interface WMSelectWoundViewController (PrivateMethods)

- (void)navigateToWoundDetailForWound:(WMWound *)wound;
- (BOOL)indexPathIsAddWound:(NSIndexPath *)indexPath;
- (void)updateUIForDataChange;

@end

@implementation WMSelectWoundViewController (PrivateMethods)

- (void)navigateToWoundDetailForWound:(WMWound *)wound
{
    WMWoundDetailViewController *woundDetailViewController = self.woundDetailViewController;
    if (nil == wound) {
        woundDetailViewController.newWoundFlag = YES;
    } else {
        woundDetailViewController.wound = wound;
    }
    [self.navigationController pushViewController:woundDetailViewController animated:YES];
}

- (BOOL)indexPathIsAddWound:(NSIndexPath *)indexPath
{
    return (indexPath.row == [self.fetchedResultsController.fetchedObjects count]);
}

- (void)updateUIForDataChange
{
    if (self.managedObjectContext.hasChanges) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                              target:self
                                                                                              action:@selector(cancelAction:)];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:
                                                   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                                 target:self
                                                                                                 action:@selector(saveAction:)],
                                                   nil];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:
                                                   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                                 target:self
                                                                                                 action:@selector(saveAction:)],
                                                   nil];
    }
}

@end

@implementation WMSelectWoundViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.modalInPopover = YES;
        self.preferredContentSize = CGSizeMake(320.0, 320.0);
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Add code to clean up any of your own resources that are no longer necessary.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Select Wound";
    // allow editing
    [self.tableView setEditing:YES animated:NO];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:
                                               [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                             target:self
                                                                                             action:@selector(saveAction:)],
                                               nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self updateUIForDataChange];
    [super viewWillAppear:animated];
    [self refetchDataForTableView];
    self.navigationItem.rightBarButtonItem.enabled = (nil != self.wound);
    // check for wound deletions
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak __typeof(&*self)weakSelf = self;
    [ffm updateGrabBags:@[WMPatientRelationships.wounds] aggregator:self.patient ff:ff completionHandler:^(NSError *error) {
        if (error) {
            [WMUtilities logError:error];
        }
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
    }];
}

#pragma mark - BaseViewController

#pragma mark - Core

- (WMWoundDetailViewController *)woundDetailViewController
{
    WMWoundDetailViewController *woundDetailViewController = [[WMWoundDetailViewController alloc] initWithNibName:@"WMWoundDetailViewController" bundle:nil];
    woundDetailViewController.delegate = self;
    return woundDetailViewController;
}

#pragma mark - Actions

- (IBAction)saveAction:(id)sender
{
    [self.delegate selectWoundController:self didSelectWound:self.wound];
}

- (IBAction)cancelAction:(id)sender
{
    _didCancel = YES;
    [self.delegate selectWoundControllerDidCancel:self];
}

#pragma mark - WoundDetailViewControllerDelegate

- (void)woundDetailViewController:(WMWoundDetailViewController *)viewController didUpdateWound:(WMWound *)wound
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.tableView reloadData];
    // commit to back end
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak __typeof(&*self)weakSelf = self;
    [ff updateObj:wound onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
    }];
}

- (void)woundDetailViewControllerDidCancelUpdate:(WMWoundDetailViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    // reload table
    [self.tableView reloadData];
}

- (void)woundDetailViewController:(WMWoundDetailViewController *)viewController didDeleteWound:(WMWound *)wound
{
    [self.appDelegate.navigationCoordinator deleteWound:wound];
    [self.navigationController popViewControllerAnimated:YES];
    // reload table
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self indexPathIsAddWound:indexPath];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([self indexPathIsAddWound:indexPath] ? UITableViewCellEditingStyleInsert:UITableViewCellEditingStyleNone);
}

// edit detail information for patient record
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    // existing wound
    WMWound *wound = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self navigateToWoundDetailForWound:wound];
}

// Controls whether the background is indented while editing.  If not implemented, the default is YES.
// This is unrelated to the indentation level below.  This method only applies to grouped style table views.
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

// select existing patient document
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self indexPathIsAddWound:indexPath]) {
        // add wound
        [self navigateToWoundDetailForWound:nil];
    } else {
        // existing wound
        self.appDelegate.navigationCoordinator.wound = [self.fetchedResultsController objectAtIndexPath:indexPath];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [super tableView:tableView numberOfRowsInSection:section] + 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [self indexPathIsAddWound:indexPath] ? @"AddWound":@"WoundCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        if ([self indexPathIsAddWound:indexPath]) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
        } else {
            // TODO WoundTableViewCell - show wound type, location
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        }
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    if ([self indexPathIsAddWound:indexPath]) {
        // add wound cell
        cell.textLabel.text = @"Add Wound";
    } else {
        // existing wound cell
        WMWound *wound = [self.fetchedResultsController objectAtIndexPath:indexPath];
        cell.imageView.image = (wound == self.wound ? [WMDesignUtilities selectedWoundTableCellImage]:[WMDesignUtilities unselectedWoundTableCellImage]);
        cell.textLabel.text = wound.name;
        cell.detailTextLabel.text = wound.woundType.title;
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
}

// Allows the reorder accessory view to optionally be shown for a particular row.
// By default, the reorder control will be shown only if the datasource implements -tableView:moveRowAtIndexPath:toIndexPath:
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self navigateToWoundDetailForWound:nil];
}

#pragma mark - NSFetchedResultsController

- (NSString *)ffQuery
{
    return [NSString stringWithFormat:@"%@/%@", self.patient.ffUrl, WMPatientRelationships.wounds];
}

- (NSString *)fetchedResultsControllerEntityName
{
	return [WMWound entityName];
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
    return [NSPredicate predicateWithFormat:@"SELF IN (%@)", self.patient.wounds];
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
    return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:WMWoundAttributes.createdAt ascending:NO]];
}

@end
