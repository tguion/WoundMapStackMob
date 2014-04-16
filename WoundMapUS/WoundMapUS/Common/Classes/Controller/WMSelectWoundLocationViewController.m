//
//  WMSelectWoundLocationViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMSelectWoundLocationViewController.h"
#import "WMSelectWoundPositionViewController.h"
#import "WMWound.h"
#import "WMWoundLocation.h"
#import "WMWoundLocationValue.h"
#import "WMWoundPositionValue.h"
#import "WMDefinition.h"
#import "WMDesignUtilities.h"
#import "WMFatFractal.h"
#import "WMUtilities.h"

@interface WMSelectWoundLocationViewController () <SelectWoundPositionViewControllerDelegate>

@property (readonly, nonatomic) WMSelectWoundPositionViewController *woundPositionViewController;

@end

@interface WMSelectWoundLocationViewController (PrivateMethods)
- (void)navigateToWoundPositionController:(BOOL)woundLocationChanged;
- (void)reloadRowsForSelectedWoundLocation:(WMWoundLocation *)previousWoundLocation;
@end

@implementation WMSelectWoundLocationViewController (PrivateMethods)

- (void)navigateToWoundPositionController:(BOOL)woundLocationChanged
{
    if (woundLocationChanged) {
        // remove position values from wound
        NSSet *positionValues = [self.wound.positionValues copy];
        for (WMWoundPositionValue *positionValue in positionValues) {
            // update back end
            WMFatFractal *ff = [WMFatFractal sharedInstance];
            NSError *error = nil;
            if (positionValue.ffUrl) {
                [ff grabBagRemove:positionValue
                             from:self.wound
                      grabBagName:WMWoundRelationships.positionValues
                            error:&error];
                if (error) {
                    [WMUtilities logError:error];
                }
                [ff deleteObj:positionValue error:&error];
                if (error) {
                    [WMUtilities logError:error];
                }
            }
            // handle local store
            [self.wound removePositionValuesObject:positionValue];
            [self.managedObjectContext deleteObject:positionValue];
        }
    }
    WMSelectWoundPositionViewController *woundPositionViewController = self.woundPositionViewController;
    woundPositionViewController.woundLocation = self.selectedWoundLocation;
    woundPositionViewController.wound = self.wound;
    [self.navigationController pushViewController:woundPositionViewController animated:YES];
}

- (void)reloadRowsForSelectedWoundLocation:(WMWoundLocation *)previousWoundLocation
{
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:self.selectedWoundLocation];
    NSIndexPath *currentIndexPath = nil;
    if (nil != previousWoundLocation && ![previousWoundLocation isEqual:self.selectedWoundLocation]) {
        currentIndexPath = [self.fetchedResultsController indexPathForObject:previousWoundLocation];
    }
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, currentIndexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
}

@end

@implementation WMSelectWoundLocationViewController

@synthesize wound=_wound;

- (WMSelectWoundPositionViewController *)woundPositionViewController
{
    WMSelectWoundPositionViewController *woundPositionViewController = [[WMSelectWoundPositionViewController alloc] initWithNibName:@"WMSelectWoundPositionViewController" bundle:nil];
    woundPositionViewController.delegate = self;
    woundPositionViewController.wound = _wound;
    return woundPositionViewController;
}

#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Wound Location";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelAction:)];
    [self.managedObjectContext.undoManager beginUndoGrouping];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUIForDataChange];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Add code to clean up any of your own resources that are no longer necessary.
}

#pragma mark - Core

- (WMWoundLocation *)selectedWoundLocation
{
    if (nil == _selectedWoundLocation) {
        _selectedWoundLocation = self.wound.locationValue.location;
    }
    return _selectedWoundLocation;
}

#pragma mark - BuildGroupViewController

- (id)valueForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup
{
    WMWoundLocation *woundLocation = (WMWoundLocation *)assessmentGroup;
    if (woundLocation == self.selectedWoundLocation) {
        if ([self.wound.positionValues count] > 0) {
            return self.wound.positionValuesForDisplay;
        }
        // else
        if ([self.wound.woundLocationValue length] > 0) {
            return self.wound.woundLocationValue;
        }
        // else
        return self.selectedWoundLocation;
    }
    // else
    return nil;
}

- (void)updateAssessmentGroup:(id<AssessmentGroup>)assessmentGroup withValue:(id)value
{
    BOOL createValue = (nil != value);
    if ([value isKindOfClass:[NSString class]]) {
        createValue = [value length] > 0;
    }
    WMWoundLocation *woundLocation = (WMWoundLocation *)assessmentGroup;
    if (createValue) {
        WMWoundLocation *previousWoundLocation = self.selectedWoundLocation;
        self.wound.woundLocationValue = value;
        self.selectedWoundLocation = woundLocation;
        [self reloadRowsForSelectedWoundLocation:previousWoundLocation];
    } else {
        self.wound.woundLocationValue = nil;
        self.selectedWoundLocation = nil;
    }
}

#pragma mark - BaseViewController

- (void)updateTitle
{
    // no call to super
}

- (void)clearDataCache
{
    [super clearDataCache];
    _selectedWoundLocation = nil;
    _wound = nil;
}

#pragma mark - Actions

- (IBAction)saveAction:(id)sender
{
    [super saveAction:sender];
    [self.delegate selectWoundLocationViewController:self didSelectWoundLocation:self.selectedWoundLocation];
}

- (IBAction)cancelAction:(id)sender
{
    [super cancelAction:sender];
    [self.delegate selectWoundLocationViewControllerDidCancel:self];
}

#pragma mark - SelectWoundPositionViewControllerDelegate

- (void)selectWoundPositionViewControllerDidSave:(WMSelectWoundPositionViewController *)viewController
{
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
    }
    [self.navigationController popViewControllerAnimated:YES];
    if (nil != self.selectedWoundLocation) {
        NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:self.selectedWoundLocation];
        if (nil != indexPath) {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)selectWoundPositionViewControllerDidCancel:(WMSelectWoundPositionViewController *)viewController
{
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
        if (self.managedObjectContext.undoManager.canUndo) {
            [self.managedObjectContext.undoManager undoNestedGroup];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    if (self.isSearchActive) {
        return;
    }
    // else
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WMWoundLocation *woundLocation = [self.fetchedResultsController objectAtIndexPath:indexPath];
    BOOL woundLocationChanged = (self.selectedWoundLocation != woundLocation);
    NSIndexPath *currentIndexPath = nil;
    if (nil != self.selectedWoundLocation) {
        currentIndexPath = [self.fetchedResultsController indexPathForObject:self.selectedWoundLocation];
    }
    self.selectedWoundLocation = woundLocation;
    UITextField *textField = [self textFieldForTableViewCell:[tableView cellForRowAtIndexPath:indexPath]];
    if (nil != textField) {
        [textField becomeFirstResponder];
    } else if ([self.selectedWoundLocation.positionJoins count] > 0) {
        // navigate to position controller
        [self navigateToWoundPositionController:woundLocationChanged];
    }
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    if (nil != currentIndexPath && ![currentIndexPath isEqual:indexPath]) {
        indexPaths = [NSArray arrayWithObjects:indexPath, currentIndexPath, nil];
    }
    [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self updateUIForDataChange];
}

#pragma mark - UITableViewDataSource

// fixed font style. use custom view (UILabel) if you want something different
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.isSearchActive) {
        return nil;
    }
    // else
    NSString *title = @"Common Locations";
    if (section > 0) {
        title = @"Other Locations";
    }
    return title;
}

#pragma mark - NSFetchedResultsController

- (NSString *)fetchedResultsControllerEntityName
{
    return (self.isSearchActive ? @"WMDefinition":@"WMWoundLocation");
}

- (NSString *)fetchedResultsControllerSectionNameKeyPath
{
    if (self.isSearchActive) {
        return nil;
    }
    // else
	return @"sectionTitle";
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
    NSPredicate *predicate = nil;
    if (self.isSearchActive && [self.searchDisplayController.searchBar.text length] > 0) {
        if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == 0) {
            predicate = [WMDefinition predicateForSearchInput:self.searchDisplayController.searchBar.text section:WoundPUMPScopeWoundLocation];
        } else {
            predicate = [WMDefinition predicateForSearchInput:self.searchDisplayController.searchBar.text];
        }
    }
    return predicate;
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
    NSArray *sortDescriptors = nil;
    if (self.isSearchActive) {
        sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"term" ascending:YES]];
    } else {
        sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"sectionTitle" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES], nil];
    }
    return sortDescriptors;
}

@end
