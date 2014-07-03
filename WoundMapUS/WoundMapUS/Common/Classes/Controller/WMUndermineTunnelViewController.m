//
//  WMUndermineTunnelViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/23/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMUndermineTunnelViewController.h"
#import "WMAdjustAlpaView.h"
#import "MBProgressHUD.h"
#import "WMWoundMeasurementGroup.h"
#import "WMWoundMeasurementValue.h"
#import "WMWoundMeasurement.h"
#import "WMWoundPhoto.h"
#import "WMDefinition.h"
#import "WMUndermineTunnelContainerView.h"
#import "UIView+Custom.h"
#import "WMFatFractal.h"
#import "WMUtilities.h"

@interface WMUndermineTunnelViewController ()

@property (nonatomic) BOOL removeUndoManagerWhenDone;

@property (strong, nonatomic) WMWoundMeasurement *woundMeasurement;

@property (strong, nonatomic) WMWoundMeasurementValue *valueUnderEdit;          // value being editing
@property (readonly, nonatomic) NSNumber *fromOClockValue;
@property (readonly, nonatomic) NSNumber *toOClockValue;
@property (readonly, nonatomic) BOOL isEditingTunneling;                        // YES if editing WMWoundMeasurementTunnelValue

@property (nonatomic) BOOL didCancel;                                           // YES if user tapped cancel

@property (strong, nonatomic) IBOutlet WMUndermineTunnelContainerView *pickerViewContainer;
@property (strong, nonatomic) IBOutlet UIToolbar *inputAccessoryToolbar;        // Dismiss
@property (weak, nonatomic) IBOutlet UIPickerView *fromPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *toPickerView;
@property (weak, nonatomic) IBOutlet UITextField *depthTextField;
@property (weak, nonatomic) WMAdjustAlpaView *adjustAlpaView;
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;

@end

@interface WMUndermineTunnelViewController (PrivateMethods)
- (void)showUndermineTunnelPickerView;
- (void)hideUndermineTunnelPickerView;
- (void)configureForUndermining;
- (void)configureForTunneling;
- (BOOL)isUnderminingForIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isAddingUndermineTunnelValue:(NSIndexPath *)indexPath;
- (void)updateCurrentUndermineTunnelValues;
@end

@implementation WMUndermineTunnelViewController (PrivateMethods)

- (void)showUndermineTunnelPickerView
{
    if (self.isEditingTunneling) {
        [self configureForTunneling];
    } else {
        [self configureForUndermining];
        [self.toPickerView selectRow:[self.toOClockValue intValue] inComponent:0 animated:YES];
    }
    [self.fromPickerView selectRow:[self.fromOClockValue intValue] inComponent:0 animated:YES];
    self.depthTextField.text = self.valueUnderEdit.value;
}

- (void)hideUndermineTunnelPickerView
{
    [[self.view findFirstResponder] resignFirstResponder];
}

- (void)configureForUndermining
{
    self.pickerViewContainer.state = UndermineTunnelContainerViewState_Undermine;
}

- (void)configureForTunneling
{
    self.pickerViewContainer.state = UndermineTunnelContainerViewState_Tunnel;
}

- (BOOL)isUnderminingForIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == 0);
}

- (BOOL)isAddingUndermineTunnelValue:(NSIndexPath *)indexPath
{
    return [self tableView:self.tableView numberOfRowsInSection:indexPath.section] == (indexPath.row + 1);
}

- (void)updateCurrentUndermineTunnelValues
{
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:self.valueUnderEdit];
    indexPath = [self indexPathFetchedResultsControllerToTable:indexPath];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    // update model
    NSString *valueText = nil;
    if (self.isEditingTunneling) {
        WMWoundMeasurementValue *tunnelValue = (WMWoundMeasurementValue *)self.valueUnderEdit;
        tunnelValue.fromOClockValue = @([self.fromPickerView selectedRowInComponent:0]);
        tunnelValue.value = self.depthTextField.text;
        valueText = tunnelValue.valueText;
    } else {
        WMWoundMeasurementValue *undermineValue = (WMWoundMeasurementValue *)self.valueUnderEdit;
        undermineValue.fromOClockValue = @([self.fromPickerView selectedRowInComponent:0]);
        undermineValue.toOClockValue = @([self.toPickerView selectedRowInComponent:0]);
        undermineValue.value = self.depthTextField.text;
        valueText = undermineValue.valueText;
    }
    // update view
    cell.detailTextLabel.text = valueText;
}

@end

@implementation WMUndermineTunnelViewController

#pragma mark - View

- (void)dealloc
{
    _fromPickerView.delegate = nil;
    _fromPickerView.dataSource = nil;
    _toPickerView.delegate = nil;
    _toPickerView.dataSource = nil;
    _depthTextField.delegate = nil;
    _inputTextField.delegate = nil;

}

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
    self.title = @"Undermining & Tunneling";
    if (_showCancelButton) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                              target:self
                                                                                              action:@selector(cancelAction:)];
    } else {
        // we want to support cancel, so make sure we have an undoManager
        if (nil == self.managedObjectContext.undoManager) {
            self.managedObjectContext.undoManager = [[NSUndoManager alloc] init];
            _removeUndoManagerWhenDone = YES;
        }
        [self.managedObjectContext.undoManager beginUndoGrouping];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                           target:self
                                                                                           action:@selector(saveAction:)];
    [self.view addSubview:_inputTextField];
    CGRect frame = _inputTextField.frame;
    frame.origin.x = -CGRectGetWidth(frame);
    frame.origin.y = -44.0;
    _inputTextField.frame = frame;
    _inputTextField.inputView = self.pickerViewContainer;
    _inputTextField.inputAccessoryView = self.inputAccessoryToolbar;
    self.depthTextField.inputAccessoryView = self.inputAccessoryToolbar;
    if (self.isIPadIdiom) {
        self.depthTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    }
    NSMutableArray *items = [self.inputAccessoryToolbar.items mutableCopy];
    UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    aLabel.font = [UIFont systemFontOfSize:15.0];
    aLabel.backgroundColor = [UIColor clearColor];
    aLabel.text = @"Depth:";
    [aLabel sizeToFit];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aLabel];
    [items insertObject:barButtonItem atIndex:1];
    aLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    aLabel.font = [UIFont systemFontOfSize:15.0];
    aLabel.backgroundColor = [UIColor clearColor];
    aLabel.text = @"cm";
    [aLabel sizeToFit];
    barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aLabel];
    [items insertObject:barButtonItem atIndex:3];
    self.inputAccessoryToolbar.items = items;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tableView.backgroundColor = [UIColor whiteColor];
    UIImage *image = self.woundMeasurementGroup.woundPhoto.thumbnail;
    if (image) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.tableView.backgroundView = imageView;
        self.tableView.backgroundView.alpha = kInitialBackgroundImageAlpha;
        [self.navigationController setToolbarHidden:YES animated:YES];
        // place WMAdjustAlpaView
        if (nil == _adjustAlpaView) {
            // keep out of way of tableview
            CGFloat height = CGRectGetHeight(self.view.bounds);
            CGRect aFrame = CGRectMake(0.0, ceilf(1.0 * height/3.0) + 88.0, 32.0, ceilf(1.0 * height/3.0));
            WMAdjustAlpaView *adjustAlpaView = [[WMAdjustAlpaView alloc] initWithFrame:aFrame delegate:self];
            [self.view addSubview:adjustAlpaView];
            [adjustAlpaView performSelector:@selector(flashViewAlpha) withObject:nil afterDelay:0.0];
            _adjustAlpaView = adjustAlpaView;
        }
    }
    [self.tableView setEditing:YES animated:NO];
    self.tableView.allowsSelectionDuringEditing = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // dismiss responder
    UIResponder *responder = [self.view findFirstResponder];
    if (nil == responder && self.depthTextField.isFirstResponder) {
        responder = self.depthTextField;
    }
    [responder resignFirstResponder];
}

#pragma mark - Core

- (WMWoundMeasurement *)woundMeasurement
{
    if (nil == _woundMeasurement) {
        _woundMeasurement = [WMWoundMeasurement underminingTunnelingWoundMeasurement:self.managedObjectContext];
    }
    return _woundMeasurement;
}

- (BOOL)isEditingTunneling
{
    return self.valueUnderEdit.isTunnelingValue;
}

- (NSNumber *)fromOClockValue
{
    return self.valueUnderEdit.fromOClockValue;
}

- (NSNumber *)toOClockValue
{
    return self.valueUnderEdit.toOClockValue;
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Add code to clean up any of your own resources that are no longer necessary.
}

#pragma mark - Actions

- (IBAction)cancelAction:(id)sender
{
	_didCancel = YES;
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
        if (self.managedObjectContext.undoManager.canUndo) {
            [self.managedObjectContext.undoManager undoNestedGroup];
        }
    }
    if (_removeUndoManagerWhenDone) {
        self.managedObjectContext.undoManager = nil;
    }
	[self.delegate undermineTunnelViewControllerDidCancel:self];
}

- (void)delayedSaveAction:(id)sender
{
    [self.delegate undermineTunnelViewControllerDidDone:self];
}

- (IBAction)saveAction:(id)sender
{
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
    }
    if (_removeUndoManagerWhenDone) {
        self.managedObjectContext.undoManager = nil;
    }
    if (self.depthTextField.isFirstResponder) {
        [self.depthTextField resignFirstResponder];
        [self updateCurrentUndermineTunnelValues];
    } else {
        [[self.view findFirstResponder] resignFirstResponder];
    }
    // handle back end
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMWoundMeasurementGroup *woundMeasurementGroup = self.woundMeasurementGroup;
    __block NSInteger counter = 0;
    __weak __typeof(&*self)weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    dispatch_block_t block = ^{
        if (_saveToStoreOnSave) {
            [[woundMeasurementGroup managedObjectContext] MR_saveToPersistentStoreAndWait];
        }
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:NO];
        // delay the execution to allow updates to self
        [weakSelf performSelector:@selector(delayedSaveAction:) withObject:sender afterDelay:0.0];
    };
    FFHttpMethodCompletion completionHandler = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        if (counter == 0 || --counter == 0) {
            block();
        }
    };
    FFHttpMethodCompletion createCompletionHandler = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        [ff grabBagAddItemAtFfUrl:[object valueForKey:WMWoundMeasurementValueAttributes.ffUrl]
                     toObjAtFfUrl:woundMeasurementGroup.ffUrl
                      grabBagName:WMWoundMeasurementGroupRelationships.values
                       onComplete:completionHandler];
    };
    // update back end now
    for (WMWoundMeasurementValue *value in woundMeasurementGroup.values) {
        ++counter;
        if (value.ffUrl) {
            [ff updateObj:value onComplete:completionHandler
                onOffline:completionHandler];
        } else {
            [ff createObj:value
                    atUri:[NSString stringWithFormat:@"/%@", [WMWoundMeasurementValue entityName]]
               onComplete:createCompletionHandler
                onOffline:createCompletionHandler];
        }
    }
    ++counter;
    [ff updateObj:woundMeasurementGroup
       onComplete:completionHandler
        onOffline:completionHandler];
}

- (IBAction)pickerViewChangedValueAction:(id)sender
{
    [self updateCurrentUndermineTunnelValues];
}

- (IBAction)dismissAction:(id)sender
{
    UIResponder *firstResponder = [self.view findFirstResponder];
    if (nil == firstResponder && self.depthTextField.isFirstResponder) {
        firstResponder = self.depthTextField;
    }
    [firstResponder resignFirstResponder];
}

#pragma mark - AdjustAlpaViewDelegate

- (CGFloat)initialAlpha
{
    return  kInitialBackgroundImageAlpha;
}

- (void)adjustAlpaView:(WMAdjustAlpaView *)adjustAlpaView didUpdateAlpha:(CGFloat)alpha
{
    self.tableView.backgroundView.alpha = alpha;
}

#pragma mark - UITextFieldDelegate

// DEBUG became first responder
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"depthTextField didBegin: %@", textField == self.depthTextField ? @"YES":@"NO");
}

// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self performSelector:@selector(updateCurrentUndermineTunnelValues) withObject:nil afterDelay:0.0];
}

#pragma mark - UIPickerViewDelegate

// returns width of column and height of row for each component.
//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component;
//- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component;

// these methods return either a plain NSString, a NSAttributedString, or a view (e.g UILabel) to display the row for the component.
// for the view versions, we cache any hidden and thus unused views and pass them back for reuse.
// If you return back a different object, the old one will be released. the view will be centered in the row rect
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = nil;
    if (row == 0) {
        title = @"12:00";
    } else {
        title = [NSString stringWithFormat:@"%02ld:00", (long)row];
    }
    return title;
}

//- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component NS_AVAILABLE_IOS(6_0); // attributed title is favored if both methods are implemented
//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view;

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self updateCurrentUndermineTunnelValues];
}

#pragma mark - UIPickerViewDataSource

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return (nil == self.managedObjectContext ? 0:12);
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // check if we are adding
    BOOL addingFlag = [self isAddingUndermineTunnelValue:indexPath];
    if (addingFlag) {
        [self insertUndermineTunnelInstanceForIndexPath:indexPath];
    } else {
        indexPath = [self indexPathTableToFetchedResultsController:indexPath];
        self.valueUnderEdit = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    [self resetForEdit];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isAddingUndermineTunnelValue:indexPath]) {
        return UITableViewCellEditingStyleInsert;
    }
    // else
    return UITableViewCellEditingStyleDelete;
}

// Controls whether the background is indented while editing.  If not implemented, the default is YES.
// This is unrelated to the indentation level below.  This method only applies to grouped style table views.
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (nil == self.managedObjectContext) {
        return 0;
    }
    // else
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sectionTitle == %@", @"Undermining"];
    NSInteger undermineCount = [[[self.fetchedResultsController fetchedObjects] filteredArrayUsingPredicate:predicate] count];
    predicate = [NSPredicate predicateWithFormat:@"sectionTitle == %@", @"Tunneling"];
    NSInteger tunnelingCount = [[[self.fetchedResultsController fetchedObjects] filteredArrayUsingPredicate:predicate] count];
    if (section == 0) {
        return undermineCount + 1;
    }
    // else
    return (tunnelingCount + 1);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.isSearchActive) {
        return nil;
    }
    // else
    return (0 == section ? @"Undermining":@"Tunneling");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL underminingFlag = [self isUnderminingForIndexPath:indexPath];
    NSString *cellIdentifier =[NSString stringWithFormat:@"%@-%ld", underminingFlag ? @"UnderminingCell":@"TunnelingCell", (long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    BOOL underminingFlag = [self isUnderminingForIndexPath:indexPath];
    BOOL addingFlag = [self isAddingUndermineTunnelValue:indexPath];
    if (addingFlag) {
        cell.textLabel.text = (underminingFlag ? @"Add Undermining":@"Add Tunneling");
        cell.detailTextLabel.text = nil;
    } else {
        WMWoundMeasurementValue *value = [self.fetchedResultsController objectAtIndexPath:[self indexPathTableToFetchedResultsController:indexPath]];
        cell.textLabel.text = value.labelText;
        cell.detailTextLabel.text = value.valueText;
    }
}

// Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Allows the reorder accessory view to optionally be shown for a particular row.
// By default, the reorder control will be shown only if the datasource implements -tableView:moveRowAtIndexPath:toIndexPath:
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        // update the model first
        [self insertUndermineTunnelInstanceForIndexPath:indexPath];
        // make the UITextField becomeFirstResponder will bring up inputView
        [self resetForEdit];
    } else if (editingStyle == UITableViewCellEditingStyleDelete) {
        // update model
        WMWoundMeasurementValue *value = [self.fetchedResultsController objectAtIndexPath:[self indexPathTableToFetchedResultsController:indexPath]];
        [self.woundMeasurementGroup removeValuesObject:value];
        [self.managedObjectContext deleteObject:value];
        // no need for back end update
        NSError *error = nil;
        if (![self.fetchedResultsController performFetch:&error]) {
            abort();
        }
        // update table
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

- (void)insertUndermineTunnelInstanceForIndexPath:(NSIndexPath *)indexPath
{
    // update the model first
    BOOL underminingFlag = [self isUnderminingForIndexPath:indexPath];
    WMWoundMeasurementValue *value = nil;
    if (underminingFlag) {
        value = [WMWoundMeasurementValue undermineWoundMeasurementValue:self.managedObjectContext];
        value.sortRank = @(self.woundMeasurementGroup.tunnelingValueCount);
    } else {
        value = [WMWoundMeasurementValue tunnelWoundMeasurementValue:self.managedObjectContext];
        value.sortRank = @(self.woundMeasurementGroup.underminingValueCount);
    }
    value.woundMeasurement = self.woundMeasurement;
    [self.woundMeasurementGroup addValuesObject:value];
    self.valueUnderEdit = value;
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        abort();
    }
    // update table
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
}

- (void)resetForEdit
{
    // save state and show picker(s)
    [self showUndermineTunnelPickerView];
    // make the UITextField becomeFirstResponder will bring up inputView
    [self.inputTextField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];
}

#pragma mark - NSFetchedResultsController

- (NSString *)fetchedResultsControllerEntityName
{
    return (self.isSearchActive ? @"WMDefinition":@"WMWoundMeasurementValue");
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
    NSPredicate *predicate = nil;
    if (self.isSearchActive) {
        if ([self.searchDisplayController.searchBar.text length] > 0) {
            if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == 0) {
                predicate = [WMDefinition predicateForSearchInput:self.searchDisplayController.searchBar.text section:WoundPUMPScopeWoundUandT];
            } else {
                predicate = [WMDefinition predicateForSearchInput:self.searchDisplayController.searchBar.text];
            }
        }
    } else {
        predicate = [NSPredicate predicateWithFormat:@"woundMeasurement == %@ AND group == %@ AND (woundMeasurementValueType == %d OR woundMeasurementValueType == %d)", self.woundMeasurement, self.woundMeasurementGroup, kWoundMeasurementValueTypeTunnel,
                     kWoundMeasurementValueTypeUndermine];
    }
    return predicate;
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
    NSArray *sortDescriptors = nil;
    if (self.isSearchActive) {
        sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"term" ascending:YES]];
    } else {
        sortDescriptors = [NSArray arrayWithObjects:
                           [NSSortDescriptor sortDescriptorWithKey:@"sectionTitle" ascending:NO],
                           [NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES],
                           nil];
    }
    return sortDescriptors;
}

/**
 If this key path is not the same as that specified by the first sort descriptor in fetchRequest, they must generate the same relative orderings.
 For example, the first sort descriptor in fetchRequest might specify the key for a persistent property;
 sectionNameKeyPath might specify a key for a transient property derived from the persistent property.
 */
- (NSString *)fetchedResultsControllerSectionNameKeyPath
{
    if (self.isSearchActive) {
        return nil;
    }
    // else
	return @"sectionTitle";
}

#pragma mark - IndexPath

- (NSIndexPath *)indexPathTableToFetchedResultsController:(NSIndexPath *)indexPath
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sectionTitle == %@", @"Undermining"];
    NSInteger undermineCount = [[[self.fetchedResultsController fetchedObjects] filteredArrayUsingPredicate:predicate] count];
    if (undermineCount == 0) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    }
	return indexPath;
}

- (NSIndexPath *)indexPathFetchedResultsControllerToTable:(NSIndexPath *)indexPath
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sectionTitle == %@", @"Undermining"];
    NSInteger undermineCount = [[[self.fetchedResultsController fetchedObjects] filteredArrayUsingPredicate:predicate] count];
    if (undermineCount == 0) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:1];
    }
	return indexPath;
}

- (NSUInteger)sectionIndexFetchedResultsControllerToTable:(NSUInteger)sectionIndex
{
	return sectionIndex;
}

- (NSUInteger)sectionIndexTableToFetchedResultsController:(NSUInteger)sectionIndex
{
	return sectionIndex;
}

@end
