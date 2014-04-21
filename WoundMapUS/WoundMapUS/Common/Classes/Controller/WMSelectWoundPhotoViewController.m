//
//  WMSelectWoundPhotoViewController.m
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 2/25/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//

#import "WMSelectWoundPhotoViewController.h"
#import "WMWound.h"
#import "WMWoundPhoto.h"
#import "WMDesignUtilities.h"

@interface WMSelectWoundPhotoViewController ()

@end

@implementation WMSelectWoundPhotoViewController

@synthesize delegate;
@synthesize selectedWoundPhotos=_selectedWoundPhotos;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Select Photos";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Core

- (NSMutableSet *)selectedWoundPhotos
{
    if (nil == _selectedWoundPhotos) {
        _selectedWoundPhotos = [[NSMutableSet alloc] initWithCapacity:16];
        [_selectedWoundPhotos addObjectsFromArray:self.delegate.selectedWoundPhotos];
    }
    return  _selectedWoundPhotos;
}

#pragma mark - BaseViewController

- (void)updateTitle
{
    // nothing
}

- (void)clearDataCache
{
    [super clearDataCache];
    _selectedWoundPhotos = nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WMWoundPhoto *woundPhoto = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([self.selectedWoundPhotos containsObject:woundPhoto]) {
        [self.selectedWoundPhotos removeObject:woundPhoto];
    } else {
        [self.selectedWoundPhotos addObject:woundPhoto];
    }
    [tableView reloadData];
}

#pragma mark - Actions

- (IBAction)cancelAction:(id)sender
{
    [self.delegate selectWoundPhotoViewControllerDidCancel:self];
}

- (IBAction)doneAction:(id)sender
{
    [self.delegate selectWoundPhotoViewController:self didSelectWoundPhotos:[self.selectedWoundPhotos allObjects]];
}

#pragma mark - UITableViewDataSource

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"WoundPhotoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    WMWoundPhoto *woundPhoto = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSDateFormatter localizedStringFromDate:woundPhoto.createdAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    cell.imageView.image = woundPhoto.thumbnail;
    if ([self.selectedWoundPhotos containsObject:woundPhoto]) {
        cell.imageView.image = [WMDesignUtilities selectedWoundTableCellImage];
    } else {
        cell.imageView.image = [WMDesignUtilities unselectedWoundTableCellImage];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
}

#pragma mark - NSFetchedResultsController

- (NSString *)fetchedResultsControllerEntityName
{
	return @"WMWoundPhoto";
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
    return [NSPredicate predicateWithFormat:@"wound == %@", self.delegate.selectedWound];
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
    return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]];
}

@end
