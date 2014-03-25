//
//  WMTelecomEditorViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 3/16/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMTelecomEditorViewController.h"
#import "WMSimpleTableViewController.h"
#import "WMTextFieldTableViewCell.h"
#import "WMValue1TableViewCell.h"
#import "MBProgressHUD.h"
#import "WMTelecom.h"
#import "WMTelecomType.h"
#import "WCAppDelegate.h"
#import "WMFatFractalManager.h"
#import "WMUtilities.h"

@interface WMTelecomEditorViewController () <SimpleTableViewControllerDelegate, UITextFieldDelegate>

@property (nonatomic) BOOL removeUndoManagerWhenDone;
@property (strong, nonatomic) WMTelecomType *telecomType;
@property (readonly, nonatomic) WMSimpleTableViewController *simpleTableViewController;

@end

@implementation WMTelecomEditorViewController

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
    self.title = @"Telecom Details";
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

- (NSString *)cellReuseIdentifier:(NSIndexPath *)indexPath
{
    NSString *cellReuseIdentifier = nil;
    switch (indexPath.row) {
        case 0: {
            // use
            cellReuseIdentifier = @"TextCell";  // TODO: select value set
            break;
        }
        case 1: {
            // type
            cellReuseIdentifier = @"ValueCell";
            break;
        }
        case 2: {
            // value
            cellReuseIdentifier = @"TextCell";
            break;
        }
    }
    return cellReuseIdentifier;
}

- (BOOL)validateInput
{
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    if ([self.telecom.value length] == 0) {
        [messages addObject:@"Please enter a valid telecom value"];
    }
    if (nil == _telecomType) {
        [messages addObject:@"Please select a telecom type"];
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

- (WMSimpleTableViewController *)simpleTableViewController
{
    WMSimpleTableViewController *simpleTableViewController = [[WMSimpleTableViewController alloc] initWithNibName:@"WMSimpleTableViewController" bundle:nil];
    simpleTableViewController.delegate = self;
    simpleTableViewController.allowMultipleSelection = NO;
    return simpleTableViewController;
}

- (void)navigateToTelecomType
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    // backend may not have data or device has not fetched
    MBProgressHUD *progressView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progressView.labelText = @"Updating telecom data";
    __weak __typeof(&*self)weakSelf = self;
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMTelecomType entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        WM_ASSERT_MAIN_THREAD;
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if (error) {
            [WMUtilities logError:error];
        } else {
            WM_ASSERT_MAIN_THREAD;
            // make sure we have data
            if ([WMTelecomType MR_countOfEntitiesWithContext:managedObjectContext] == 0) {
                // load data
                [WMTelecomType seedDatabase:managedObjectContext];
            }
            WMSimpleTableViewController *simpleTableViewController = weakSelf.simpleTableViewController;
            [weakSelf.navigationController pushViewController:simpleTableViewController animated:YES];
            simpleTableViewController.title = @"Select Telecom Type";
        }
    }];
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
        self.telecom.telecomType = _telecomType;
        [self.delegate telecomEditorViewController:self didEditTelecom:_telecom];
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
    [self.delegate telecomEditorViewControllerDidCancel:self];
}

#pragma mark - WMBaseViewController

- (void)clearDataCache
{
    [super clearDataCache];
    _telecom = nil;
    _telecomType = nil;
}

#pragma mark - SimpleTableViewControllerDelegate

- (NSString *)navigationTitle
{
    return @"Select Telecom Type";
}

- (NSArray *)valuesForDisplay
{
    return [[WMTelecomType sortedTelecomTypes:self.managedObjectContext] valueForKey:@"title"];
}

- (NSArray *)selectedValuesForDisplay
{
    if (nil == _telecomType) {
        return [NSArray array];
    }
    // else
    return [NSArray arrayWithObject:_telecomType.title];
}

- (void)simpleTableViewController:(WMSimpleTableViewController *)viewController didSelectValues:(NSArray *)selectedValues
{
    NSString *title = [selectedValues lastObject];
    if ([title length] > 0) {
        _telecomType = [WMTelecomType telecomTypeForTitle:title
                                                   create:NO
                                     managedObjectContext:self.managedObjectContext];
    }
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void)simpleTableViewControllerDidCancel:(WMSimpleTableViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
}

#pragma mark - UITextFieldDelegate

// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    UITableViewCell *cell = [self cellForView:textField];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    switch (indexPath.row) {
        case 0: {
            // use
            self.telecom.use = textField.text;
            break;
        }
        case 2: {
            // value
            self.telecom.value = textField.text;
            break;
        }
    }
}

#pragma mark - UITableViewDelegate

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1) {
        [self navigateToTelecomType];
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
            // use
            WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
            [myCell updateWithLabelText:@"Use" valueText:self.telecom.use valuePrompt:@"DIR"];
            myCell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 1: {
            // type
            cell.textLabel.text = @"Type";
            cell.detailTextLabel.text = self.telecomType.title;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case 2: {
            // value
            WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
            [myCell updateWithLabelText:@"Value" valueText:self.telecom.value valuePrompt:@"you@host.org"]; // TODO adjust value and use using type
            myCell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
    }
}

@end
