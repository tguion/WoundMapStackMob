//
//  WMBradenScaleInputViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/26/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBradenScaleInputViewController.h"
#import "WMBradenScaleViewController.h"
#import "WMBradenSectionSelectCellViewController.h"
#import "MBProgressHUD.h"
#import "WMBradenCellTableViewCell.h"
#import "WMBradenSection.h"
#import "WMBradenScale.h"
#import "WMBradenCell.h"
#import "WMBradenScaleTableHeaderView.h"
#import "WMBradenSectionHeaderView.h"
#import "WMFatFractal.h"
#import "WMFatFractalManager.h"
#import "WMUtilities.h"

@interface WMBradenScaleInputViewController () <BradenSectionCellDelegate, BradenCellSelectionDelegate>

@property (nonatomic) BOOL removeUndoManagerWhenDone;

@property (readonly, nonatomic) WMBradenScaleTableHeaderView *bradenScaleTableViewHeader;
@property (strong, nonatomic) NSMutableDictionary *bradenSectionExpansionMap;
@property (readonly, nonatomic) WMBradenSectionSelectCellViewController *bradenSectionSelectCellViewController;
@property (nonatomic) BOOL didCancel;

@end

@implementation WMBradenScaleInputViewController (PrivateMethods)

- (WMBradenSection *)bradenSectionForSection:(NSInteger)section
{
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSString *sortRankString = [sectionInfo name];
	return [WMBradenSection bradenSectionBradenScale:self.bradenScale sortRank:[sortRankString intValue]];
}

- (NSString *)keyForIndexPath:(NSIndexPath *)indexPath
{
    return [NSString stringWithFormat:@"[%ld, %ld]", (long)indexPath.row, (long)indexPath.section];
}

- (void)navigateToBradenCellSelector:(WMBradenSection *)bradenSection
{
    WMBradenSectionSelectCellViewController *bradenSectionSelectCellViewController = self.bradenSectionSelectCellViewController;
    bradenSectionSelectCellViewController.bradenSection = bradenSection;
    bradenSectionSelectCellViewController.newBradenScaleFlag = self.newBradenScaleFlag;
    [self.navigationController pushViewController:bradenSectionSelectCellViewController animated:YES];
}

@end

@implementation WMBradenScaleInputViewController

- (WMBradenSectionSelectCellViewController *)bradenSectionSelectCellViewController
{
    WMBradenSectionSelectCellViewController *bradenSectionSelectCellViewController = [[WMBradenSectionSelectCellViewController alloc] initWithNibName:@"WMBradenSectionSelectCellViewController" bundle:nil];
    bradenSectionSelectCellViewController.delegate = self;
    return bradenSectionSelectCellViewController;
}

- (WMBradenScaleTableHeaderView *)bradenScaleTableViewHeader
{
    return (WMBradenScaleTableHeaderView *)self.tableView.tableHeaderView;
}

- (NSMutableDictionary *)bradenSectionExpansionMap
{
    if (nil == _bradenSectionExpansionMap) {
        _bradenSectionExpansionMap = [[NSMutableDictionary alloc] initWithCapacity:16];
    }
    return _bradenSectionExpansionMap;
}

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.modalInPopover = YES;
        self.preferredContentSize = CGSizeMake(320.0, 380.0);
        __weak __typeof(&*self)weakSelf = self;
        self.refreshCompletionHandler = ^(NSError *error, id object) {
            [weakSelf.managedObjectContext MR_saveToPersistentStoreAndWait];
            if (!weakSelf.newBradenScaleFlag) {
                // we want to support cancel, so make sure we have an undoManager
                if (nil == weakSelf.managedObjectContext.undoManager) {
                    weakSelf.managedObjectContext.undoManager = [[NSUndoManager alloc] init];
                    weakSelf.removeUndoManagerWhenDone = YES;
                }
                [weakSelf.managedObjectContext.undoManager beginUndoGrouping];
            }
        };
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Add code to clean up any of your own resources that are no longer necessary.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Edit Scale";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
																						   target:self
																						   action:@selector(doneAction:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelAction:)];
	WMBradenScaleTableHeaderView *aView = [[WMBradenScaleTableHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), 64.0)];
	self.tableView.tableHeaderView = aView;
    // update from back end or create new data
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    __weak __typeof(&*self)weakSelf = self;
    if (_newBradenScaleFlag) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        // create and save to back end
        NSParameterAssert(_bradenScale);
        NSParameterAssert([_bradenScale.sections count] == 0);
        [WMBradenScale populateBradenScaleSections:_bradenScale];
        __block NSInteger counter = [_bradenScale.sections count];
        FFHttpMethodCompletion handler = ^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            }
            if (counter == 0 || --counter == 0) {
                [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
            }
        };
        FFHttpMethodCompletion grabBagHandler = ^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            }
            [ff grabBagAddItemAtFfUrl:[object valueForKey:@"ffUrl"]
                         toObjAtFfUrl:_bradenScale.ffUrl
                          grabBagName:WMBradenScaleRelationships.sections
                           onComplete:handler];
        };
        for (WMBradenSection *bradenSection in _bradenScale.sections) {
            [ff createObj:bradenSection
                    atUri:[NSString stringWithFormat:@"/%@", [WMBradenSection entityName]]
               onComplete:grabBagHandler
                onOffline:grabBagHandler];
        }
    } else {
        // make sure we have the data from back end will be handled by fetchedResultsControllerDidFetch
        // we want to support cancel, so make sure we have an undoManager
        if (nil == self.managedObjectContext.undoManager) {
            self.managedObjectContext.undoManager = [[NSUndoManager alloc] init];
            _removeUndoManagerWhenDone = YES;
        }
        [self.managedObjectContext.undoManager beginUndoGrouping];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.bradenScaleTableViewHeader.bradenScale = self.bradenScale;
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - BaseViewController

- (void)clearDataCache
{
    [super clearDataCache];
    _bradenScale = nil;
    _bradenSectionExpansionMap = nil;
}

#pragma mark - Core

- (void)setBradenScale:(WMBradenScale *)bradenScale
{
    if (_bradenScale == bradenScale) {
        return;
    }
    // else
    [self willChangeValueForKey:@"bradenScale"];
    _bradenScale = bradenScale;
    [self didChangeValueForKey:@"bradenScale"];
    // update the header view
    self.bradenScaleTableViewHeader.bradenScale = bradenScale;
}

#pragma mark - Actions

- (IBAction)doneAction:(id)sender
{
    if (!_newBradenScaleFlag) {
        if (self.managedObjectContext.undoManager.groupingLevel > 0) {
            [self.managedObjectContext.undoManager endUndoGrouping];
        }
        if (_removeUndoManagerWhenDone) {
            self.managedObjectContext.undoManager = nil;
        }
    }
    [self.delegate bradenScaleInputController:self didFinishWithBradenScale:self.bradenScale];
}

- (IBAction)cancelAction:(id)sender
{
    _didCancel = YES;
    if (!_newBradenScaleFlag) {
        if (self.managedObjectContext.undoManager.groupingLevel > 0) {
            [self.managedObjectContext.undoManager endUndoGrouping];
            if (_didCancel && self.managedObjectContext.undoManager.canUndo) {
                [self.managedObjectContext.undoManager undoNestedGroup];
            }
        }
        if (_removeUndoManagerWhenDone) {
            self.managedObjectContext.undoManager = nil;
        }
    }
    [self.delegate bradenScaleInputControllerDidCancel:self];
}

#pragma mark - BradenSectionCellDelegate

- (void)updateExpandedMapForBradenSection:(WMBradenSection *)bradenSection expanded:(BOOL)expanded
{
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:bradenSection];
    NSString *key = [self keyForIndexPath:indexPath];
    if (expanded) {
        [self.bradenSectionExpansionMap setObject:@YES forKey:key];
    } else {
        [self.bradenSectionExpansionMap removeObjectForKey:key];
    }
    [self.tableView reloadData];
}

#pragma mark - BradenCellSelectionDelegate

- (void)controller:(WMBradenSectionSelectCellViewController *)viewController didSelectBradenCell:(WMBradenCell *)bradenCell
{
    WMBradenSection *bradenSection = bradenCell.section;
    [bradenSection.cells makeObjectsPerformSelector:@selector(setSelectedFlag:) withObject:@NO];
    bradenCell.selectedFlag = @YES;
    [bradenSection.bradenScale updateScoreFromSections];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - NSFetchedResultsController

- (NSString *)fetchedResultsControllerEntityName
{
	return @"WMBradenSection";
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
	return [NSPredicate predicateWithFormat:@"bradenScale == %@", self.bradenScale];
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
	return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES]];
}

- (NSArray *)ffQuery
{
    if (_bradenScale.ffUrl) {
        return @[[NSString stringWithFormat:@"%@/%@", _bradenScale.ffUrl, WMBradenScaleRelationships.sections]];
    }
    // else
    return nil;
}

#pragma mark - UITableViewDataSource

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"BradenCell";
    WMBradenCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
		cell = [[WMBradenCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.delegate = self;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	WMBradenSection *bradenSection = [self.fetchedResultsController objectAtIndexPath:indexPath];
	WMBradenCellTableViewCell *myCell = (WMBradenCellTableViewCell *)cell;
	myCell.bradenSection = bradenSection;
    NSString *key = [self keyForIndexPath:indexPath];
    myCell.expandedFlag = [[self.bradenSectionExpansionMap objectForKey:key] boolValue];
}

#pragma mark - UITableViewDelegate

// Variable height support

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL expanded = (nil != [self.bradenSectionExpansionMap objectForKey:[self keyForIndexPath:indexPath]]);
    WMBradenSection *bradenSection = [self.fetchedResultsController objectAtIndexPath:indexPath];
	return [WMBradenCellTableViewCell recommendedHeightForBradenSection:bradenSection expanded:expanded forWidth:CGRectGetWidth(tableView.bounds)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 33.0;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    WMBradenSection *bradenSection = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[self navigateToBradenCellSelector:bradenSection];
}

// Section header & footer information. Views are preferred over title should you decide to provide both

// custom view for footer. will be adjusted to default or specified footer height
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	return nil;
}

@end
