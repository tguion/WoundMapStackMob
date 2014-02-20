//
//  WMAddressListViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/20/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//
//  TODO: + sign on add address, height for cell attributedString

#import "WMAddressListViewController.h"
#import "WMAddressEditorViewController.h"
#import "WMAddress.h"
#import "WMAddress+CoreText.h"
#import "WMUtilities.h"

@interface WMAddressListViewController () <AddressEditorViewControllerDelegate>

@property (nonatomic) BOOL removeUndoManagerWhenDone;
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
    // we want to support cancel, so make sure we have an undoManager
    if (nil == self.managedObjectContext.undoManager) {
        self.managedObjectContext.undoManager = [[NSUndoManager alloc] init];
        _removeUndoManagerWhenDone = YES;
    }
    [self.managedObjectContext.undoManager beginUndoGrouping];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core

- (NSManagedObjectContext *)managedObjectContext
{
    return self.delegate.managedObjectContext;
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
    return indexPath.row == [self.delegate.source.addresses count];
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

- (WMAddress *)addressForIndex:(NSInteger)index
{
    NSArray *addresses = [[self.delegate.source.addresses allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastmoddate" ascending:YES]]];
    return addresses[index];
}

#pragma mark - Actions

- (IBAction)addAction:(id)sender
{
    WMAddress *address = [WMAddress instanceWithManagedObjectContext:self.managedObjectContext persistentStore:nil];
    [self navigateToAddressEditorForAddress:address];
}

- (IBAction)doneAction:(id)sender
{
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
    }
    if (_removeUndoManagerWhenDone) {
        self.managedObjectContext.undoManager = nil;
    }
    [self.delegate addressListViewControllerDidFinish:self];
}

- (IBAction)cancelAction:(id)sender
{
    [self clearAllReferences];
    [self.delegate addressListViewControllerDidCancel:self];
}

#pragma mark - WMBaseViewController

#pragma mark - AddressEditorViewControllerDelegate

- (void)addressEditorViewController:(WMAddressEditorViewController *)viewController didEditAddress:(WMAddress *)address
{
    [self.delegate.source addAddressesObject:address];
    [self.navigationController popViewControllerAnimated:YES];
    [self.tableView reloadData];
}

- (void)addressEditorViewControllerDidCancel:(WMAddressEditorViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
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
        [self navigateToAddressEditorForAddress:[self addressForIndex:indexPath.row]];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.delegate.source.addresses count] + 1;
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
        WMAddress *address = [self addressForIndex:indexPath.row];
        NSAttributedString *attributedString = [address descriptionAsMutableAttributedStringWithBaseFontSize:15.0];
        cell.textLabel.attributedText = attributedString;
    }
}

// 2014-02-20 14:04:49.272 WoundMapUS[2323:70b] *** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: 'Cannot retrieve referenceObject from an objectID that was not created by this store'

#pragma mark - NSFetchedResultsController

- (NSString *)fetchedResultsControllerEntityName
{
    return [WMAddress entityName];
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
    return [NSPredicate predicateWithFormat:@"%K == %@", self.delegate.relationshipKey, self.delegate.source];
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
    return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"lastmoddate" ascending:NO]];
}

@end
