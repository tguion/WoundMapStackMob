//
//  WMOrganizationEditorViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 3/30/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMOrganizationEditorViewController.h"
#import "WMAddressListViewController.h"
#import "WMIdListViewController.h"
#import "WMValue1TableViewCell.h"
#import "WMTextFieldTableViewCell.h"
#import "WMOrganization.h"

@interface WMOrganizationEditorViewController ()  <UITextFieldDelegate, AddressListViewControllerDelegate, IdListViewControllerDelegate>

@property (weak, nonatomic) NSManagedObjectContext *moc;

@property (nonatomic) BOOL removeUndoManagerWhenDone;
@property (readonly, nonatomic) WMAddressListViewController *addressListViewController;
@property (readonly, nonatomic) WMIdListViewController *idListViewController;

- (NSString *)cellReuseIdentifier:(NSIndexPath *)indexPath;

@end

@implementation WMOrganizationEditorViewController

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
    self.title = @"Organization";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneAction:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelAction:)];
    [self.tableView registerClass:[WMTextFieldTableViewCell class] forCellReuseIdentifier:@"TextCell"];
    [self.tableView registerClass:[WMValue1TableViewCell class] forCellReuseIdentifier:@"ValueCell"];
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
    if (nil == _moc) {
        _moc = self.delegate.managedObjectContext;
    }
    return _moc;
}

- (WMOrganization *)organization
{
    if (nil == _organization) {
        _organization = [WMOrganization MR_createInContext:self.managedObjectContext];
    }
    return _organization;
}

- (WMAddressListViewController *)addressListViewController
{
    WMAddressListViewController *addressListViewController = [[WMAddressListViewController alloc] initWithNibName:@"WMAddressListViewController" bundle:nil];
    addressListViewController.delegate = self;
    return addressListViewController;
}

- (WMIdListViewController *)idListViewController
{
    WMIdListViewController *idListViewController = [[WMIdListViewController alloc] initWithNibName:@"WMIdListViewController" bundle:nil];
    idListViewController.delegate = self;
    return idListViewController;
}
- (NSString *)cellReuseIdentifier:(NSIndexPath *)indexPath
{
    NSString *cellReuseIdentifier = nil;
    switch (indexPath.row) {
        case 0: {
            // prefix
            cellReuseIdentifier = @"TextCell";
            break;
        }
        case 1: {
            // addresses
            cellReuseIdentifier = @"ValueCell";
            break;
        }
        case 2: {
            // ids
            cellReuseIdentifier = @"ValueCell";
            break;
        }
    }
    return cellReuseIdentifier;
}

- (BOOL)validateInput
{
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    if ([_organization.addresses count] == 0) {
        [messages addObject:@"Please add at least one address"];
    }
    if ([_organization.ids count] == 0) {
        [messages addObject:@"Please add at least one id"];
    }
    if ([messages count]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Missing Information"
                                                            message:[messages componentsJoinedByString:@"\r"]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    // else
    return YES;
}

#pragma mark - Actions

- (IBAction)doneAction:(id)sender
{
    [self.view endEditing:YES];
    [self performSelector:@selector(delayedDoneAction) withObject:nil afterDelay:0.0];
}

- (void)delayedDoneAction
{
    if ([self validateInput]) {
        if (self.managedObjectContext.undoManager.groupingLevel > 0) {
            [self.managedObjectContext.undoManager endUndoGrouping];
        }
        if (_removeUndoManagerWhenDone) {
            self.managedObjectContext.undoManager = nil;
        }
        [self.managedObjectContext MR_saveOnlySelfAndWait];
        [self.delegate organizationEditorViewController:self didEditOrganization:_organization];
    }
}

- (IBAction)cancelAction:(id)sender
{
    [self.view endEditing:YES];
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
    [self.delegate organizationEditorViewControllerDidCancel:self];
}

#pragma mark - WMBaseViewController

- (void)clearDataCache
{
    [super clearDataCache];
    _organization = nil;
}

#pragma mark - AddressListViewControllerDelegate

- (id<AddressSource>)addressSource
{
    return _organization;
}

- (void)addressListViewControllerDidFinish:(WMAddressListViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void)addressListViewControllerDidCancel:(WMAddressListViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - IdListViewControllerDelegate

- (id<idSource>)idSource
{
    return _organization;
}

- (void)idListViewControllerDidFinish:(WMIdListViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void)idListViewControllerDidCancel:(WMIdListViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    UITableViewCell *cell = [self cellForView:textField];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    switch (indexPath.row) {
        case 0: {
            // name
            _organization.name = textField.text;
            break;
        }
    }
}

#pragma mark - UITableViewDelegate

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 1: {
            [self.navigationController pushViewController:self.addressListViewController animated:YES];
            break;
        }
        case 2: {
            [self.navigationController pushViewController:self.idListViewController animated:YES];
            break;
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
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
    switch (indexPath.row) {
        case 0: {
            // name
            WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
            UITextField *textField = myCell.textField;
            textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            textField.spellCheckingType = UITextSpellCheckingTypeNo;
            textField.returnKeyType = UIReturnKeyDefault;
            textField.delegate = self;
            myCell.textField.tag = 1000;
            [myCell updateWithLabelText:@"Name" valueText:self.organization.name valuePrompt:@"organization name"];
            break;
        }
        case 1: {
            // addresses
            cell.textLabel.text = @"Addresses";
            NSString *addressString = ([self.organization.addresses count] == 1 ? @"address":@"addresses");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu %@", (unsigned long)[self.organization.addresses count], addressString];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case 2: {
            // ids
            cell.textLabel.text = @"Ids";
            NSString *idString = ([self.organization.ids count] == 1 ? @"id":@"ids");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu %@", (unsigned long)[self.organization.ids count], idString];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
    }
}

@end
