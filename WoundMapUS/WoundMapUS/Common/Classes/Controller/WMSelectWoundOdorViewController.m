//
//  WMSelectWoundOdorViewController.m
//  WoundPUMP
//
//  Created by etreasure consulting LLC on 4/26/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMSelectWoundOdorViewController.h"
#import "WMWoundOdor.h"

@interface WMSelectWoundOdorViewController ()

@end

@implementation WMSelectWoundOdorViewController

@synthesize delegate, woundOdor=_woundOdor;

#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Select Odor";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
    [self.tableView registerNib:[UINib nibWithNibName:@"SelectCell" bundle:nil] forCellReuseIdentifier:@"SelectCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.woundOdor = self.delegate.selectedWoundOdor;
    [super viewWillAppear:animated];
}

#pragma mark - Memory

- (void)clearDataCache
{
    [super clearDataCache];
    _woundOdor = nil;
}

#pragma mark - Core

- (WMWoundOdor *)woundOdor
{
    if (nil == _woundOdor) {
        _woundOdor = self.delegate.selectedWoundOdor;
    }
    return _woundOdor;
}

#pragma mark - Actions

- (IBAction)cancelAction:(id)sender
{
    [self.delegate selectWoundOdorViewControllerDidCancel:self];
}

- (IBAction)doneAction:(id)sender
{
    [self.delegate selectWoundOdorViewController:self didSelectWoundOdor:self.woundOdor];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.woundOdor = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [tableView reloadData];
}

#pragma mark - UITableViewDataSource

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    WMWoundOdor *woundOdor = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = woundOdor.title;
    if ([self.woundOdor isEqual:woundOdor]) {
        cell.imageView.image = [UIImage imageNamed:@"ui_checkmark"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"ui_circle"];
    }
}

#pragma mark - NSFetchedResultsController

- (NSArray *)backendSeedEntityNames
{
    return @[self.fetchedResultsControllerEntityName];
}

- (NSString *)fetchedResultsControllerEntityName
{
    return @"WCWoundOdor";
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
    return nil;
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
    return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES]];
}

@end
