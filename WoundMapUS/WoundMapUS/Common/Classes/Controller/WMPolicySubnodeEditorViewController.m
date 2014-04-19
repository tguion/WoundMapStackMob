//
//  WMPolicySubnodeEditorViewController.m
//  WoundPUMP
//
//  Created by Todd Guion on 10/14/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMPolicySubnodeEditorViewController.h"
#import "WMNavigationNode.h"

@interface WMPolicySubnodeEditorViewController ()

@end

@implementation WMPolicySubnodeEditorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = self.parentNavigationNode.title;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PolicyEditorViewController

- (BOOL)sectionIsNavigationNodeSection:(NSInteger)section
{
    return YES;
}

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = kEditNodeCellIdentifier;
    WMNavigationNode *navigationNode = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (self.tableView.isEditing) {
        cellIdentifier = kReorderNodeCellIdentifier;
    } else if ([navigationNode.subnodes count] > 0) {
        cellIdentifier = kSubnodeCellIdentifier;
    }
    return cellIdentifier;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    WMNavigationNode *navigationNode = [self.fetchedResultsController objectAtIndexPath:indexPath];
    CGFloat deltaY = 0.0;
    if (NavigationNodeFrequencyUnit_None == navigationNode.frequencyUnitValue) {
        deltaY += 56.0;
    }
    if (NavigationNodeFrequencyUnit_None == navigationNode.closeUnitValue) {
        deltaY += 56.0;
    }
    if (self.tableView.isEditing) {
        height = 44.0;
    } else if ([navigationNode.subnodes count] > 0) {
        height = 44.0;
    } else if ([navigationNode.desc length] == 0) {
        height = 190.0 - deltaY;
    } else {
        height = 224.0 - deltaY;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0: {
            WMNavigationNode *navigationNode = [self.fetchedResultsController objectAtIndexPath:indexPath];
            if ([navigationNode.subnodes count] > 0) {
                // subnodes
                WMPolicySubnodeEditorViewController *viewController = [[WMPolicySubnodeEditorViewController alloc] initWithNibName:@"PolicyEditorViewController" bundle:nil];
                viewController.parentNavigationNode = navigationNode;
                viewController.delegate = self;
                [self.navigationController pushViewController:viewController animated:YES];
            }
            break;
        }
    }
    [self reorderNodesFromSortOrderings];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath

{
    WMNavigationNode *navigationNode = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self configureNavigationNodeCell:cell forNavigationNode:navigationNode];
}

#pragma mark - NSFetchedResultsController

- (NSPredicate *)fetchedResultsControllerPredicate
{
    return [NSPredicate predicateWithFormat:@"SELF in (%@)", self.parentNavigationNode.subnodes];
}

- (NSIndexPath *)indexPathTableToFetchedResultsController:(NSIndexPath *)indexPath
{
	return indexPath;
}

- (NSIndexPath *)indexPathFetchedResultsControllerToTable:(NSIndexPath *)indexPath
{
	return indexPath;
}

- (NSUInteger)sectionIndexFetchedResultsControllerToTable:(NSUInteger)sectionIndex
{
	return sectionIndex;
}

- (NSUInteger)sectionIndexTableToFetchedResultsController:(NSUInteger)sectionIndex
{
    return sectionIndex;
}

@end
