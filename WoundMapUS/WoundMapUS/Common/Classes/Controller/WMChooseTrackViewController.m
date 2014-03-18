//
//  WMChooseTrackViewController.m
//  WoundPUMP
//
//  Created by Todd Guion on 7/12/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMChooseTrackViewController.h"
#import "WMNavigationTrack.h"
#import "WMNavigationTrackTableViewCell.h"
#import "CoreDataHelper.h"
#import "WMUserDefaultsManager.h"
#import "WMUtilities.h"

@interface WMChooseTrackViewController ()
@property (strong, nonatomic) WMNavigationTrack *navigationTrack;
@end

@implementation WMChooseTrackViewController

#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Choose Clinical Setting";
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(chooseTrackAction:)];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    barButtonItem.enabled = (nil != self.navigationTrack);
    if (nil != self.delegate) {
        barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
        self.navigationItem.leftBarButtonItem = barButtonItem;
    }
    // tableView
    [self.tableView registerClass:[WMNavigationTrackTableViewCell class] forCellReuseIdentifier:@"TrackCell"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.isIPadIdiom) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (nil == self.navigationController) {
        [self clearAllReferences];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    _navigationTrack = nil;
}

#pragma mark - Core

- (WMNavigationTrack *)navigationTrack
{
    if (nil == _navigationTrack) {
        _navigationTrack = [self.userDefaultsManager defaultNavigationTrack:self.managedObjectContext];
    }
    return _navigationTrack;
}

#pragma mark - Actions

- (IBAction)chooseTrackAction:(id)sender
{
    [self.delegate chooseTrackViewController:self didChooseNavigationTrack:self.navigationTrack];
}

- (IBAction)cancelAction:(id)sender
{
    [self.delegate chooseTrackViewControllerDidCancel:self];
}

#pragma mark - BaseViewController

- (void)updateTitle
{
    // nothing
}

- (void)clearDataCache
{
    [super clearDataCache];
    _navigationTrack = nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [WMNavigationTrackTableViewCell heightTheFitsForTrack:[self.fetchedResultsController objectAtIndexPath:indexPath] width:(CGRectGetWidth(self.view.frame) - 52.0)];
}

// select existing patient document
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.navigationTrack = [self.fetchedResultsController objectAtIndexPath:indexPath];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"TrackCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    WMNavigationTrackTableViewCell *myCell = (WMNavigationTrackTableViewCell *)cell;
    WMNavigationTrack *navigationTrack = [self.fetchedResultsController objectAtIndexPath:indexPath];
    myCell.navigationTrack = navigationTrack;
    myCell.imageView.image = (navigationTrack == _navigationTrack ? [UIImage imageNamed:@"ui_checkmark"]:[UIImage imageNamed:@"ui_circle"]);
    myCell.accessoryType = UITableViewCellAccessoryNone;
}

#pragma mark - NSFetchedResultsController

- (NSString *)fetchedResultsControllerEntityName
{
	return @"WMNavigationTrack";
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
