//
//  WMPatientDetailViewController.m
//  WoundCarePhoto
//
//  Created by Todd Guion on 5/29/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import "WMPatientDetailViewController.h"
#import "WMPersonEditorViewController.h"
#import "WMIdListViewController.h"
#import "WMValue1TableViewCell.h"
#import "WMTextFieldTableViewCell.h"
#import "WMSegmentControlTableViewCell.h"
#import "MBProgressHUD.h"
#import "UIView+Custom.h"
#import "WMPatient.h"
#import "WMPerson.h"
#import "WMNavigationTrack.h"
#import "WMNavigationStage.h"
#import "WMUtilities.h"
#import "WMUserDefaultsManager.h"
#import "WMNavigationCoordinator.h"
#import "WMFatFractal.h"
#import "WMFatFractalManager.h"
#import "WCAppDelegate.h"

@interface WMPatientDetailViewController () <PersonEditorViewControllerDelegate, IdListViewControllerDelegate>

// data
@property (strong, nonatomic) WMPatient *patient;       // create patient if new patient, otherwise we hold a strong reference to the active patient (held by navigationCoordinator)
@property (strong, nonatomic) WMPerson *person;         // do no attach to new patient, since ff backend will barf. wait until we persist patient to back end.
// state
@property (nonatomic) BOOL removeUndoManagerWhenDone;
// UI
@property (strong, nonatomic) IBOutlet UIToolbar *inputAccessoryToolbar;
@property (readonly, nonatomic) UITextField *dobTextField;
@property (readonly, nonatomic) UITextField *ssnTextField;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePickerView;
@property (strong, nonatomic) NSDateFormatter *dateOfBirthDateFormatter;

@property (readonly, nonatomic) WMPersonEditorViewController *personEditorViewController;
@property (readonly, nonatomic) WMIdListViewController *idListViewController;

- (IBAction)cancelAction:(id)sender;
- (IBAction)saveAction:(id)sender;
- (IBAction)dateOfBirthChangedValueAction:(id)sender;
- (IBAction)dismissDatePickerAction:(id)sender;
- (IBAction)previousNextAction:(id)sender;

@end

@interface WMPatientDetailViewController (PrivateMethods)

- (void)updateDOBModelFromView;
- (void)updateUIFromPatient;
- (void)updateUIForDataChange;
- (UIResponder *)nextTextFieldResponder;
- (UIResponder *)previousTextFieldResponder;
- (UIResponder *)responderInCell:(UITableViewCell *)cell;

@end

@implementation WMPatientDetailViewController (PrivateMethods)

- (void)updateTitle
{
    NSString *title = nil;
    WMPatient *patient = self.patient;
    if (nil == patient) {
        title = @"Anonymous";
    } else {
        title = patient.lastNameFirstName;
    }
    self.title = title;
}

- (void)updateDOBModelFromView
{
    WMPatient *patient = self.patient;
    patient.dateOfBirth = self.datePickerView.date;
    // save dob for next patient
    self.userDefaultsManager.lastDateOfBirth = self.patient.dateOfBirth;
}

// update any view not table view cell
- (void)updateUIFromPatient
{
    [self updateTitle];
    WMPatient *patient = self.patient;
    NSDate *date = patient.dateOfBirth;
    if (nil == date) {
        date = self.userDefaultsManager.lastDateOfBirth;
        patient.dateOfBirth = date;
    }
    self.datePickerView.date = date;
    [self.tableView reloadData];
}

- (void)updateUIForDataChange
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelAction:)];
    if (self.managedObjectContext.hasChanges) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                               target:self
                                                                                               action:@selector(saveAction:)];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                               target:self
                                                                                               action:@selector(saveAction:)];
    }
}

- (UIResponder *)nextTextFieldResponder
{
    UIResponder *responder = nil;
    UITableViewCell *cell = [self cellForView:(UIView *)[self.tableView findFirstResponder]];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSInteger row = indexPath.row + 1;
    NSInteger section = indexPath.section;
    while (row < [self tableView:self.tableView numberOfRowsInSection:section]) {
        // search for next responder in this section
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
        responder = [self responderInCell:cell];
        if (nil != responder) {
            // found it
            break;
        }
        // else move to next cell
        ++row;
    }
    if (nil == responder) {
        // look in next section
        ++section;
        while (section < [self numberOfSectionsInTableView:self.tableView]) {
            for (NSInteger row = 0; row < [self tableView:self.tableView numberOfRowsInSection:section]; ++row) {
                cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                responder = [self responderInCell:cell];
                if (nil != responder) {
                    break;
                }
            }
            ++section;
        }
    }
    // if responder is still nil, return firstName
    if (nil == responder) {
        responder = [self responderInCell:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]];
    }
    return responder;
}

- (UIResponder *)previousTextFieldResponder
{
    UIResponder *responder = nil;
    UITableViewCell *cell = [self cellForView:(UIView *)[self.tableView findFirstResponder]];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSInteger row = indexPath.row - 1;
    NSInteger section = indexPath.section;
    while (section >= 0) {
        for (NSInteger rowIndex = row; rowIndex >= 0; --rowIndex) {
            cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:section]];
            responder = [self responderInCell:cell];
            if (nil != responder) {
                break;
            }
        }
        --section;
        row = ([self tableView:self.tableView numberOfRowsInSection:section] - 1);
    }
    if (nil == responder) {
        responder = [self responderInCell:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]];
    }
    return responder;
}

- (UIResponder *)responderInCell:(UITableViewCell *)cell
{
    if (nil == cell) {
        return nil;
    }
    // else
    UIResponder *responder = nil;
    for (UIView *aView in cell.contentView.subviews) {
        if ([aView isKindOfClass:[UIResponder class]]) {
            responder = aView;
            break;
        }
    }
    return responder;
}

@end

@implementation WMPatientDetailViewController

@synthesize patient=_patient;

- (NSDateFormatter *)dateOfBirthDateFormatter
{
    if (nil == _dateOfBirthDateFormatter) {
        _dateOfBirthDateFormatter = [[NSDateFormatter alloc] init];
        [_dateOfBirthDateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [_dateOfBirthDateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
    return _dateOfBirthDateFormatter;
}

#pragma mark - Memory

- (void)clearDataCache
{
    [super clearDataCache];
    _patient = nil;
    _person = nil;
}

#pragma mark - Views

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // set state
        self.modalInPopover = YES;
        self.preferredContentSize = CGSizeMake(320.0, 460.0);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // configure tableView
    [self.tableView registerClass:[WMTextFieldTableViewCell class] forCellReuseIdentifier:@"TextCell"];
    [self.tableView registerClass:[WMValue1TableViewCell class] forCellReuseIdentifier:@"ValueCell"];
    [self.tableView registerClass:[WMSegmentControlTableViewCell class] forCellReuseIdentifier:@"SwitchCell"];
    // configure date picker
    _datePickerView.maximumDate = [NSDate date];
    _datePickerView.date = self.userDefaultsManager.lastDateOfBirth;
    // we want to support cancel, so make sure we have an undoManager
    if (nil == self.managedObjectContext.undoManager) {
        self.managedObjectContext.undoManager = [[NSUndoManager alloc] init];
        _removeUndoManagerWhenDone = YES;
    }
    [self.managedObjectContext.undoManager beginUndoGrouping];
    // acquire patient - creating local and back end
    if (_newPatientFlag) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        __weak __typeof(&*self)weakSelf = self;
        [self.appDelegate.navigationCoordinator createPatient:self.managedObjectContext completionHandler:^(NSError *error, id object) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            if (error) {
                [WMUtilities logError:error];
            } else {
                NSParameterAssert([object isKindOfClass:[WMPatient class]]);
                _patient = object;
            }
        }];
    } else {
        _patient = super.patient;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUIFromPatient];
    [self updateUIForDataChange];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

#pragma mark - Core

- (NSString *)cellReuseIdentifier:(NSIndexPath *)indexPath
{
    NSString *cellReuseIdentifier = nil;
    switch (indexPath.section) {
        case 0: {
            // patient data
            switch (indexPath.row) {
                case 0: {
                    // contact detail
                    cellReuseIdentifier = @"ValueCell";
                    break;
                }
                case 1: {
                    // gender
                    cellReuseIdentifier = @"SwitchCell";
                    break;
                }
                case 2: {
                    // DOB
                    cellReuseIdentifier = @"TextCell";
                    break;
                }
                case 3: {
                    // SSN
                    cellReuseIdentifier = @"TextCell";
                    break;
                }
            }
            break;
        }
        case 1: {
            // ids
            cellReuseIdentifier = @"ValueCell";
            break;
        }
    }
    return cellReuseIdentifier;
}

- (UITextField *)dobTextField
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    return (UITextField *)[self responderInCell:cell];
}

- (UITextField *)ssnTextField
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    return (UITextField *)[self responderInCell:cell];
}

- (WMPersonEditorViewController *)personEditorViewController
{
    WMPersonEditorViewController *personEditorViewController = [[WMPersonEditorViewController alloc] initWithNibName:@"WMPersonEditorViewController" bundle:nil];
    personEditorViewController.delegate = self;
    return personEditorViewController;
}

- (WMIdListViewController *)idListViewController
{
    WMIdListViewController *idListViewController = [[WMIdListViewController alloc] initWithNibName:@"WMIdListViewController" bundle:nil];
    idListViewController.delegate = self;
    return idListViewController;
}

#pragma mark - BaseViewController

- (WMPerson *)person
{
    if (nil == _person) {
        _person = _patient.person;
        if (nil == _person) {
            _person = [WMPerson MR_createInContext:self.managedObjectContext];
        }
    }
    return _person;
}

#pragma mark - Actions

- (IBAction)previousNextAction:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    UIResponder *responder = ((segmentedControl.selectedSegmentIndex == 1) ? [self nextTextFieldResponder]:[self previousTextFieldResponder]);
    if (nil == responder) {
        [[self.view findFirstResponder] resignFirstResponder];
    } else {
        [responder becomeFirstResponder];
    }
}

- (IBAction)genderChangedAction:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSString *genderCode = @"N";
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            genderCode = @"M";
            break;
        case 1:
            genderCode = @"F";
            break;
        case 2:
            genderCode = @"U";
            break;
    }
    self.patient.gender = genderCode;
    [self updateUIForDataChange];
}

- (IBAction)dateOfBirthChangedValueAction:(id)sender
{
    self.dobTextField.text = [NSDateFormatter localizedStringFromDate:self.datePickerView.date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
}

- (IBAction)dismissDatePickerAction:(id)sender
{
    [self.view endEditing:YES];
}

- (IBAction)cancelAction:(id)sender
{
    [self.view endEditing:YES];
    // delete patient if canceling a new patient
    __weak __typeof(&*self)weakSelf = self;
    dispatch_block_t block = ^{
        if (weakSelf.managedObjectContext.undoManager.groupingLevel > 0) {
            [weakSelf.managedObjectContext.undoManager endUndoGrouping];
            if (weakSelf.managedObjectContext.undoManager.canUndo) {
                // this should undo the insert of new person
                [weakSelf.managedObjectContext.undoManager undoNestedGroup];
            }
        }
        if (_removeUndoManagerWhenDone) {
            weakSelf.managedObjectContext.undoManager = nil;
        }
        [weakSelf.delegate patientDetailViewControllerDidCancelUpdate:weakSelf];
    };
    if (_newPatientFlag) {
        [self.appDelegate.navigationCoordinator deletePatient:_patient completionHandler:block];
    } else {
        block();
    }
}

- (IBAction)saveAction:(id)sender
{
    [self.view endEditing:YES];
    [self performSelector:@selector(delayedSaveAction:) withObject:sender afterDelay:0.0];
}

- (IBAction)delayedSaveAction:(id)sender
{
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
    }
    if (_removeUndoManagerWhenDone) {
        self.managedObjectContext.undoManager = nil;
    }
    // associate
    if (nil == _patient.person) {
        _patient.person = _person;
    }
    // save local
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak __typeof(&*self)weakSelf = self;
    [self.managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        // update back end
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
        WMPatient *patient = weakSelf.patient;
        NSParameterAssert(patient.ffUrl);
        [ffm updatePatient:patient ff:ff completionHandler:^(NSError *error) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf.delegate patientDetailViewControllerDidUpdatePatient:weakSelf];
        }];
    }];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.dobTextField == textField) {
        // update date picker
        if (nil != self.patient.dateOfBirth) {
            self.datePickerView.date = self.patient.dateOfBirth;
        }
    }
}

// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // update model from text
    if (textField == self.ssnTextField) {
        self.patient.ssn = textField.text;
    }
    [self performSelector:@selector(updateTitle) withObject:nil afterDelay:0.0];
    [self performSelector:@selector(updateUIForDataChange) withObject:nil afterDelay:0.0];
}

// called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [[self nextTextFieldResponder] becomeFirstResponder];
    return YES;
}

#pragma mark - PersonEditorViewControllerDelegate

- (void)personEditorViewController:(WMPersonEditorViewController *)viewController didEditPerson:(WMPerson *)person
{
    [self.navigationController popViewControllerAnimated:YES];
    // update back end now
    _person = person;
    if (nil == _patient.person) {
        _patient.person = _person;
    }
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    if (nil == _person.ffUrl) {
        [ffm createPerson:person ff:ff completionHandler:^(NSError *error) {
            if (error) {
                [WMUtilities logError:error];
            }
        }];
    }
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void)personEditorViewControllerDidCancel:(WMPersonEditorViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - IdListViewControllerDelegate

- (id<idSource>)idSource
{
    return self.patient;
}

- (void)idListViewControllerDidFinish:(WMIdListViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    // update back end
    
}

- (void)idListViewControllerDidCancel:(WMIdListViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0: {
            // Patient Information - no selection
            WMPersonEditorViewController *personEditorViewController = self.personEditorViewController;
            personEditorViewController.person = self.person;
            [self.navigationController pushViewController:personEditorViewController animated:YES];
            break;
        }
        case 1: {
            // EMR/Insurance Identification
            WMIdListViewController *idListViewController = self.idListViewController;
            [self.navigationController pushViewController:idListViewController animated:YES];
            break;
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

// fixed font style. use custom view (UILabel) if you want something different
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    switch (section) {
        case 0: {
            title = @"Patient Information";
            break;
        }
        case 1: {
            title = @"EMR/Record Identifiers";
            break;
        }
    }
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    switch (section) {
        case 0: {
            count = 4;
            break;
        }
        case 1: {
            count = 1;
            break;
        }
    }
    return count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [self cellReuseIdentifier:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if ([cell isKindOfClass:[WMTextFieldTableViewCell class]]) {
        WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
        myCell.textField.delegate = self;
        myCell.textField.inputAccessoryView = self.inputAccessoryToolbar;
    } else if ([cell isKindOfClass:[WMSegmentControlTableViewCell class]]) {
        WMSegmentControlTableViewCell *myCell = (WMSegmentControlTableViewCell *)cell;
        [myCell configureWithItems:@[@"Male", @"Female"] target:self action:@selector(genderChangedAction:)];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    WMPatient *patient = self.patient;
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    // contact detail
                    cell.textLabel.text = @"Contact Details";
                    cell.detailTextLabel.text = self.person.lastNameFirstName;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
                case 1: {
                    // gender
                    WMSegmentControlTableViewCell *myCell = (WMSegmentControlTableViewCell *)cell;
                    myCell.segmentedControl.selectedSegmentIndex = patient.genderIndex;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    break;
                }
                case 2: {
                    // dob
                    WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
                    [myCell updateWithLabelText:@"DOB"
                                      valueText:[NSDateFormatter localizedStringFromDate:patient.dateOfBirth dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle]
                                    valuePrompt:@"Date of Birth"];
                    myCell.textField.inputView = self.datePickerView;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    break;
                }
                case 3: {
                    // ssn
                    WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
                    [myCell updateWithLabelText:@"SSN"
                                      valueText:patient.ssn
                                    valuePrompt:@"SSN (optional)"];
                    myCell.textField.inputView = nil;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    break;
                }
            }
            break;
        }
        case 1: {
            switch (indexPath.row) {
                case 0: {
                    // identifier
                    cell.textLabel.text = @"Idenfiers";
                    NSString *string = ([patient.ids count] == 1 ? @"Identifier":@"Idenfiers");
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@", [patient.ids count], string];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
            }
            break;
        }
    }
}

@end
