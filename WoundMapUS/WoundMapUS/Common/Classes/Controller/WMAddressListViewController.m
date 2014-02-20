//
//  WMAddressListViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/20/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMAddressListViewController.h"
#import "WMAddressEditorViewController.h"
#import "WMAddress.h"
#import "WMAddress+CoreText.h"
#import "WMUtilities.h"

@interface WMAddressListViewController () <AddressEditorViewControllerDelegate>

@property (strong, nonatomic, readwrite) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) id<AddressSource> childAddressSource;
@property (readonly, nonatomic) WMAddressEditorViewController *addressEditorViewController;

- (BOOL)isAddIndexPath:(NSIndexPath *)indexPath;

@end

@implementation WMAddressListViewController

@synthesize managedObjectContext=_managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Addresses";
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                              target:self
                                                                                              action:@selector(doneAction:)],
                                                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                              target:self
                                                                                              action:@selector(addAction:)]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelAction:)];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"AddCell"];
    self.fetchPolicy = SMFetchPolicyCacheOnly;
    self.savePolicy = SMSavePolicyCacheOnly;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core

- (NSManagedObjectContext *)managedObjectContext
{
    if (nil == _managedObjectContext) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _managedObjectContext.parentContext = self.delegate.source.managedObjectContext;
    }
    return _managedObjectContext;
}

- (id<AddressSource>)childAddressSource
{
    if (nil == _childAddressSource) {
        _childAddressSource = (id<AddressSource>)[self.managedObjectContext objectWithID:self.delegate.source.objectID];
    }
    return _childAddressSource;
}

- (NSString *)cellReuseIdentifier:(NSIndexPath *)indexPath
{
    NSString *cellReuseIdentifier = @"Cell";
    if ([self isAddIndexPath:indexPath]) {
        cellReuseIdentifier = @"AddCell";
    }
    return cellReuseIdentifier;
}

- (BOOL)isAddIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row == [self.childAddressSource.addresses count];
}

- (WMAddressEditorViewController *)addressEditorViewController
{
    WMAddressEditorViewController *addressEditorViewController = [[WMAddressEditorViewController alloc] initWithNibName:@"WMAddressEditorViewController" bundle:nil];
    addressEditorViewController.delegate = self;
    return addressEditorViewController;
}

- (void)navigateToAddressEditorForAddress:(WMAddress *)address
{
    WMAddressEditorViewController *addressEditorViewController = self.addressEditorViewController;
    addressEditorViewController.address = address;
    [self.navigationController pushViewController:addressEditorViewController animated:YES];
}

#pragma mark - Actions

- (IBAction)addAction:(id)sender
{
    WMAddress *address = [WMAddress instanceWithManagedObjectContext:self.managedObjectContext persistentStore:nil];
    [self navigateToAddressEditorForAddress:address];
}

- (IBAction)doneAction:(id)sender
{
    NSError *error = nil;
    BOOL success = [self.managedObjectContext save:&error];
    if (!success) {
        [WMUtilities logError:error];
    }
    [self.delegate addressListViewControllerDidFinish:self];
}

- (IBAction)cancelAction:(id)sender
{
    [self.delegate addressListViewControllerDidCancel:self];
}

#pragma mark - WMBaseViewController

- (void)clearDataCache
{
    [super clearDataCache];
    _managedObjectContext = nil;
    _childAddressSource = nil;
}

#pragma mark - AddressEditorViewControllerDelegate

- (void)addressEditorViewController:(WMAddressEditorViewController *)viewController didEditAddress:(WMAddress *)address
{
    [self.childAddressSource addAddressesObject:address];
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
    [self.tableView reloadData];
}

- (void)addressEditorViewControllerDidCancel:(WMAddressEditorViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
}

#pragma mark - UITableViewDelegate

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self isAddIndexPath:indexPath]) {
        // add address
        [self addAction:nil];
    } else {
        // edit address
        [self navigateToAddressEditorForAddress:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (nil == _childAddressSource) {
        return 0;
    }
    // else
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.childAddressSource.addresses count] + 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [self cellReuseIdentifier:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([self isAddIndexPath:indexPath]) {
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.textLabel.text = @"Add Address";
    } else {
        WMAddress *address = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSAttributedString *attributedString = [address descriptionAsMutableAttributedStringWithBaseFontSize:15.0];
        cell.textLabel.attributedText = attributedString;
    }
}

#pragma mark - NSFetchedResultsController

- (NSString *)fetchedResultsControllerEntityName
{
    return [WMAddress entityName];
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
    return [NSPredicate predicateWithFormat:@"SELF IN (%@)", self.childAddressSource.addresses];
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
    return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"lastmoddate" ascending:NO]];
}

@end
