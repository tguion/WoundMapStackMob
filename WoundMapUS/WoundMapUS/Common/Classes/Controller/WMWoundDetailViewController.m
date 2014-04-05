//
//  WMWoundDetailViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//  TODO: create and associate new wound as appropriate

#import "WMWoundDetailViewController.h"
#import "WMSelectWoundTypeViewController.h"
#import "WMSelectWoundLocationViewController.h"
#import "WMWound.h"
#import "WMWoundType.h"
#import "WMWoundLocation.h"
#import "WMWoundLocationValue.h"
#import "WMFatFractal.h"
#import "WMFatFractalManager.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"

#define kDeleteWoundActionSheetTag 1000

@interface WMWoundDetailViewController () <UITextFieldDelegate, UIActionSheetDelegate, SelectWoundTypeViewControllerDelegate, SelectWoundLocationViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableViewCell *woundNameCell;
@property (strong, nonatomic) IBOutlet UIView *deleteWoundContainerView;
@property (readonly, nonatomic) WMSelectWoundTypeViewController *selectWoundTypeViewController;
@property (readonly, nonatomic) WMSelectWoundLocationViewController *selectWoundLocationViewController;

@property (nonatomic) BOOL didCancel;

- (IBAction)deleteWoundAction:(id)sender;

@end

@implementation WMWoundDetailViewController

- (WMSelectWoundTypeViewController *)selectWoundTypeViewController
{
    WMSelectWoundTypeViewController *selectWoundTypeViewController = [[WMSelectWoundTypeViewController alloc] initWithNibName:@"WMSelectWoundTypeViewController" bundle:nil];
    selectWoundTypeViewController.delegate = self;
    return selectWoundTypeViewController;
}

- (WMSelectWoundLocationViewController *)selectWoundLocationViewController
{
    WMSelectWoundLocationViewController *selectWoundLocationViewController = [[WMSelectWoundLocationViewController alloc] initWithNibName:@"WMSelectWoundLocationViewController" bundle:nil];
    selectWoundLocationViewController.delegate = self;
    return selectWoundLocationViewController;
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Add code to clean up any of your own resources that are no longer necessary.
}

// clear any strong references to views
- (void)clearViewReferences
{
    [super clearViewReferences];
    _woundNameCell = nil;
    _deleteWoundContainerView = nil;
}

#pragma mark - View

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // set state
        self.preferredContentSize = CGSizeMake(320.0, 260.0);
        self.modalInPopover = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.managedObjectContext.undoManager beginUndoGrouping];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                           target:self
                                                                                           action:@selector(saveAction:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *title = self.wound.shortName;
    if ([title length] == 0) {
        title = @"New Wound";
    }
    self.title = title;
    if (!_newWoundFlag) {
        self.tableView.tableFooterView = _deleteWoundContainerView;
    }
    _didCancel = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.view endEditing:YES];
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - BaseViewController

- (void)updateTitle
{
    // no
}

#pragma mark - Actions

- (IBAction)saveAction:(id)sender
{
    [self.view endEditing:YES];
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
    }
    [self.delegate woundDetailViewControllerDidUpdateWound:self];
}

- (IBAction)cancelAction:(id)sender
{
    _didCancel = YES;
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
        if (_didCancel && self.managedObjectContext.undoManager.canUndo) {
            [self.managedObjectContext.undoManager undoNestedGroup];
        }
    }
    [self.delegate woundDetailViewControllerDidCancelUpdate:self];
}

- (IBAction)deleteWoundAction:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Deleting wound will delete all associated data, including photos of wound"
                                                             delegate:self
                                                    cancelButtonTitle:(self.isIPadIdiom ? nil:@"Cancel")
                                               destructiveButtonTitle:@"Delete"
                                                    otherButtonTitles:(self.isIPadIdiom ? @"Cancel":nil), nil];
    actionSheet.tag = kDeleteWoundActionSheetTag;
    UIButton *button = (UIButton *)sender;
    if (self.isIPadIdiom) {
        [actionSheet showInView:self.view];
    } else {
        [actionSheet showFromRect:button.frame inView:self.view animated:YES];
    }
}

#pragma mark - UIActionSheetDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kDeleteWoundActionSheetTag) {
        if (actionSheet.destructiveButtonIndex == buttonIndex) {
            [self.delegate woundDetailViewController:self didDeleteWound:self.wound];
        }
    }
}

#pragma mark - SelectWoundTypeViewControllerDelegate

- (void)selectWoundTypeViewController:(WMSelectWoundTypeViewController *)viewController didSelectWoundType:(WMWoundType *)woundType
{
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
    }
    self.wound.woundType = woundType;
    [self.navigationController popViewControllerAnimated:YES];
    // clear
    [viewController clearAllReferences];
}

// FIXME: don't understand why the undo group does not work: if change wound name, and navigate to wound type and cancel, wound name is undone also
- (void)selectWoundTypeViewControllerDidCancel:(WMSelectWoundTypeViewController *)viewController
{
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
        if (self.managedObjectContext.undoManager.canUndo) {
            [self.managedObjectContext.undoManager undoNestedGroup];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
    // clear
    [viewController clearAllReferences];
}

#pragma mark - SelectWoundLocationViewControllerDelegate

- (void)selectWoundLocationViewController:(WMSelectWoundLocationViewController *)viewController didSelectWoundLocation:(WMWoundLocation *)woundLocation
{
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
    }
    WMWoundLocationValue *woundLocationValue = [WMWoundLocationValue woundLocationValueForWound:self.wound];
    self.wound.locationValue = woundLocationValue;
    // update back end

    [self.navigationController popViewControllerAnimated:YES];
    // clear
    [viewController clearAllReferences];
}

- (void)selectWoundLocationViewControllerDidCancel:(WMSelectWoundLocationViewController *)viewController
{
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
        if (self.managedObjectContext.undoManager.canUndo) {
            [self.managedObjectContext.undoManager undoNestedGroup];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
    // clear
    [viewController clearAllReferences];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // create undo group
    [self.managedObjectContext.undoManager beginUndoGrouping];
    switch (indexPath.row) {
        case 1: {
            // wound type
            [self.managedObjectContext.undoManager setActionName:@"EditWoundType"];
            [self.navigationController pushViewController:self.selectWoundTypeViewController animated:YES];
            break;
        }
        case 2: {
            // wound location
            [self.managedObjectContext.undoManager setActionName:@"EditWoundLocation"];
            [self.navigationController pushViewController:self.selectWoundLocationViewController animated:YES];
            break;
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// fixed font style. use custom view (UILabel) if you want something different
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"Cell%ld-%ld", (long)indexPath.row, (long)indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell) {
        if (indexPath.row == 0) {
            cell = self.woundNameCell;
        } else if (indexPath.row == 3) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        } else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        }
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0: {
            // wound name or identifier
            UITextField *textField = (UITextField *)[cell.contentView viewWithTag:1000];
            textField.text = self.wound.name;
            break;
        }
        case 1: {
            // wound type
            cell.textLabel.text = @"Type";
            cell.detailTextLabel.text = self.wound.woundType.titleForDisplay;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case 2: {
            // wound location
            cell.textLabel.text = @"Location";
            NSString *string = self.wound.locationValue.location.title;
            if ([self.wound.positionValues count] > 0) {
                string = [string stringByAppendingFormat:@":%@", self.wound.positionValuesForDisplay];
            }
            cell.detailTextLabel.text = string;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
    }
}

#pragma mark - UITextFieldDelegate

// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag) {
        case 1000:
            self.wound.name = textField.text;
            self.title = textField.text;
            break;
    }
}

// called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.text length] == 0) {
        return NO;
    }
    // else
    [textField resignFirstResponder];
    return YES;
}

@end
