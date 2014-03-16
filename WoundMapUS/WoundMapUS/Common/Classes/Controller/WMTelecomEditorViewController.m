//
//  WMTelecomEditorViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 3/16/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMTelecomEditorViewController.h"
#import "WMTextFieldTableViewCell.h"
#import "WMValue1TableViewCell.h"
#import "WMTelecom.h"
#import "WMTelecomType.h"
#import "WCAppDelegate.h"
#import "WMFatFractalManager.h"
#import "WMUtilities.h"

@interface WMTelecomEditorViewController () <UITextFieldDelegate>

@property (nonatomic) BOOL removeUndoManagerWhenDone;
@property (strong, nonatomic) WMTelecomType *telecomType;

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

- (void)navigateToTelecomType
{
    // make sure we have data
    if ([WMTelecomType MR_countOfEntitiesWithContext:self.managedObjectContext]) {
        // ok to navigate
    }
    // else backend may not have data or device has not fetched
    [self showProgressViewWithMessage:@"Updating telecom data"];
    __weak __typeof(&*self)weakSelf = self;
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    [ff getArrayFromUri:[NSString stringWithFormat:@"/%@", [WMTelecomType entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        WM_ASSERT_MAIN_THREAD;
        if (error) {
            [WMUtilities logError:error];
            [weakSelf hideProgressView];
        } else {
            WM_ASSERT_MAIN_THREAD;
            [weakSelf.managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                if (error) {
                    [WMUtilities logError:error];
                } else {
                    // ok to navigate
                }
            }];
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

#pragma mark - UITextFieldDelegate

// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    UITableViewCell *cell = [self cellForView:textField];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    switch (indexPath.row) {
        case 1: {
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
    if (indexPath.row == 2) {
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
            // type
            cell.textLabel.text = @"Type";
            cell.detailTextLabel.text = self.telecomType.title;
            break;
        }
        case 1: {
            // use
            WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
            [myCell updateWithLabelText:@"Use" valueText:self.telecom.value valuePrompt:@"DIR"];
            break;
        }
        case 2: {
            // city
            WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
            [myCell updateWithLabelText:@"Value" valueText:self.telecom.value valuePrompt:@"you@host.org"]; // TODO adjust value and use using type
            break;
        }
    }
}

@end
