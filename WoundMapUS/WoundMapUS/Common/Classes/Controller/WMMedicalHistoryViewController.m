//
//  WMMedicalHistoryViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 4/8/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
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
    // make sure we have a group
    WMPatient *patient = self.patient;
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    _medicalHistoryGroup = [WMMedicalHistoryGroup activeMedicalHistoryGroup:patient];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    __weak __typeof(&*self)weakSelf = self;
    WMErrorCallback errorCallback = ^(NSError *error) {
        if (error) {
            [WMUtilities logError:error];
        }
        // we want to support cancel, so make sure we have an undoManager
        if (nil == managedObjectContext.undoManager) {
            managedObjectContext.undoManager = [[NSUndoManager alloc] init];
            _removeUndoManagerWhenDone = YES;
        }
        [managedObjectContext.undoManager beginUndoGrouping];
    };
    if (nil == _medicalHistoryGroup) {
        [MBProgressHUD showHUDAddedToViewController:self animated:YES];
        _medicalHistoryGroup = [WMMedicalHistoryGroup medicalHistoryGroupForPatient:patient];
        _medicalHistoryGroupWasCreated = YES;
        FFHttpMethodCompletion createCompletionHandler = ^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            }
            [managedObjectContext MR_saveToPersistentStoreAndWait];
            [ff queueGrabBagAddItemAtUri:_medicalHistoryGroup.ffUrl toObjAtUri:patient.ffUrl grabBagName:WMPatientRelationships.medicalHistoryGroups];
            [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        };
        [ff createObj:_medicalHistoryGroup
                atUri:[NSString stringWithFormat:@"/%@", [WMMedicalHistoryGroup entityName]]
           onComplete:createCompletionHandler onOffline:createCompletionHandler];
    } else {
        [ffm updateGrabBags:@[WMMedicalHistoryGroupRelationships.values] aggregator:_medicalHistoryGroup ff:ff completionHandler:errorCallback];
    }
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
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext.undoManager.groupingLevel > 0) {
        [managedObjectContext.undoManager endUndoGrouping];
        if (managedObjectContext.undoManager.canUndo) {
            // this should undo the insert of new person
            [managedObjectContext.undoManager undoNestedGroup];
        }
    }
    if (_removeUndoManagerWhenDone) {
        managedObjectContext.undoManager = nil;
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
        [managedObjectContext MR_deleteObjects:@[_medicalHistoryGroup]];
    } else {
        [self.delegate medicalHistoryViewControllerDidCancel:self];
    }
}

- (IBAction)doneAction:(id)sender
{
    [self.view endEditing:YES];
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext.undoManager.groupingLevel > 0) {
        [managedObjectContext.undoManager endUndoGrouping];
    }
    if (_removeUndoManagerWhenDone) {
        managedObjectContext.undoManager = nil;
    }
    // indicate that patient was changed on device
    [self patientNavigationDataChangedOnDevice];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    // update back end
    [MBProgressHUD showHUDAddedToViewController:self animated:YES];
    NSArray *medicalHistoryValues = [self.fetchedResultsController fetchedObjects];
    __weak __typeof(&*self)weakSelf = self;
    NSParameterAssert([_medicalHistoryGroup.ffUrl length]);
    __block NSInteger counter = 0;
    FFHttpMethodCompletion block = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        if (counter == 0 || --counter == 0) {
            ffm.postSynchronizationEvents = YES;
            [managedObjectContext MR_saveToPersistentStoreAndWait];
            [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
            [weakSelf.delegate medicalHistoryViewControllerDidFinish:weakSelf];
        }
    };
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    FFHttpMethodCompletion createOnComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        WMMedicalHistoryValue *medicalHistoryValue = (WMMedicalHistoryValue *)object;
        [ff queueGrabBagAddItemAtUri:medicalHistoryValue.ffUrl toObjAtUri:_medicalHistoryGroup.ffUrl grabBagName:WMMedicalHistoryGroupRelationships.values];
        block(error, object, response);
    };
    for (WMMedicalHistoryValue *medicalHistoryValue in medicalHistoryValues) {
        if (medicalHistoryValue.ffUrl) {
            ++counter;
            [ff updateObj:medicalHistoryValue onComplete:block onOffline:block];
        } else {
            ++counter;
            [ff createObj:medicalHistoryValue
                    atUri:[NSString stringWithFormat:@"/%@", [WMMedicalHistoryValue entityName]]
               onComplete:createOnComplete onOffline:createOnComplete];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([WMMedicalHistoryItem MR_countOfEntitiesWithContext:self.managedObjectContext] == 0) {
        return 0;
    }
    // else
    return [super numberOfSectionsInTableView:tableView];
}

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

- (NSArray *)backendSeedEntityNames
{
    return @[]; // WMMedicalHistoryItem fetched on sign in
}

- (NSArray *)ffQuery
{
    if (_medicalHistoryGroupWasCreated) {
        return nil;
    }
    // else
    return @[[NSString stringWithFormat:@"%@/%@", self.medicalHistoryGroup.ffUrl, WMMedicalHistoryGroupRelationships.values]];
}

- (id)aggregator
{
    return _medicalHistoryGroup;
}

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
