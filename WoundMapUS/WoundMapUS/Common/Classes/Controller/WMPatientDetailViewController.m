//
//  WMPatientDetailViewController.m
//  WoundCarePhoto
//
//  Created by Todd Guion on 5/29/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import "WMPatientDetailViewController.h"
#import "WMPatient.h"
#import "WMPerson.h"
#import "WMNavigationTrack.h"
#import "WMNavigationStage.h"
//#import "WCWound+Custom.h"
//#import "WCWoundType+Custom.h"
//#import "WCWoundPhoto+Custom.h"
//#import "WCBradenScale+Custom.h"
//#import "WCWoundTreatmentGroup+Custom.h"
//#import "WCMedicationGroup+Custom.h"
//#import "WCDeviceGroup+Custom.h"
//#import "WCSkinAssessmentGroup+Custom.h"
//#import "WCCarePlanGroup+Custom.h"
//#import "WMProgressViewHUD.h"
//#import "PrintConfiguration.h"
#import "WMUtilities.h"
//#import "PatientManager.h"
#import "WMUserDefaultsManager.h"
//#import "NavigationCoordinator.h"
#import "UIView+Custom.h"
#import "WCAppDelegate.h"
#import "StackMob.h"

@interface WMPatientDetailViewController ()

// data
@property (strong, nonatomic) WMPatient *patient;
@property (strong, nonatomic) WMPerson *person;
@property (strong, nonatomic) NSArray *sortedWounds;
// state
@property (nonatomic) BOOL willCancelFlag;                                          // cancel action started
// UI
@property (strong, nonatomic) IBOutlet UIToolbar *inputAccessoryToolbar;
@property (strong, nonatomic) IBOutlet UITableViewCell *firstNameCell;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (strong, nonatomic) IBOutlet UITableViewCell *lastNameCell;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (strong, nonatomic) IBOutlet UITableViewCell *genderCell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSegmentedControl;
@property (strong, nonatomic) IBOutlet UITableViewCell *dobCell;
@property (weak, nonatomic) IBOutlet UITextField *dobTextField;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePickerView;
@property (strong, nonatomic) IBOutlet UITableViewCell *identifierCell;
@property (weak, nonatomic) IBOutlet UITextField *identifierField;
@property (strong, nonatomic) NSDateFormatter *dateOfBirthDateFormatter;

//@property (readonly, nonatomic) WoundDetailViewController *woundDetailViewController;

- (IBAction)cancelAction:(id)sender;
- (IBAction)saveAction:(id)sender;
- (IBAction)dateOfBirthChangedValueAction:(id)sender;
- (IBAction)dismissDatePickerAction:(id)sender;
- (IBAction)previousNextAction:(id)sender;

@end

@interface WMPatientDetailViewController (PrivateMethods)

//- (void)navigateToWoundDetailWithNewWoundFlag:(BOOL)newWoundFlag;
- (void)updateTitle;
- (void)updateModelFromView;
- (void)updateUIFromPatient;
- (void)updateUIForDataChange;
- (UIResponder *)nextTextFieldResponder;
- (UIResponder *)previousTextFieldResponder;
- (UIResponder *)responderInCell:(UITableViewCell *)cell;

@end

@implementation WMPatientDetailViewController (PrivateMethods)

//- (void)navigateToWoundDetailWithNewWoundFlag:(BOOL)newWoundFlag
//{
//    WoundDetailViewController *woundDetailViewController = self.woundDetailViewController;
//    woundDetailViewController.newWoundFlag = newWoundFlag;
//    [self.navigationController pushViewController:woundDetailViewController animated:YES];
//}

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

- (void)updateModelFromView
{
    WMPatient *patient = self.patient;
    WMPerson *person = self.person;
    person.nameGiven = self.firstNameField.text;
    person.nameFamily = self.lastNameField.text;
    patient.dateOfBirth = self.datePickerView.date;
//    self.dobTextField.text = [self.dateOfBirthDateFormatter stringFromDate:self.patient.dateOfBirth];
    // TODO figure out how to allow more than one patient id
//    self.patient.identifierEMR = self.identifierField.text;
    // save dob for next patient
    self.userDefaultsManager.lastDateOfBirth = self.patient.dateOfBirth;
}

// update any view not table view cell
- (void)updateUIFromPatient
{
    [self updateTitle];
    WMPatient *patient = self.patient;
    if (nil != patient.dateOfBirth) {
        self.datePickerView.date = patient.dateOfBirth;
    }
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
            // move to next cell
            break;
        }
        // else
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
            if (nil != responder) {
                break;
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
        if (nil != responder) {
            break;
        }
        // else
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
    return (UIResponder *)[[cell.contentView.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tag == 1000"]] lastObject];
}

@end

@implementation WMPatientDetailViewController

@synthesize patient=_patient;

- (void)setNewPatientFlag:(BOOL)newPatientFlag
{
    if (_newPatientFlag == newPatientFlag) {
        return;
    }
    // else
    [self willChangeValueForKey:@"newPatientFlag"];
    _newPatientFlag = newPatientFlag;
    [self didChangeValueForKey:@"newPatientFlag"];
    if (newPatientFlag) {
        // dump any cache
        _sortedWounds = nil;
    }
}

//- (NSArray *)sortedWounds
//{
//    if (nil == _sortedWounds) {
//        _sortedWounds = [WCWound sortedWounds:self.managedObjectContext];
//    }
//    return _sortedWounds;
//}

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Add code to clean up any of your own resources that are no longer necessary.
    _sortedWounds = nil;
    _dateOfBirthDateFormatter = nil;
}

- (void)clearDataCache
{
    [super clearDataCache];
    _newPatientFlag = NO;
    _patient = nil;
    _sortedWounds = nil;
}

#pragma mark - Views

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // set state
        self.modalInPopover = YES;
//        self.preferredContentSize = CGSizeMake(320.0, 460.0 + [self.patient.wounds count] * 44.0);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // configure input
    self.firstNameField.inputAccessoryView = self.inputAccessoryToolbar;
    self.lastNameField.inputAccessoryView = self.inputAccessoryToolbar;
    self.identifierField.inputAccessoryView = self.inputAccessoryToolbar;
    self.dobTextField.inputAccessoryView = self.inputAccessoryToolbar;
    self.dobTextField.inputView = self.datePickerView;
    self.firstNameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.lastNameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    // allow editing
    [self.tableView setEditing:YES animated:NO];
    // configure date picker
    _datePickerView.maximumDate = [NSDate date];
    _datePickerView.date = self.userDefaultsManager.lastDateOfBirth;
    [self.managedObjectContext.undoManager beginUndoGrouping];
    // confirm that we have a clean moc
    NSAssert1(![self.managedObjectContext hasChanges], @"self.managedObjectContext has changes", self.managedObjectContext);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUIFromPatient];
    [self updateUIForDataChange];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
    self.willCancelFlag = NO;
}

#pragma mark - Core

#pragma mark - BaseViewController

- (WMPatient *)patient
{
    if (nil == _patient) {
        if (_newPatientFlag) {
            _patient = [WMPatient instanceWithManagedObjectContext:self.managedObjectContext persistentStore:self.store];
        } else {
            _patient = super.patient;
        }
    }
    return _patient;
}

- (void)setPatient:(WMPatient *)patient
{
    self.appDelegate.patient = patient;
}

- (WMPerson *)person
{
    if (nil == _person) {
        WMPatient *patient = self.patient;
        _person = patient.person;
        if (nil == _person) {
            // must save patient
            NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
            NSError *error = nil;
            [managedObjectContext saveAndWait:&error];
            [WMUtilities logError:error];
            _person = [WMPerson instanceWithManagedObjectContext:managedObjectContext persistentStore:self.store];
            patient.person = _person;
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
    [[self.view findFirstResponder] resignFirstResponder];
}

- (IBAction)cancelAction:(id)sender
{
    _willCancelFlag = YES;
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
        if (self.managedObjectContext.undoManager.canUndo) {
            // this should undo the insert of new patient
            [self.managedObjectContext.undoManager undoNestedGroup];
        }
    }
    [self.delegate patientDetailViewControllerDidCancelUpdate:self];
}

// NOTE: delegate would typically set self.patient to appDelegate.patient and save
- (IBAction)saveAction:(id)sender
{
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
    }
    [[self.view findFirstResponder] resignFirstResponder];
    // do not allow any further input
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateModelFromView) object:nil];
    [self updateModelFromView];
    [self.delegate patientDetailViewControllerDidUpdatePatient:self];
}

#pragma mark - WoundDetailViewControllerDelegate

//- (void)woundDetailViewControllerDidUpdateWound:(WoundDetailViewController *)viewController
//{
//    [self.navigationController popViewControllerAnimated:YES];
//    [self.documentManager saveDocument:self.document];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.sortedWounds indexOfObject:viewController.wound] inSection:2];
//    // dump our cache
//    _sortedWounds = nil;
//    // reload table cell
//    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    // update title
//    [self updateTitle];
//    // clear
//    [viewController clearAllReferences];
//}
//
//- (void)woundDetailViewControllerDidCancelUpdate:(WoundDetailViewController *)viewController
//{
//    if (viewController.isNewWound) {
//        [self.navigationCoordinator deleteWound:viewController.wound];
//        self.wound = [self.navigationCoordinator selectLastWound];
//    }
//    [self.documentManager saveDocument:viewController.document];
//    [self.navigationController popViewControllerAnimated:YES];
//    // dump our cache
//    _sortedWounds = nil;
//    // reload table
//    [self.tableView reloadData];
//    // clear
//    [viewController clearAllReferences];
//}
//
//- (void)woundDetailViewController:(WoundDetailViewController *)viewController didDeleteWound:(WCWound *)wound
//{
//    [self.navigationCoordinator deleteWound:wound];
//    self.wound = [self.navigationCoordinator selectLastWound];
//    [self.documentManager saveDocument:viewController.document];
//    [self.navigationController popViewControllerAnimated:YES];
//    // dump our cache
//    _sortedWounds = nil;
//    // reload table
//    [self.tableView reloadData];
//    // clear
//    [viewController clearAllReferences];
//}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.dobTextField == textField) {
        // update date picker
        if (nil != self.patient.dateOfBirth) {
            self.datePickerView.date = self.patient.dateOfBirth;
        }
    }
//    UITableViewCell *cell = [self cellForView:textField];
//    self.indexPathToScrollIntoView = [self.tableView indexPathForCell:cell];
//    [self.tableView scrollToRowAtIndexPath:self.indexPathToScrollIntoView atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (_willCancelFlag) {
        return;
    }
    // else
    [self performSelector:@selector(updateModelFromView) withObject:nil afterDelay:0.0];
    [self performSelector:@selector(updateTitle) withObject:nil afterDelay:0.0];
    [self performSelector:@selector(updateUIForDataChange) withObject:nil afterDelay:0.0];
}

// called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [[self nextTextFieldResponder] becomeFirstResponder];
    return YES;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 || indexPath.section == 3 || indexPath.section == 4) {
        return YES;
    }
    // else
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0: {
            // Patient Information - no selection
            break;
        }
        case 1: {
            // EMR/Insurance Identification - no selection
            break;
        }
//        case 2: {
//            // Wounds
//            BOOL newWoundFlag = NO;
//            if (indexPath.row == [self.sortedWounds count]) {
//                // add wound
//                self.wound = [WCWound createWoundForPatient:self.patient];
//                newWoundFlag = YES;
//            } else {
//                // existing wound
//                self.wound = [self.sortedWounds objectAtIndex:indexPath.row];
//            }
//            [self navigateToWoundDetailWithNewWoundFlag:newWoundFlag];
//            break;
//        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        // wounds
        return (indexPath.row == [self.sortedWounds count] ? UITableViewCellEditingStyleInsert:UITableViewCellEditingStyleNone);
    }
    // else
    return UITableViewCellEditingStyleNone;
}

// Controls whether the background is indented while editing.  If not implemented, the default is YES.
// This is unrelated to the indentation level below.  This method only applies to grouped style table views.
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - UITableViewDataSource

// NOTE: 2013.07.03 limiting to only 3 sections - assessments and sharing sections moved to primary UI

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (self.hideAddWoundFlag ? 2:3);
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
            title = @"EMR/Record Identifier";
            break;
        }
        case 2: {
            title = @"Wounds";
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
        case 2: {
            count = ([self.sortedWounds count] + 1);
            break;
        }
    }
    return count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = nil;
    UITableViewCell *cell = nil;
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    // contact information cell
                    cell = self.firstNameCell;
                    break;
                }
                case 1: {
                    // contact information cell
                    cell = self.lastNameCell;
                    break;
                }
                case 3: {
                    // gender cell
                    cell = self.genderCell;
                    break;
                }
                case 2: {
                    // contact information cell
                    cell = self.dobCell;
                    break;
                }
            }
            break;
        }
        case 1: {
            switch (indexPath.row) {
                case 0: {
                    // identifier
                    cell = self.identifierCell;
                    break;
                }
            }
            break;
        }
        case 2: {
            if (indexPath.row == [self.sortedWounds count]) {
                // cell to add wound
                cellIdentifier = @"AddWoundCell";
                cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            } else {
                // existing wound
                cellIdentifier = @"WoundCell";
                cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
                    cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
            }
            break;
        }
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    WMPatient *patient = self.patient;
    WMPerson *person = self.person;
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    // first name
                    self.firstNameField.text = person.nameGiven;
                    break;
                }
                case 1: {
                    // last name
                    self.lastNameField.text = person.nameFamily;
                    break;
                }
                case 3: {
                    // gender
                    self.genderSegmentedControl.selectedSegmentIndex = patient.genderIndex;
                    break;
                }
                case 2: {
                    // dob
                    if (nil != patient.dateOfBirth) {
                        self.dobTextField.text = [NSDateFormatter localizedStringFromDate:patient.dateOfBirth dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
                    };
                    break;
                }
            }
            break;
        }
//        case 1: {
//            switch (indexPath.row) {
//                case 0: {
//                    // identifier
//                    self.identifierField.text = self.patient.identifierEMR;
//                    break;
//                }
//            }
//            break;
//        }
//        case 2: {
//            // Wounds section
//            if (indexPath.row == [self.sortedWounds count]) {
//                // cell to add wound
//                cell.textLabel.text = @"Add Wound";
//            } else {
//                // existing wound
//                WCWound *wound = [self.sortedWounds objectAtIndex:indexPath.row];
//                cell.textLabel.text = wound.name;
//                cell.detailTextLabel.text = wound.woundType.titleForDisplay;
//            }
//            break;
//        }
    }
}

//// Allows the reorder accessory view to optionally be shown for a particular row.
//// By default, the reorder control will be shown only if the datasource implements -tableView:moveRowAtIndexPath:toIndexPath:
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return NO;
//}
//
//// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    self.wound = [WCWound createWoundForPatient:self.patient];
//    [self navigateToWoundDetailWithNewWoundFlag:YES];
//}


@end
