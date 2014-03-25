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
@property (strong, nonatomic) NSArray *addresses;

- (BOOL)isAddIndexPath:(NSIndexPath *)indexPath;

@end

@implementation WMAddressListViewController

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneAction:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelAction:)];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"AddCell"];
    // allow editing
    [self.tableView setEditing:YES animated:NO];
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
    return indexPath.row == [self.delegate.addressSource.addresses count];
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
    if (nil == _addresses) {
        _addresses = [[self.delegate.addressSource.addresses allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:YES]]];
    }
    return _addresses[index];
}

#pragma mark - WMBaseViewController

- (void)clearDataCache
{
    [super clearDataCache];
    _addresses = nil;
}

#pragma mark - Actions

- (IBAction)addAction:(id)sender
{
    WMAddress *address = [WMAddress MR_createInContext:self.managedObjectContext];
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
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
        if (self.managedObjectContext.undoManager.canUndo) {
            // this should undo the insert of new person
            [self.managedObjectContext.undoManager undoNestedGroup];
        }
    }
    if (_removeUndoManagerWhenDone) {
        self.managedObjectContext.undoManager = nil;
    }
    [self.delegate addressListViewControllerDidCancel:self];
}

#pragma mark - WMBaseViewController

#pragma mark - AddressEditorViewControllerDelegate

- (void)addressEditorViewController:(WMAddressEditorViewController *)viewController didEditAddress:(WMAddress *)address
{
    [self.delegate.addressSource addAddressesObject:address];
    [self.navigationController popViewControllerAnimated:YES];
    _addresses = nil;
    [self.tableView reloadData];
    [viewController clearAllReferences];
}

- (void)addressEditorViewControllerDidCancel:(WMAddressEditorViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44.0;
    if (![self isAddIndexPath:indexPath]) {
        WMAddress *address = [self addressForIndex:indexPath.row];
        NSAttributedString *attributedString = [address descriptionAsMutableAttributedStringWithBaseFontSize:15.0];
        CGSize aSize = CGSizeMake(CGRectGetWidth(self.tableView.bounds) - self.tableView.separatorInset.left - self.tableView.separatorInset.right, CGFLOAT_MAX);
        height = ceilf([attributedString boundingRectWithSize:aSize
                                                options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                context:nil].size.height) + 32.0;
    }
    return height;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([self isAddIndexPath:indexPath] ? UITableViewCellEditingStyleInsert:UITableViewCellEditingStyleDelete);
}

// Controls whether the background is indented while editing.  If not implemented, the default is YES.
// This is unrelated to the indentation level below.  This method only applies to grouped style table views.
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

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
    return [self.delegate.addressSource.addresses count] + 1;
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
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.attributedText = attributedString;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WMAddress *address = [self addressForIndex:indexPath.row];
        [self.delegate.addressSource removeAddressesObject:address];
        _addresses = nil;
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [self.tableView endUpdates];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        [self addAction:nil];
    }
}

// FRC did not work
// 2014-02-20 14:04:49.272 WoundMapUS[2323:70b] *** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: 'Cannot retrieve referenceObject from an objectID that was not created by this store'

@end
