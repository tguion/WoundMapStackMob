//
//  WMBradenSectionSelectCellViewController.m
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 7/30/12.
//  Copyright (c) 2012 etreasure consulting inc. All rights reserved.
//

#import "WMBradenSectionSelectCellViewController.h"
#import "WMBradenCellSelectTableViewCell.h"
#import "MBProgressHUD.h"
#import "WMFatFractal.h"
#import "WMFatFractalManager.h"
#import "WMBradenScale.h"
#import "WMBradenSection.h"
#import "WMBradenCell.h"
#import "WMUtilities.h"

@interface WMBradenSectionSelectCellViewController ()

@property (nonatomic) BOOL removeUndoManagerWhenDone;

@end

@implementation WMBradenSectionSelectCellViewController

@synthesize delegate;
@synthesize bradenSection=_bradenSection, selectedBradenCell=_selectedBradenCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.modalInPopover = YES;
        self.preferredContentSize = CGSizeMake(320.0, 460.0);
        __weak __typeof(&*self)weakSelf = self;
        self.refreshCompletionHandler = ^(NSError *error, id object) {
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    __weak __typeof(&*self)weakSelf = self;
    if ([_bradenSection.cells count] == 0) {
        [MBProgressHUD showHUDAddedToViewController:self animated:YES];
        [WMBradenScale populateBradenSectionCells:_bradenSection];
        __block NSInteger counter = [_bradenSection.cells count];
        FFHttpMethodCompletion createHandler = ^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            }
            [ff queueGrabBagAddItemAtUri:[object valueForKey:WMBradenCellAttributes.ffUrl] toObjAtUri:_bradenSection.ffUrl grabBagName:WMBradenSectionRelationships.cells];
            if (counter == 0 || --counter == 0) {
                [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
            }
        };
        for (WMBradenCell *bradenCell in _bradenSection.cells) {
            [ff createObj:bradenCell
                    atUri:[NSString stringWithFormat:@"/%@", [WMBradenCell entityName]]
               onComplete:createHandler
                onOffline:createHandler];
        }
    }
    if (!_newBradenScaleFlag) {
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
    self.title = self.bradenSection.title;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Add code to clean up any of your own resources that are no longer necessary.
}

#pragma mark - BaseViewController

- (void)clearDataCache
{
    [super clearDataCache];
    _bradenSection = nil;
    _selectedBradenCell = nil;
}

#pragma mark - NSFetchedResultsController

- (NSString *)fetchedResultsControllerEntityName
{
	return @"WMBradenCell";
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
	return [NSPredicate predicateWithFormat:@"section == %@", self.bradenSection];
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
	return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"value" ascending:YES]];
}

- (NSArray *)ffQuery
{
    if (_bradenSection.ffUrl) {
        return @[[NSString stringWithFormat:@"%@/%@", _bradenSection.ffUrl, WMBradenSectionRelationships.cells]];
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
    WMBradenCellSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
		cell = [[WMBradenCellSelectTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	WMBradenCell *bradenCell = [self.fetchedResultsController objectAtIndexPath:indexPath];
	WMBradenCellSelectTableViewCell *myCell = (WMBradenCellSelectTableViewCell *)cell;
	myCell.bradenCell = bradenCell;
    myCell.accessoryType = bradenCell.isSelected ? UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
}

#pragma mark - UITableViewDelegate

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedBradenCell = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[self.delegate controller:self didSelectBradenCell:self.selectedBradenCell];
}

// Variable height support

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WMBradenCell *bradenCell = [self.fetchedResultsController objectAtIndexPath:indexPath];
	return [WMBradenCellSelectTableViewCell recommendedHeightForBradenCell:bradenCell forWidth:UIEdgeInsetsInsetRect(tableView.bounds, tableView.separatorInset).size.width];
}

@end
