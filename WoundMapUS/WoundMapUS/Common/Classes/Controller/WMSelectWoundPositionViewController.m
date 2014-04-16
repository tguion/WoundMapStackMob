//
//  WMSelectWoundPositionViewController.m
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 1/14/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//

#import "WMSelectWoundPositionViewController.h"
#import "WMSimpleTableViewController.h"
#import "MBProgressHUD.h"
#import "WMWound.h"
#import "WMWoundLocation.h"
#import "WMWoundLocationValue.h"
#import "WMWoundPosition.h"
#import "WMWoundLocationPositionJoin.h"
#import "WMWoundPositionValue.h"
#import "WMDefinition.h"
#import "WMUserDefaultsManager.h"
#import "WMFatFractal.h"
#import "WMUtilities.h"

@interface WMSelectWoundPositionViewController () <SimpleTableViewControllerDelegate>
@property (strong, nonatomic) WMWoundLocationPositionJoin *selectedJoin;
@property (readonly, nonatomic) WMSimpleTableViewController *simpleTableViewController;
@property (weak, nonatomic) UISegmentedControl *clinicalCommonSegmentedControl;
@end

@interface WMSelectWoundPositionViewController (PrivateMethods)

@end

@implementation WMSelectWoundPositionViewController (PrivateMethods)

@end

@implementation WMSelectWoundPositionViewController

@synthesize wound=_wound;

- (WMWoundLocation *)woundLocation
{
    if (nil == _woundLocation) {
        _woundLocation = self.wound.locationValue.location;
    }
    return _woundLocation;
}

- (WMSimpleTableViewController *)simpleTableViewController
{
    WMSimpleTableViewController *simpleTableViewController = [[WMSimpleTableViewController alloc] initWithNibName:@"WMSimpleTableViewController" bundle:nil];
    simpleTableViewController.delegate = self;
    simpleTableViewController.allowMultipleSelection = YES;
    return simpleTableViewController;
}

#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.managedObjectContext.undoManager beginUndoGrouping];
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Add code to clean up any of your own resources that are no longer necessary.
}

#pragma mark - Back end

- (void)deleteWoundPositionValueFromBackEnd:(WMWoundPositionValue *)woundPositionValue
{
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    NSError *error = nil;
    [ff grabBagRemove:woundPositionValue from:self.wound grabBagName:WMWoundRelationships.positionValues error:&error];
    if (error) {
        [WMUtilities logError:error];
    }
    [ff deleteObj:woundPositionValue error:&error];
    if (error) {
        [WMUtilities logError:error];
    }
}

#pragma mark - BaseViewController

- (void)clearDataCache
{
    [super clearDataCache];
    _wound = nil;
    _woundLocation = nil;
    _selectedJoin = nil;
}

#pragma mark - BuildGroupViewController

- (BOOL)shouldShowToolbar
{
    return YES;
}

- (void)updateToolbarItems
{
    NSInteger woundPositionCount = self.wound.woundPositionCount;
    BOOL hasClearBarButtonItem = NO;
    NSMutableArray *items = [self.toolbarItems mutableCopy];
    if (nil == items) {
        items = [[NSMutableArray alloc] initWithCapacity:4];
    }
    if ([items count] > 0) {
        // toobar items already created
        hasClearBarButtonItem = [[[items objectAtIndex:0] title] isEqualToString:@"Clear"];
        if (hasClearBarButtonItem && woundPositionCount == 0) {
            [items removeObjectAtIndex:0];
        } else if (!hasClearBarButtonItem && woundPositionCount > 0) {
            [items insertObject:[[UIBarButtonItem alloc] initWithTitle:@"Clear"
                                                                 style:UIBarButtonItemStyleBordered
                                                                target:self
                                                                action:@selector(clearAction:)] atIndex:0];
        }
    } else {
        // create toobar items
        if (woundPositionCount > 0) {
            [items addObject:[[UIBarButtonItem alloc] initWithTitle:@"Clear"
                                                              style:UIBarButtonItemStyleBordered
                                                             target:self
                                                             action:@selector(clearAction:)]];
        }
        [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:nil]];
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Clinical", @"Common", nil]];
        segmentedControl.selectedSegmentIndex = ([self.userDefaultsManager.woundPositionTermKey isEqualToString:@"title"] ? 0:1);
        [segmentedControl addTarget:self action:@selector(clinicalCommonValueChangedAction:) forControlEvents:UIControlEventValueChanged];
        [items addObject:[[UIBarButtonItem alloc] initWithCustomView:segmentedControl]];
        self.clinicalCommonSegmentedControl = segmentedControl;
        [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:nil]];
    }
    self.toolbarItems = items;
}

- (void)updateUIForDataChange
{
    [super updateUIForDataChange];
    self.title = self.woundLocation.title;
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)updateUIForSearch
{
    [super updateUIForSearch];
    self.title = @"Search Definitions";
}

- (id)valueForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup
{
    WMWoundLocationPositionJoin *join = (WMWoundLocationPositionJoin *)assessmentGroup;
    WMWoundPositionValue *woundPositionValue = [self.wound woundPositionValueForJoin:join
                                                                              create:NO
                                                                               value:nil];
    if (nil == woundPositionValue) {
        return nil;
    }
    // else
    if (join.groupValueTypeCode == GroupValueTypeCodeValue1NavigateToOptions) {
        return [[[self.wound woundPositionValuesForJoin:join value:nil] valueForKeyPath:@"woundPosition.title"] componentsJoinedByString:@", "];
    }
    // else
    return woundPositionValue.value;
}

- (void)updateAssessmentGroup:(id<AssessmentGroup>)assessmentGroup withValue:(id)value
{
    WMWoundLocationPositionJoin *join = (WMWoundLocationPositionJoin *)assessmentGroup;
    BOOL createValue = (nil != value);
    if ([value isKindOfClass:[NSString class]]) {
        createValue = [value length] > 0;
    }
    WMWoundPositionValue *woundPositionValue = [self.wound woundPositionValueForJoin:join
                                                                              create:createValue
                                                                               value:nil];
    if (createValue) {
        woundPositionValue.value = value;
        woundPositionValue.woundPosition = [join positionAtIndex:[value intValue]];
    } else if (nil != woundPositionValue) {
        // update back end
        if (woundPositionValue.ffUrl) {
            [self deleteWoundPositionValueFromBackEnd:woundPositionValue];
        }
        [self.wound removePositionValuesObject:woundPositionValue];
        [self.managedObjectContext deleteObject:woundPositionValue];
    }
    [self updateUIForDataChange];
}

#pragma mark - Actions

- (IBAction)clearAction:(id)sender
{
    NSArray *values = [self.wound.positionValues allObjects];
    for (WMWoundPositionValue *woundPositionValue in values) {
        // update back end
        // update back end
        if (woundPositionValue.ffUrl) {
            [self deleteWoundPositionValueFromBackEnd:woundPositionValue];
        }
        [self.wound removePositionValuesObject:woundPositionValue];
        [self.managedObjectContext deleteObject:woundPositionValue];
    }
    [self updateUIForDataChange];
    [self.tableView reloadData];
}

- (void)delayedRestoreSearchDisplayController
{
    // make sure we have a searchDisplayController
    if (nil == self.searchDisplayController) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
        [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
#pragma clang diagnostic pop
    }
}

- (IBAction)clinicalCommonValueChangedAction:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    self.userDefaultsManager.woundPositionTermKey = (segmentedControl.selectedSegmentIndex == 0 ? @"title":@"commonTitle");
    [self.tableView reloadData];
    [self performSelector:@selector(delayedRestoreSearchDisplayController) withObject:nil afterDelay:0.0];
}

- (IBAction)saveAction:(id)sender
{
    [super saveAction:sender];
    // update back end
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    NSError *error = nil;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    for (WMWoundPositionValue *woundPositionValue in self.wound.positionValues) {
        if (woundPositionValue.ffUrl) {
            [ff updateObj:woundPositionValue error:&error];
        } else {
            [ff createObj:woundPositionValue atUri:[NSString stringWithFormat:@"/%@", [WMWoundPositionValue entityName]] error:&error];
            [ff grabBagAdd:woundPositionValue to:self.wound grabBagName:WMWoundRelationships.positionValues error:&error];
        }
        if (error) {
            [WMUtilities logError:error];
        }
    }
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    [self.delegate selectWoundPositionViewControllerDidSave:self];
}

- (IBAction)cancelAction:(id)sender
{
    [super cancelAction:sender];
    [self.delegate selectWoundPositionViewControllerDidCancel:self];
}

#pragma mark - SimpleTableViewControllerDelegate

- (NSString *)navigationTitle
{
    return [[self.selectedJoin.positions anyObject] prompt];
}

- (NSArray *)valuesForDisplay
{
    return [self.selectedJoin.sortedPositions valueForKeyPath:@"commonTitle"];
}

- (NSArray *)selectedValuesForDisplay
{
    NSMutableSet *positions = [[self.wound.positionValues valueForKey:@"woundPosition"] mutableCopy];
    [positions intersectSet:self.selectedJoin.positions];
    return [[[positions allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"commonTitle" ascending:YES]]] valueForKey:@"commonTitle"];
}

- (void)simpleTableViewController:(WMSimpleTableViewController *)viewController didSelectValues:(NSArray *)selectedValues
{
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
    }
    NSMutableSet *positions = [[self.wound.positionValues valueForKey:@"woundPosition"] mutableCopy];
    [positions intersectSet:self.selectedJoin.positions];
    NSMutableSet *updatedPositions = [[NSMutableSet alloc] initWithCapacity:16];
    for (NSString *displayValue in selectedValues) {
        WMWoundPosition *position = [WMWoundPosition woundPositionForCommonTitle:displayValue
                                                                          create:NO
                                                            managedObjectContext:self.managedObjectContext];
        [updatedPositions addObject:position];
    }
    // determine woundPositionValues to delete
    [positions minusSet:updatedPositions];
    for (WMWoundPosition *woundPosition in positions) {
        WMWoundPositionValue *woundPositionValue = [self.wound woundPositionValueForWoundPosition:woundPosition
                                                                                           create:NO
                                                                                            value:nil];
        // update back end
        if (woundPositionValue.ffUrl) {
            [self deleteWoundPositionValueFromBackEnd:woundPositionValue];
        }
        [self.wound removePositionValuesObject:woundPositionValue];
        [self.managedObjectContext deleteObject:woundPositionValue];
    }
    // add value
    for (WMWoundPosition *woundPosition in updatedPositions) {
        WMWoundPositionValue *woundPositionValue = [self.wound woundPositionValueForWoundPosition:woundPosition
                                                                                           create:YES
                                                                                            value:nil];
        [self.wound addPositionValuesObject:woundPositionValue];
    }
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
}

- (void)simpleTableViewControllerDidCancel:(WMSimpleTableViewController *)viewController
{
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
        if (self.managedObjectContext.undoManager.canUndo) {
            [self.managedObjectContext.undoManager undoNestedGroup];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSearchActive) {
        return YES;
    }
    // else
    WMWoundLocationPositionJoin *join = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return join.groupValueTypeCode == GroupValueTypeCodeValue1NavigateToOptions;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSearchActive) {
        return indexPath;
    }
    // else
    WMWoundLocationPositionJoin *join = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return (join.groupValueTypeCode == GroupValueTypeCodeValue1NavigateToOptions ? indexPath:nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    if (self.isSearchActive) {
        return;
    }
    // else
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedJoin = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.managedObjectContext.undoManager beginUndoGrouping];
    [self.navigationController pushViewController:self.simpleTableViewController animated:YES];
}

#pragma mark - UITableViewDataSource

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    WMAssessmentTableViewCell *myCell = (WMAssessmentTableViewCell *)cell;
    myCell.showSecondaryOptionsArray = (self.clinicalCommonSegmentedControl.selectedSegmentIndex == 1);
    [super configureCell:cell atIndexPath:indexPath];
}

#pragma mark - NSFetchedResultsController

- (NSString *)fetchedResultsControllerEntityName
{
    return (self.isSearchActive ? @"WMDefinition":@"WMWoundLocationPositionJoin");
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
    NSPredicate *predicate = nil;
    if (self.isSearchActive) {
        if ([self.searchDisplayController.searchBar.text length] > 0) {
            if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == 0) {
                predicate = [WMDefinition predicateForSearchInput:self.searchDisplayController.searchBar.text section:WoundPUMPScopeWoundPosition];
            } else {
                predicate = [WMDefinition predicateForSearchInput:self.searchDisplayController.searchBar.text];
            }
        }
    } else {
        predicate = [NSPredicate predicateWithFormat:@"location == %@", self.woundLocation];
    }
    return predicate;
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
    NSArray *sortDescriptors = nil;
    if (self.isSearchActive) {
        sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"term" ascending:YES]];
    } else {
        sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES]];
    }
    return sortDescriptors;
}

@end
