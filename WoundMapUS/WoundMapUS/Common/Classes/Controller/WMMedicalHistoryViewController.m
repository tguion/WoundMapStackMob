//
//  WMMedicalHistoryViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 4/8/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMMedicalHistoryViewController.h"
#import "WMNoteViewController.h"
#import "WMSwitchTableViewCell.h"
#import "WMValue1TableViewCell.h"
#import "MBProgressHUD.h"
#import "WMPatient.h"
#import "WMMedicalHistoryGroup.h"
#import "WMMedicalHistoryItem.h"
#import "WMMedicalHistoryValue.h"
#import "WMNavigationCoordinator.h"
#import "WMFatFractal.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"

@interface WMMedicalHistoryViewController () <NoteViewControllerDelegate>

@property (nonatomic) BOOL removeUndoManagerWhenDone;
@property (nonatomic) BOOL medicalHistoryGroupWasCreated;
@property (strong, nonatomic) WMMedicalHistoryGroup *medicalHistoryGroup;
@property (readonly, nonatomic) WMNoteViewController *noteViewController;

@end

@implementation WMMedicalHistoryViewController

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
    self.title = @"Medical History";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneAction:)];
    [self.tableView registerClass:[WMSwitchTableViewCell class] forCellReuseIdentifier:@"SwitchCell"];
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

- (WMPatient *)patient
{
    return self.delegate.patient;
}

- (NSManagedObjectContext *)managedObjectContext
{
    return [self.patient managedObjectContext];
}

- (WMMedicalHistoryGroup *)medicalHistoryGroup
{
    if (nil == _medicalHistoryGroup) {
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        _medicalHistoryGroup = [WMMedicalHistoryGroup activeMedicalHistoryGroup:self.patient groupCreatedCallback:^(NSError *error, id object) {
            _medicalHistoryGroupWasCreated = YES;
            [ff createObj:object
                    atUri:[NSString stringWithFormat:@"/%@", [WMMedicalHistoryGroup entityName]]
               onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                   NSParameterAssert([object isKindOfClass:[WMMedicalHistoryGroup class]]);
               }];
        }];
    }
    return _medicalHistoryGroup;
}

- (BOOL)indexPathIsOther:(NSIndexPath *)indexPath
{
    WMMedicalHistoryValue *medicalHistoryValue = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return medicalHistoryValue.medicalHistoryItem.valueTypeCodeValue == GroupValueTypeCodeNavigateToNote;
}

- (NSString *)cellReuseIdentifier:(NSIndexPath *)indexPath
{
    return ([self indexPathIsOther:indexPath] ? @"ValueCell":@"SwitchCell");
}

- (WMNoteViewController *)noteViewController
{
    WMNoteViewController *noteViewController = [[WMNoteViewController alloc] initWithNibName:@"WMNoteViewController" bundle:nil];
    noteViewController.delegate = self;
    return noteViewController;
}

#pragma mark - Actions

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
    // delete from back end
    __weak __typeof(&*self)weakSelf = self;
    FFHttpMethodCompletion block = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        [weakSelf.delegate medicalHistoryViewControllerDidCancel:weakSelf];
    };
    if (_medicalHistoryGroupWasCreated) {
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        [ff deleteObj:_medicalHistoryGroup onComplete:block];
    } else {
        [self.delegate medicalHistoryViewControllerDidCancel:self];
    }
}

- (IBAction)doneAction:(id)sender
{
    [self.view endEditing:YES];
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
    }
    if (_removeUndoManagerWhenDone) {
        self.managedObjectContext.undoManager = nil;
    }
    // save locally
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    [managedObjectContext MR_saveToPersistentStoreAndWait];
    // update back end
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSArray *medicalHistoryValues = [self.fetchedResultsController fetchedObjects];
    __weak __typeof(&*self)weakSelf = self;
    NSParameterAssert([self.medicalHistoryGroup.ffUrl length]);
    __block NSInteger callbackCount = 0;
    NSInteger callbacksTotal = [medicalHistoryValues count];
    FFHttpMethodCompletion block = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        ++callbackCount;
        if (callbackCount == callbacksTotal) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
            [managedObjectContext MR_saveToPersistentStoreAndWait];
            [weakSelf.delegate medicalHistoryViewControllerDidFinish:weakSelf];
        }
    };
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    for (WMMedicalHistoryValue *medicalHistoryValue in medicalHistoryValues) {
        if (medicalHistoryValue.ffUrl) {
            [ff updateObj:medicalHistoryValue onComplete:block];
        } else {
            [ff createObj:medicalHistoryValue
                    atUri:[NSString stringWithFormat:@"/%@", [WMMedicalHistoryValue entityName]]
               onComplete:block];
        }
    }
}

- (IBAction)medicalHistoryValueChangedAction:(id)sender
{
    UISwitch *aSwitch = (UISwitch *)sender;
    NSInteger row = (aSwitch.tag - 1000);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    WMMedicalHistoryValue *medicalHistoryValue = [self.fetchedResultsController objectAtIndexPath:indexPath];
    medicalHistoryValue.value = [NSString stringWithFormat:@"%d", aSwitch.isOn];
}

#pragma mark - BaseViewController

- (NSString *)ffQuery
{
    return [NSString stringWithFormat:@"/%@/%@/%@", [WMPatient entityName], [self.patient.ffUrl lastPathComponent], [WMMedicalHistoryGroup entityName]];
}

#pragma mark - NoteViewControllerDelegate

- (NSString *)note
{
    WMMedicalHistoryValue *medicalHistoryValue = [[self.fetchedResultsController fetchedObjects] lastObject];
    return medicalHistoryValue.value;
}

- (NSString *)label
{
    return @"Other History";;
}

- (void)noteViewController:(WMNoteViewController *)viewController didUpdateNote:(NSString *)note
{
    WMMedicalHistoryValue *medicalHistoryValue = [[self.fetchedResultsController fetchedObjects] lastObject];
    medicalHistoryValue.value = note;
    [self.navigationController popViewControllerAnimated:YES];
    [self.tableView reloadRowsAtIndexPaths:@[[self.fetchedResultsController indexPathForObject:medicalHistoryValue]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)noteViewControllerDidCancel:(WMNoteViewController *)viewController withNote:(NSString *)note
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self indexPathIsOther:indexPath];
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:self.noteViewController animated:YES];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [self cellReuseIdentifier:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    // medical history panel
    WMMedicalHistoryValue *medicalHistoryValue = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([self indexPathIsOther:indexPath]) {
        cell.textLabel.text = medicalHistoryValue.medicalHistoryItem.title;
        cell.detailTextLabel.text = medicalHistoryValue.value;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        WMSwitchTableViewCell *myCell = (WMSwitchTableViewCell *)cell;
        cell.tag = (1000 + indexPath.row);
        [myCell updateWithLabelText:medicalHistoryValue.medicalHistoryItem.title value:[medicalHistoryValue.value boolValue] target:self action:@selector(medicalHistoryValueChangedAction:) tag:(1000 + indexPath.row)];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

#pragma mark - NSFetchedResultsController

- (NSString *)fetchedResultsControllerEntityName
{
    return [WMMedicalHistoryValue entityName];
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
    return [NSPredicate predicateWithFormat:@"medicalHistoryGroup == %@", self.medicalHistoryGroup];
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
    return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"medicalHistoryItem.sortRank" ascending:YES]];
}

@end
