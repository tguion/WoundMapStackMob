//
//  WMSelectWoundTypeViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMSelectWoundTypeViewController.h"
#import "WMWound.h"
#import "WMWoundType.h"
#import "WMDefinition.h"
#import "UIView+Custom.h"
#import "WMDesignUtilities.h"
#import "WMUtilities.h"

@interface WMSelectWoundTypeViewController () <SelectWoundTypeViewControllerDelegate>

@property (readonly, nonatomic) WMSelectWoundTypeViewController *selectWoundTypeViewController;

@end

@interface WMSelectWoundTypeViewController (PrivateMethods)

- (void)navigateToChildrenViewControllerForParentWoundType:(WMWoundType *)parentWoundType;
- (void)reloadRowsForSelectedWoundType:(WMWoundType *)previousWoundType;

@end

@implementation WMSelectWoundTypeViewController (PrivateMethods)

- (void)navigateToChildrenViewControllerForParentWoundType:(WMWoundType *)parentWoundType
{
    WMSelectWoundTypeViewController *selectWoundTypeViewController = self.selectWoundTypeViewController;
    selectWoundTypeViewController.parentWoundType = parentWoundType;
    [self.navigationController pushViewController:selectWoundTypeViewController animated:YES];
}

- (void)reloadRowsForSelectedWoundType:(WMWoundType *)previousWoundType
{
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:self.selectedWoundType];
    NSIndexPath *currentIndexPath = nil;
    if (nil != previousWoundType && ![previousWoundType isEqual:self.selectedWoundType]) {
        // previousWoundType may be a child of displayed wound types
        WMWoundType *woundType = previousWoundType;
        while (nil != woundType) {
            currentIndexPath = [self.fetchedResultsController indexPathForObject:woundType];
            if (nil != currentIndexPath) {
                break;
            }
            // else
            woundType = woundType.parent;
        }
    }
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, currentIndexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
}

@end

@implementation WMSelectWoundTypeViewController

@synthesize wound=_wound;

- (WMWoundType *)selectedWoundType
{
    if (nil == _selectedWoundType) {
        _selectedWoundType = self.wound.woundType;
    }
    return _selectedWoundType;
}

- (WMSelectWoundTypeViewController *)selectWoundTypeViewController
{
    WMSelectWoundTypeViewController *selectWoundTypeViewController = [[WMSelectWoundTypeViewController alloc] initWithNibName:@"WMSelectWoundTypeViewController" bundle:nil];
    selectWoundTypeViewController.delegate = self;
    selectWoundTypeViewController.wound = self.wound;
    return selectWoundTypeViewController;
}

#pragma mark - View

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // set state
        self.modalInPopover = YES;
        self.preferredContentSize = CGSizeMake(320.0, 680.0);
    }
    return self;
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Add code to clean up any of your own resources that are no longer necessary.
}

- (void)clearDataCache
{
    [super clearDataCache];
    _selectedWoundType = nil;
    _parentWoundType = nil;
}

#pragma mark - Core

- (WMWound *)wound
{
    if (nil == _wound) {
        _wound = [super wound];
    }
    return _wound;
}

#pragma mark - BuildGroupViewController

- (void)updateUIForDataChange
{
    [super updateUIForDataChange];
    self.title = (nil == self.parentWoundType ? @"Wound Type":self.parentWoundType.titleForDisplay);
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (id)valueForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup
{
    WMWoundType *woundType = (WMWoundType *)assessmentGroup;
    // check if child is selected
    if ([woundType.children containsObject:self.selectedWoundType]) {
        return self.selectedWoundType.titleForDisplay;
    }
    // else
    if (woundType == self.selectedWoundType) {
        return ([self.wound.woundTypeValue length] > 0 ? self.wound.woundTypeValue:self.selectedWoundType);
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
    WMWoundType *woundType = (WMWoundType *)assessmentGroup;
    if (createValue) {
        WMWoundType *previousWoundType = self.selectedWoundType;
        self.wound.woundTypeValue = value;
        self.selectedWoundType = woundType;
        [self reloadRowsForSelectedWoundType:previousWoundType];
    } else {
        self.wound.woundTypeValue = nil;
        self.selectedWoundType = nil;
    }
}

#pragma mark - Actions

- (IBAction)saveAction:(id)sender
{
    [super saveAction:sender];
    [self.delegate selectWoundTypeViewController:self didSelectWoundType:self.selectedWoundType];
}

- (IBAction)cancelAction:(id)sender
{
    self.willCancelFlag = YES;
    [self.delegate selectWoundTypeViewControllerDidCancel:self];
}

#pragma mark - SelectWoundTypeViewControllerDelegate

- (void)selectWoundTypeViewController:(WMSelectWoundTypeViewController *)viewController didSelectWoundType:(WMWoundType *)woundType
{
    self.selectedWoundType = woundType;
    if (woundType.parent) {
        NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:woundType.parent];
        if (indexPath) {
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selectWoundTypeViewControllerDidCancel:(WMSelectWoundTypeViewController *)viewController
{
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
    WMWoundType *selectedWoundType = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (selectedWoundType.hasChildrenWoundTypes) {
        // navigate to view with children
        [self navigateToChildrenViewControllerForParentWoundType:selectedWoundType];
    } else {
        // make sure we don't refresh a row with a control
        BOOL refreshRow = YES;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIResponder *responder = [self possibleFirstResponderInCell:cell];
        if (nil == responder) {
            [self.view endEditing:YES];
            // check for a control
            UIControl *control = [self controlInCell:cell];
            if (nil != control) {
                refreshRow = NO;
            }
        } else {
            refreshRow = NO;
            self.indexPathForDelayedFirstResponder = indexPath;
            [responder performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];
        }
        // draw as selected
        WMWoundType *previousWoundType = self.selectedWoundType;
        self.selectedWoundType = selectedWoundType;
        self.wound.woundType = self.selectedWoundType;
        if (refreshRow) {
            [self reloadRowsForSelectedWoundType:previousWoundType];
        }
        [self updateUIForDataChange];
    }
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.isSearchActive) {
        return nil;
    }
    // else
	id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    return sectionInfo.name;
}

#pragma mark - NSFetchedResultsController

- (NSArray *)backendSeedEntityNames
{
    return @[[WMWoundType entityName]];
}

- (NSString *)fetchedResultsControllerEntityName
{
    return (self.isSearchActive ? @"WMDefinition":@"WMWoundType");
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
    NSPredicate *predicate = nil;
    if (self.isSearchActive) {
        if ([self.searchDisplayController.searchBar.text length] > 0) {
            if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == 0) {
                predicate = [WMDefinition predicateForSearchInput:self.searchDisplayController.searchBar.text section:WoundPUMPScopeWoundType];
            } else {
                predicate = [WMDefinition predicateForSearchInput:self.searchDisplayController.searchBar.text];
            }
        }
    } else {
        if (nil == self.parentWoundType) {
            predicate = [NSPredicate predicateWithFormat:@"parent = nil"];
        } else {
            predicate = [NSPredicate predicateWithFormat:@"parent == %@", self.parentWoundType];
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
        sortDescriptors = [NSArray arrayWithObjects:
                           [NSSortDescriptor sortDescriptorWithKey:@"sectionTitle" ascending:YES],
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
	return (self.parentWoundType.childrenHaveSectionTitles ? @"sectionTitle":nil);
}

@end
