//
//  WMChooseStageViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMChooseStageViewController.h"
#import "WMNavigationTrack.h"
#import "WMNavigationStage.h"
#import "WMNavigationStageTableViewCell.h"
#import "WMNavigationCoordinator.h"
#import "WCAppDelegate.h"
#import "WMDesignUtilities.h"
#import "WMUtilities.h"

@interface WMChooseStageViewController ()

@property (readonly, nonatomic) WMNavigationTrack *navigationTrack;
@property (strong, nonatomic) WMNavigationStage *navigationStage;     // selected stage

@end

@implementation WMChooseStageViewController

#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Choose Stage";
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(chooseStageAction:)];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    barButtonItem.enabled = (nil != self.navigationStage);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    // tableView
    [self.tableView registerClass:[WMNavigationStageTableViewCell class] forCellReuseIdentifier:@"StageCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core

- (WMNavigationTrack *)navigationTrack
{
    if (nil == self.delegate) {
        return self.appDelegate.navigationCoordinator.navigationTrack;
    }
    // else
    return self.delegate.navigationTrack;
}

- (WMNavigationStage *)navigationStage
{
    if (nil == _navigationStage) {
        if (nil == self.delegate) {
            _navigationStage = self.appDelegate.navigationCoordinator.navigationStage;
        } else {
            _navigationStage = self.delegate.navigationStage;
        }
    }
    return _navigationStage;
}

#pragma mark - Actions

- (IBAction)chooseStageAction:(id)sender
{
    [self.delegate chooseStageViewController:self didSelectNavigationStage:self.navigationStage];
}

- (IBAction)cancelAction:(id)sender
{
    [self.delegate chooseStageViewControllerDidCancel:self];
}

#pragma mark - BaseViewController

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [WMNavigationStageTableViewCell heightTheFitsForStage:[self.fetchedResultsController objectAtIndexPath:indexPath] width:(CGRectGetWidth(self.view.frame) - 52.0)];
}

// select existing patient document
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.navigationStage = [self.fetchedResultsController objectAtIndexPath:indexPath];
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
    NSString *cellIdentifier = @"StageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    WMNavigationStageTableViewCell *myCell = (WMNavigationStageTableViewCell *)cell;
    WMNavigationStage *navigationStage = [self.fetchedResultsController objectAtIndexPath:indexPath];
    myCell.navigationStage = navigationStage;
    myCell.imageView.image = (navigationStage == _navigationStage ? [WMDesignUtilities selectedWoundTableCellImage]:[WMDesignUtilities unselectedWoundTableCellImage]);
    myCell.accessoryType = UITableViewCellAccessoryNone;
}

#pragma mark - NSFetchedResultsController

- (NSString *)fetchedResultsControllerEntityName
{
	return @"WMNavigationStage";
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
    return [NSPredicate predicateWithFormat:@"track == %@", self.navigationTrack];
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
    return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES]];
}

@end
