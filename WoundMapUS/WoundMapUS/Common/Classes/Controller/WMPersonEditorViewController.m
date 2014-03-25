//
//  WMPersonEditorViewController.m
//  WoundMapUS
//
//  Created by etreasure consulting LLC on 2/17/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMPersonEditorViewController.h"
#import "WMAddressListViewController.h"
#import "WMTelecomListViewController.h"
#import "WMValue1TableViewCell.h"
#import "WMTextFieldTableViewCell.h"
#import "WMPerson.h"
#import "CoreDataHelper.h"
#import "WMUtilities.h"

@interface WMPersonEditorViewController () <UITextFieldDelegate, AddressListViewControllerDelegate>

@property (nonatomic) BOOL removeUndoManagerWhenDone;
@property (readonly, nonatomic) WMAddressListViewController *addressListViewController;
@property (readonly, nonatomic) WMTelecomListViewController *telecomListViewController;

- (NSString *)cellReuseIdentifier:(NSIndexPath *)indexPath;

@end

@implementation WMPersonEditorViewController

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
    self.title = @"Contact Details";
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
    return self.delegate.managedObjectContext;
}

- (WMPerson *)person
{
    if (nil == _person) {
        _person = [WMPerson MR_createInContext:self.managedObjectContext];
    }
    return _person;
}

- (WMAddressListViewController *)addressListViewController
{
    WMAddressListViewController *addressListViewController = [[WMAddressListViewController alloc] initWithNibName:@"WMAddressListViewController" bundle:nil];
    addressListViewController.delegate = self;
    return addressListViewController;
}

- (WMTelecomListViewController *)telecomListViewController
{
    WMTelecomListViewController *telecomListViewController = [[WMTelecomListViewController alloc] initWithNibName:@"WMTelecomListViewController" bundle:nil];
    telecomListViewController.delegate = self;
    return telecomListViewController;
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
            // given name
            cellReuseIdentifier = @"TextCell";
            break;
        }
        case 2: {
            // family name
            cellReuseIdentifier = @"TextCell";
            break;
        }
        case 3: {
            // suffix
            cellReuseIdentifier = @"TextCell";
            break;
        }
        case 4: {
            // addresses
            cellReuseIdentifier = @"ValueCell";
            break;
        }
        case 5: {
            // telecoms
            cellReuseIdentifier = @"ValueCell";
            break;
        }
    }
    return cellReuseIdentifier;
}

- (BOOL)validateInput
{
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    if ([self.person.telecoms count] == 0) {
        [messages addObject:@"Please add at least one email address"];
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
        [self.delegate personEditorViewController:self didEditPerson:_person];
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
    [self.delegate personEditorViewControllerDidCancel:self];
}

#pragma mark - WMBaseViewController

- (void)clearDataCache
{
    [super clearDataCache];
    _person = nil;
}

#pragma mark - AddressListViewControllerDelegate

- (id<AddressSource>)addressSource
{
    return _person;
}

- (NSString *)addressRelationshipKey
{
    return @"person";
}

- (void)addressListViewControllerDidFinish:(WMAddressListViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:4 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void)addressListViewControllerDidCancel:(WMAddressListViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TelecomListViewControllerDelegate

- (id<TelecomSource>)telecomSource
{
    return _person;
}

- (NSString *)telecomRelationshipKey
{
    return @"person";
}

- (void)telecomListViewControllerDidFinish:(WMTelecomListViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:5 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void)telecomListViewControllerDidCancel:(WMTelecomListViewController *)viewController
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
            // prefix
            self.person.namePrefix = textField.text;
            break;
        }
        case 1: {
            // given name
            self.person.nameGiven = textField.text;
            break;
        }
        case 2: {
            // family name
            self.person.nameFamily = textField.text;
            break;
        }
        case 3: {
            // suffix
            self.person.nameSuffix = textField.text;
            break;
        }
    }
}

#pragma mark - UITableViewDelegate

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 4) {
        // address
        [self.navigationController pushViewController:self.addressListViewController animated:YES];
    } else if (indexPath.row == 5) {
        // telecom
        [self.navigationController pushViewController:self.telecomListViewController animated:YES];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [self cellReuseIdentifier:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if ([cell isKindOfClass:[WMTextFieldTableViewCell class]]) {
        WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
        myCell.textField.delegate = self;
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0: {
            // prefix
            WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
            [myCell updateWithLabelText:@"Prefix" valueText:self.person.namePrefix valuePrompt:@"Dr, Mr, Ms, etc"];
            break;
        }
        case 1: {
            // given name
            WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
            [myCell updateWithLabelText:@"Given Name" valueText:self.person.nameGiven valuePrompt:@"Given or First Name"];
            break;
        }
        case 2: {
            // family name
            WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
            [myCell updateWithLabelText:@"Family Name" valueText:self.person.nameFamily valuePrompt:@"Family or Last Name"];
            break;
        }
        case 3: {
            // suffix
            WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
            [myCell updateWithLabelText:@"Suffix" valueText:self.person.nameSuffix valuePrompt:@"III, Esquire, etc"];
            break;
        }
        case 4: {
            // addresses
            cell.textLabel.text = @"Addresses";
            NSString *addressString = ([self.person.telecoms count] == 1 ? @"address":@"addresses");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu %@", (unsigned long)[self.person.addresses count], addressString];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case 5: {
            // telecoms
            cell.textLabel.text = @"Telecoms";
            NSString *telecomString = ([self.person.telecoms count] == 1 ? @"telecom":@"telecoms");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu %@", (unsigned long)[self.person.telecoms count], telecomString];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
    }
}

@end
