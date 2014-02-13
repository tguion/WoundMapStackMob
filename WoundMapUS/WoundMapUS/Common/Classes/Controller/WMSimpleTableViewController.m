//
//  WMSimpleTableViewController.m
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 1/22/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//

#import "WMSimpleTableViewController.h"

@interface WMSimpleTableViewController ()

@end

@implementation WMSimpleTableViewController

@synthesize referenceObject=_referenceObject, values=_values, selectedValues=_selectedValues;

#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];
    // configure navigation
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                           target:self
                                                                                           action:@selector(saveAction:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (nil == self.title) {
        self.title = self.delegate.navigationTitle;
    }
    self.tableView.allowsMultipleSelection = self.allowMultipleSelection;
    [self.selectedValues addObjectsFromArray:self.delegate.selectedValuesForDisplay];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _values = nil;
    _selectedValues = nil;
    _referenceObject = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Add code to clean up any of your own resources that are no longer necessary.
}

#pragma mark - BaseViewController

- (void)updateTitle
{
    // nothing
}

- (void)clearDataCache
{
    [super clearDataCache];
    _referenceObject = nil;
    _values = nil;
    _selectedValues = nil;
}

#pragma mark - Core

- (NSArray *)values
{
    if (nil == _values) {
        _values = self.delegate.valuesForDisplay;
    }
    return _values;
}

- (NSMutableSet *)selectedValues
{
    if (nil == _selectedValues) {
        _selectedValues = [[NSMutableSet alloc] initWithCapacity:16];
    }
    return _selectedValues;
}

#pragma mark - Actions

- (IBAction)cancelAction:(id)sender
{
    [self.delegate simpleTableViewControllerDidCancel:self];
}

- (IBAction)saveAction:(id)sender
{
    [self.delegate simpleTableViewController:self didSelectValues:[self.selectedValues allObjects]];
}

#pragma mark - UITableViewDelegate

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id value = [self.values objectAtIndex:indexPath.row];
    if ([self.selectedValues containsObject:value]) {
        [self.selectedValues removeObject:value];
    } else {
        if (!self.allowMultipleSelection) {
            [self.selectedValues removeAllObjects];
        }
        [self.selectedValues addObject:value];
    }
    [tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.values count];
}

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
    id object = [self.values objectAtIndex:indexPath.row];
    // DEPLOYMENT - iOS7 issue ???
    CGRect frame = cell.textLabel.frame;
    CGFloat deltaX = (CGRectGetMaxX(cell.imageView.frame) + 8.0 - CGRectGetMinX(frame));
    frame.origin.x += deltaX;
    frame.size.width -= deltaX;
    cell.textLabel.frame = frame;
    cell.textLabel.text = object;
    if ([self.selectedValues containsObject:object]) {
        cell.imageView.image = [UIImage imageNamed:@"ui_checkmark"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"ui_circle"];
    }
}

@end
