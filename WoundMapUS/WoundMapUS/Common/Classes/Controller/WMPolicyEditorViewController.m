//
//  WMPolicyEditorViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMPolicyEditorViewController.h"
#import "WMPolicySubnodeEditorViewController.h"
#import "MBProgressHUD.h"
#import "WMParticipant.h"
#import "WMTeam.h"
#import "WMNavigationTrack.h"
#import "WMNavigationStage.h"
#import "WMNavigationNode.h"
#import "WMNavigationStageTableViewCell.h"
#import "UIView+Custom.h"
#import "WMFatFractal.h"
#import "WMNavigationCoordinator.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"

NSString * const kEditNodeCellIdentifier = @"EditNodeCell";
NSString * const kSubnodeCellIdentifier = @"SubnodeCell";
NSString * const kChooseTrackCellIdentifier = @"ChooseTrackCell";
NSString * const kChooseStageCellIdentifier = @"ChooseStageCell";
NSString * const kReorderNodeCellIdentifier = @"ReorderNodeCell";

#define kTitleLabelTag 1000
#define kDescriptionLabelTag 1001
#define kRequiredLabelTag 1020
#define kRequiredSwitchTag 1002
#define kFrequencyLabelTag 1003
#define kFrequencyUnitTextFieldTag 1004
#define kFrequencyValueSegmentedControlTag 1005
#define kCloseLabelTag 1009
#define kCloseUnitTextFieldTag 1010
#define kCloseValueSegmentedControlTag 1011

#define kSavePolicyAlertTag 2000
#define kChangeTrackConfirmAlertTag 2001

@interface WMPolicyEditorViewController () <ChooseTrackDelegate, ChooseStageDelegate, UITextFieldDelegate, UIActionSheetDelegate>

@property (nonatomic) BOOL removeUndoManagerWhenDone;

@property (strong, nonatomic) WMNavigationTrack *navigationTrack;
@property (strong, nonatomic) WMNavigationStage *navigationStage;
@property (strong, nonatomic) NSMutableArray *sortOrdering;
@property (readonly, nonatomic) WMChooseTrackViewController *chooseTrackViewController;
@property (readonly, nonatomic) WMChooseStageViewController *chooseStageViewController;
@property (nonatomic) BOOL trackIsChanging;

@property (nonatomic) BOOL didCancel;

- (IBAction)beginEditing:(id)sender;
- (IBAction)doneEditingAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)saveAction:(id)sender;

@end

@interface WMPolicyEditorViewController (PrivateMethods)
- (BOOL)sectionIsNavigationNodeSection:(NSInteger)section;
- (void)updateNavigation;
- (void)reloadSortOrderings;
- (void)moveNodeOrdering:(NSInteger)sourceRow to:(NSInteger)destinationRow;
- (void)navigateToNavigationTracks;
- (void)navigateToNavigationStage;
- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath;
- (UILabel *)titleLabelForContentView:(UIView *)view;
- (UILabel *)descLabelForContentView:(UIView *)view;
- (UISwitch *)switchForContentView:(UIView *)view;
- (UITextField *)textFieldForContentView:(UIView *)view;
- (UISegmentedControl *)segmentedControlForContentView:(UIView *)view;
- (UITextField *)textFieldCloseForContentView:(UIView *)view;
- (UISegmentedControl *)segmentedControlCloseForContentView:(UIView *)view;
@end

@implementation WMPolicyEditorViewController (PrivateMethods)

- (BOOL)sectionIsNavigationNodeSection:(NSInteger)section
{
    return (section == 2);
}

- (void)updateNavigation
{
    if (self.tableView.isEditing) {
        self.navigationItem.leftBarButtonItems = nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditingAction:)];
    } else {
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:
                                                  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)],
                                                  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(beginEditing:)],
                                                  nil];
        if (self.managedObjectContext.hasChanges) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAction:)];
        } else {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveAction:)];
        }
    }
}

- (void)reloadSortOrderings
{
    [self.sortOrdering removeAllObjects];
    NSArray *nodes = self.fetchedResultsController.fetchedObjects;
    for (WMNavigationNode *node in nodes) {
        [self.sortOrdering addObject:[node objectID]];
    }
}

- (void)moveNodeOrdering:(NSInteger)sourceRow to:(NSInteger)destinationRow
{
    id objectID = [self.sortOrdering objectAtIndex:sourceRow];
    [self.sortOrdering removeObject:objectID];
    [self.sortOrdering insertObject:objectID atIndex:destinationRow];
}

- (void)navigateToNavigationTracks
{
    [self.navigationController pushViewController:self.chooseTrackViewController animated:YES];
}

- (void)navigateToNavigationStage
{
    [self.navigationController pushViewController:self.chooseStageViewController animated:YES];
}

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = kEditNodeCellIdentifier;
    if (indexPath.section == 0) {
        cellIdentifier = kChooseTrackCellIdentifier;
    } else if (indexPath.section == 1) {
        cellIdentifier = kChooseStageCellIdentifier;
    } else if (indexPath.section == 2) {
        indexPath = [self indexPathTableToFetchedResultsController:indexPath];
        WMNavigationNode *navigationNode = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if (self.tableView.isEditing) {
            cellIdentifier = kReorderNodeCellIdentifier;
        } else if ([navigationNode.subnodes count] > 0) {
            cellIdentifier = kSubnodeCellIdentifier;
        }
    }
    return cellIdentifier;
}

- (UILabel *)titleLabelForContentView:(UIView *)view
{
    return (UILabel *)[view viewWithTag:kTitleLabelTag];
}

- (UILabel *)descLabelForContentView:(UIView *)view
{
    return (UILabel *)[view viewWithTag:kDescriptionLabelTag];
}

- (UISwitch *)switchForContentView:(UIView *)view
{
    return (UISwitch *)[view viewWithTag:kRequiredSwitchTag];
}

- (UILabel *)labelForContentView:(UIView *)view
{
    return (UILabel *)[view viewWithTag:kFrequencyLabelTag];
}

- (UITextField *)textFieldForContentView:(UIView *)view
{
    return (UITextField *)[view viewWithTag:kFrequencyUnitTextFieldTag];
}

- (UISegmentedControl *)segmentedControlForContentView:(UIView *)view
{
    return (UISegmentedControl *)[view viewWithTag:kFrequencyValueSegmentedControlTag];
}

- (UILabel *)labelCloseForContentView:(UIView *)view
{
    return (UILabel *)[view viewWithTag:kCloseLabelTag];
}

- (UITextField *)textFieldCloseForContentView:(UIView *)view
{
    return (UITextField *)[view viewWithTag:kCloseUnitTextFieldTag];
}

- (UISegmentedControl *)segmentedControlCloseForContentView:(UIView *)view
{
    return (UISegmentedControl *)[view viewWithTag:kCloseValueSegmentedControlTag];
}

@end

@implementation WMPolicyEditorViewController

@synthesize navigationTrack=_navigationTrack, navigationStage=_navigationStage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        __weak __typeof(&*self)weakSelf = self;
        self.refreshCompletionHandler = ^{
            [weakSelf.managedObjectContext MR_saveToPersistentStoreAndWait];
        };
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Edit Policies";
    self.navigationItem.hidesBackButton = YES;
    [self updateNavigation];
    [self.tableView registerNib:[UINib nibWithNibName:kEditNodeCellIdentifier bundle:nil] forCellReuseIdentifier:kEditNodeCellIdentifier];
    // we want to support cancel, so make sure we have an undoManager
    if (nil == self.managedObjectContext.undoManager) {
        self.managedObjectContext.undoManager = [[NSUndoManager alloc] init];
        self.removeUndoManagerWhenDone = YES;
    }
    [self.managedObjectContext.undoManager beginUndoGrouping];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_trackIsChanging) {
        _trackIsChanging = NO;
        // determine if the user wants to change the active track
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Change the Track for current and future Patients?"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:@"Change Clinical Setting"
                                                        otherButtonTitles:@"No Now, Just Editing", nil];
        [actionSheet showInView:self.view];
        actionSheet.tag = kChangeTrackConfirmAlertTag;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core

- (WMNavigationTrack *)navigationTrack
{
    if (nil == _navigationTrack) {
        WMNavigationCoordinator *navigationCoordinator = self.appDelegate.navigationCoordinator;
        _navigationTrack = navigationCoordinator.navigationTrack;
    }
    return _navigationTrack;
}

- (void)setNavigationTrack:(WMNavigationTrack *)navigationTrack
{
    if (_navigationTrack == navigationTrack) {
        return;
    }
    // else
    [self willChangeValueForKey:@"navigationTrack"];
    _navigationTrack = navigationTrack;
    [self didChangeValueForKey:@"navigationTrack"];
    self.navigationStage = navigationTrack.initialStage;
}

- (WMNavigationStage *)navigationStage
{
    if (nil == _navigationStage) {
        _navigationStage = self.navigationTrack.initialStage;
    }
    return _navigationStage;
}

- (void)setNavigationStage:(WMNavigationStage *)navigationStage
{
    if (_navigationStage == navigationStage) {
        return;
    }
    // else
    [self willChangeValueForKey:@"navigationStage"];
    _navigationStage = navigationStage;
    [self didChangeValueForKey:@"navigationStage"];
}

- (void)fetchedResultsControllerDidFetch
{
    [super fetchedResultsControllerDidFetch];
    [self reloadSortOrderings];
}

- (NSMutableArray *)sortOrdering
{
    if (nil == _sortOrdering) {
        _sortOrdering = [[NSMutableArray alloc] initWithCapacity:64];
    }
    return _sortOrdering;
}

- (WMChooseTrackViewController *)chooseTrackViewController
{
    WMChooseTrackViewController *chooseTrackViewController = [[WMChooseTrackViewController alloc] initWithNibName:@"WMChooseTrackViewController" bundle:nil];
    chooseTrackViewController.delegate = self;
    return chooseTrackViewController;
}

- (WMChooseStageViewController *)chooseStageViewController
{
    WMChooseStageViewController *chooseStageViewController = [[WMChooseStageViewController alloc] initWithNibName:@"WMChooseStageViewController" bundle:nil];
    chooseStageViewController.delegate = self;
    return chooseStageViewController;
}

- (void)reorderNodesFromSortOrderings
{
    NSInteger sortRank = 0;
    for (NSManagedObjectID *objectID in self.sortOrdering) {
        WMNavigationNode *node = (WMNavigationNode *)[self.managedObjectContext objectWithID:objectID];
        node.sortRank = @(sortRank++);
    }
}

#pragma mark - BaseViewController

#pragma mark - Actions

- (IBAction)requiredSwitchValueChangedAction:(id)sender
{
    UITableViewCell *cell = [self cellForView:sender];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    indexPath = [self indexPathTableToFetchedResultsController:indexPath];
    WMNavigationNode *navigationNode = [self.fetchedResultsController objectAtIndexPath:indexPath];
    navigationNode.requiredFlag = [sender isOn];
}

- (IBAction)frequencyUnitValueChangedAction:(id)sender
{
    UITableViewCell *cell = [self cellForView:sender];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    indexPath = [self indexPathTableToFetchedResultsController:indexPath];
    WMNavigationNode *navigationNode = [self.fetchedResultsController objectAtIndexPath:indexPath];
    navigationNode.frequencyUnitValue = [sender selectedSegmentIndex] + 1;
}

- (IBAction)closeUnitValueChangedAction:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    UITableViewCell *cell = [self cellForView:sender];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    indexPath = [self indexPathTableToFetchedResultsController:indexPath];
    WMNavigationNode *navigationNode = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (segmentedControl.tag == kFrequencyValueSegmentedControlTag) {
        navigationNode.frequencyUnitValue = [sender selectedSegmentIndex] + 1;
    } else if (segmentedControl.tag == kCloseValueSegmentedControlTag) {
        navigationNode.closeUnitValue = [sender selectedSegmentIndex] + 1;
    }
}

- (IBAction)beginEditing:(id)sender
{
    [self setEditing:YES animated:YES];
    [self updateNavigation];
    [self.tableView reloadData];
}

- (IBAction)doneEditingAction:(id)sender
{
    [self reorderNodesFromSortOrderings];
    [self setEditing:NO animated:YES];
    [self updateNavigation];
    [self.tableView reloadData];
}

- (IBAction)saveAction:(id)sender
{
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
        if (_removeUndoManagerWhenDone) {
            self.managedObjectContext.undoManager = nil;
        }
    }
    [[self.view findFirstResponder] resignFirstResponder];
    if (nil == self.parentNavigationNode) {
        // show action sheet
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Save Policy"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel Changes"
                                                   destructiveButtonTitle:@"Update Current Patient"
                                                        otherButtonTitles:nil];
        actionSheet.tag = kSavePolicyAlertTag;
        [actionSheet showInView:self.view];
    } else {
        // just collect data
        [self reorderNodesFromSortOrderings];
        [self.delegate policyEditorViewControllerDidSave:self];
        _navigationTrack = nil;
        _navigationStage = nil;
    }
}

// TODO: user undo group to allow cancel from subnode editor
- (IBAction)cancelAction:(id)sender
{
    [[self.view findFirstResponder] resignFirstResponder];
    _didCancel = YES;
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
        if (_didCancel && self.managedObjectContext.undoManager.canUndo) {
            [self.managedObjectContext.undoManager undoNestedGroup];
        }
        if (_removeUndoManagerWhenDone) {
            self.managedObjectContext.undoManager = nil;
        }
    }
    [self.delegate policyEditorViewControllerDidCancel:self];
    _navigationTrack = nil;
    _navigationStage = nil;
}

#pragma mark - UIActionSheetDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kSavePolicyAlertTag) {
        if (actionSheet.cancelButtonIndex == buttonIndex) {
            [self cancelAction:nil];
            return;
        }
        // else
        [self reorderNodesFromSortOrderings];
        // update back end
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        __weak __typeof(&*self)weakSelf = self;
        __block NSInteger counter = 0;
        FFHttpMethodCompletion block = ^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            }
            --counter;
            if (counter == 0) {
                [weakSelf.managedObjectContext MR_saveToPersistentStoreAndWait];
                [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
                [weakSelf.delegate policyEditorViewControllerDidSave:weakSelf];
            }
        };
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        for (id updatedObject in self.managedObjectContext.updatedObjects) {
            if (![updatedObject respondsToSelector:@selector(ffUrl)]) {
                continue;
            }
            // else
            ++counter;
            [ff updateObj:updatedObject
               onComplete:block
                onOffline:block];
        }
        // else delete index patient
        if (actionSheet.destructiveButtonIndex == buttonIndex) {
            // update only current patient
            self.updateCurrentPatientFlag = YES;
        } else {
            // update current and future patients
            self.updateCurrentPatientFlag = NO;
        }
        _navigationTrack = nil;
        _navigationStage = nil;
    } else if (actionSheet.tag == kChangeTrackConfirmAlertTag) {
        if (actionSheet.destructiveButtonIndex == buttonIndex) {
            [self.delegate policyEditorViewController:self didChangeTrack:_navigationTrack];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    UITableViewCell *cell = [self cellForView:textField];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    indexPath = [self indexPathTableToFetchedResultsController:indexPath];
    WMNavigationNode *navigationNode = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (textField.tag == kFrequencyUnitTextFieldTag) {
        navigationNode.frequencyValue = @([textField.text integerValue]);
    } else if (textField.tag == kCloseUnitTextFieldTag) {
        navigationNode.closeValue = @([textField.text integerValue]);
    }
}

#pragma mark - PolicyEditorDelegate

- (void)policyEditorViewControllerDidSave:(WMPolicyEditorViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)policyEditorViewControllerDidCancel:(WMPolicyEditorViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)policyEditorViewController:(WMPolicyEditorViewController *)viewController didChangeTrack:(WMNavigationTrack *)navigationTrack
{
    
}

#pragma mark - ChooseTrackDelegate

- (NSPredicate *)navigationTrackPredicate
{
    return [NSPredicate predicateWithFormat:@"team == %@", self.appDelegate.participant.team];
}

- (void)chooseTrackViewController:(WMChooseTrackViewController *)viewController didChooseNavigationTrack:(WMNavigationTrack *)navigationTrack
{
    [self refetchDataForTableView];
    _trackIsChanging = (_navigationTrack != navigationTrack);
    self.navigationTrack = navigationTrack;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)chooseTrackViewControllerDidCancel:(WMChooseTrackViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ChooseStageDelegate

- (void)chooseStageViewController:(WMChooseStageViewController *)viewController didSelectNavigationStage:(WMNavigationStage *)navigationStage
{
    [self refetchDataForTableView];
    self.navigationStage = navigationStage;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)chooseStageViewControllerDidCancel:(WMChooseStageViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self sectionIsNavigationNodeSection:section]) {
        return [NSString stringWithFormat:@"Tasks for %@/%@", self.navigationTrack.title, self.navigationStage.title];
    }
    // else
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44.0;
    NSInteger section = indexPath.section;
    if (section == 2) {
        indexPath = [self indexPathTableToFetchedResultsController:indexPath];
        WMNavigationNode *navigationNode = [self.fetchedResultsController objectAtIndexPath:indexPath];
        CGFloat deltaY = 0.0;
        if (NavigationNodeFrequencyUnit_None == navigationNode.frequencyUnitValue) {
            deltaY += 56.0;
        }
        if (NavigationNodeFrequencyUnit_None == navigationNode.closeUnitValue) {
            deltaY += 56.0;
        }
        if (self.tableView.isEditing) {
            height = 44.0;
        } else if ([navigationNode.subnodes count] > 0) {
            height = 44.0;
        } else if ([navigationNode.desc length] == 0) {
            height = 190.0 - deltaY;
        } else {
            height = 224.0 - deltaY;
        }
    }
    return height;
}

// Allows customization of the editingStyle for a particular cell located at 'indexPath'.
// If not implemented, all editable cells will have UITableViewCellEditingStyleDelete set for them when the table has editing property set to YES.
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0: {
            // track
            [self navigateToNavigationTracks];
            break;
        }
        case 1: {
            // stage
            [self navigateToNavigationStage];
            break;
        }
        case 2: {
            indexPath = [self indexPathTableToFetchedResultsController:indexPath];
            WMNavigationNode *navigationNode = [self.fetchedResultsController objectAtIndexPath:indexPath];
            if ([navigationNode.subnodes count] > 0) {
                // subnodes
                WMPolicySubnodeEditorViewController *viewController = [[WMPolicySubnodeEditorViewController alloc] initWithNibName:@"WMPolicyEditorViewController" bundle:nil];
                viewController.parentNavigationNode = navigationNode;
                viewController.delegate = self;
                [self.navigationController pushViewController:viewController animated:YES];
            }
            break;
        }
    }
    [self reorderNodesFromSortOrderings];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    switch (section) {
        case 0: {
            // track
            count = 1;
            break;
        }
        case 1: {
            // stage
            count = 1;
            break;
        }
        case 2: {
            section = [self sectionIndexTableToFetchedResultsController:section];
            count = [super tableView:tableView numberOfRowsInSection:section];
            break;
        }
    }
    return count;
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < 2) {
        return NO;
    }
    // else
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [self moveNodeOrdering:sourceIndexPath.row to:destinationIndexPath.row];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [self cellIdentifierForIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell) {
        if ([cellIdentifier isEqualToString:kChooseStageCellIdentifier]) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kChooseStageCellIdentifier];
        } else if ([cellIdentifier isEqualToString:kChooseTrackCellIdentifier]) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kChooseTrackCellIdentifier];
        } else if ([cellIdentifier isEqualToString:kSubnodeCellIdentifier]) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kSubnodeCellIdentifier];
        } else if ([cellIdentifier isEqualToString:kReorderNodeCellIdentifier]) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kReorderNodeCellIdentifier];
        }
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: {
            // track
            cell.textLabel.text = @"Clinical Setting";
            cell.detailTextLabel.text = self.navigationTrack.title;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case 1: {
            // stage
            cell.textLabel.text = @"Stage";
            cell.detailTextLabel.text = self.navigationStage.title;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case 2: {
            indexPath = [self indexPathTableToFetchedResultsController:indexPath];
            WMNavigationNode *navigationNode = [self.fetchedResultsController objectAtIndexPath:indexPath];
            [self configureNavigationNodeCell:cell forNavigationNode:navigationNode];
            break;
        }
    }
}

- (void)configureNavigationNodeCell:(UITableViewCell *)cell forNavigationNode:(WMNavigationNode *)navigationNode
{
    if ([kReorderNodeCellIdentifier isEqualToString:cell.reuseIdentifier]) {
        cell.textLabel.text = navigationNode.title;
        cell.detailTextLabel.text = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return;
    }
    // else
    if ([navigationNode.subnodes count] > 0) {
        cell.textLabel.text = navigationNode.title;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu tasks", (unsigned long)[navigationNode.subnodes count]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return;
    }
    // else node - title
    [self titleLabelForContentView:cell.contentView].text = navigationNode.title;
    cell.accessoryType = UITableViewCellAccessoryNone;
    // node - desc
    [self descLabelForContentView:cell.contentView].text = navigationNode.desc;
    // node - required
    UISwitch *aSwitch = [self switchForContentView:cell.contentView];
    aSwitch.on = navigationNode.isRequired;
    if ([aSwitch.allTargets count] == 0) {
        // add target
        [aSwitch addTarget:self action:@selector(requiredSwitchValueChangedAction:) forControlEvents:UIControlEventValueChanged];
    }
    UILabel *label = [self labelForContentView:cell.contentView];
    UITextField *textField = [self textFieldForContentView:cell.contentView];
    UISegmentedControl *segmentedControl = [self segmentedControlForContentView:cell.contentView];
    if (NavigationNodeFrequencyUnit_None == navigationNode.frequencyUnitValue) {
        label.hidden = YES;
        textField.hidden = YES;
        segmentedControl.hidden = YES;
    } else {
        label.hidden = NO;
        textField.hidden = NO;
        segmentedControl.hidden = NO;
        // node - frequency unit and value
        textField.text = [navigationNode.frequencyValue stringValue];
        if (nil == textField.delegate) {
            // watch for end edit
            textField.delegate = self;
        }
        if ([segmentedControl.allTargets count] == 0) {
            // add target
            [segmentedControl addTarget:self action:@selector(frequencyUnitValueChangedAction:) forControlEvents:UIControlEventValueChanged];
        }
        if (navigationNode.frequencyUnitValue == NavigationNodeFrequencyUnit_None) {
            segmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment;
        } else {
            segmentedControl.selectedSegmentIndex = navigationNode.frequencyUnitValue - 1;
        }
    }
    label = [self labelCloseForContentView:cell.contentView];
    textField = [self textFieldCloseForContentView:cell.contentView];
    segmentedControl = [self segmentedControlCloseForContentView:cell.contentView];
    if (NavigationNodeFrequencyUnit_None == navigationNode.closeUnitValue) {
        label.hidden = YES;
        textField.hidden = YES;
        segmentedControl.hidden = YES;
    } else {
        label.hidden = NO;
        textField.hidden = NO;
        segmentedControl.hidden = NO;
        // node - close unit and value
        UITextField *textField = [self textFieldCloseForContentView:cell.contentView];
        textField.text = [navigationNode.closeValue stringValue];
        if (nil == textField.delegate) {
            // watch for end edit
            textField.delegate = self;
        }
        UISegmentedControl *segmentedControl = [self segmentedControlCloseForContentView:cell.contentView];
        if ([segmentedControl.allTargets count] == 0) {
            // add target
            [segmentedControl addTarget:self action:@selector(closeUnitValueChangedAction:) forControlEvents:UIControlEventValueChanged];
        }
        if (navigationNode.closeUnitValue == NavigationNodeFrequencyUnit_None) {
            segmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment;
        } else {
            segmentedControl.selectedSegmentIndex = navigationNode.closeUnitValue - 1;
        }
    }
    
}

#pragma mark - NSFetchedResultsController

- (NSString *)ffQuery
{
    NSString *ffQuery = nil;
    WMParticipant *participant = self.appDelegate.participant;
    if (participant.team) {
        ffQuery = [NSString stringWithFormat:@"/%@/%@/navigationTracks?depthRef=1&depthGb=2", [WMTeam entityName], [participant.team.ffUrl lastPathComponent]];
    } else {
        ffQuery = [NSString stringWithFormat:@"/%@?depthRef=1&depthGb=2", [WMNavigationTrack entityName]];
    }
    return ffQuery;
}

- (NSArray *)backendSeedEntityNames
{
    return @[[WMNavigationNode entityName]];
}

- (NSString *)fetchedResultsControllerEntityName
{
	return @"WMNavigationNode";
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
    return [NSPredicate predicateWithFormat:@"stage == %@ && parentNode == %@", self.navigationStage, self.parentNavigationNode];
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
    return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES]];
}

- (NSIndexPath *)indexPathTableToFetchedResultsController:(NSIndexPath *)indexPath
{
    return [NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 2)];
}

- (NSIndexPath *)indexPathFetchedResultsControllerToTable:(NSIndexPath *)indexPath
{
    return [NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section + 2)];
}

- (NSUInteger)sectionIndexFetchedResultsControllerToTable:(NSUInteger)sectionIndex
{
    return sectionIndex + 2;
}

- (NSUInteger)sectionIndexTableToFetchedResultsController:(NSUInteger)sectionIndex
{
    return sectionIndex - 2;
}

@end
