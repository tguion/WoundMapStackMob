//
//  WMParticipantTableViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 5/3/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMParticipantTableViewController.h"
#import "WMParticipant.h"
#import "WMParticipantType.h"

@interface WMParticipantTableViewController ()

@property (strong, nonatomic) WMParticipant *participant;

- (IBAction)cancelAction:(id)sender;
- (IBAction)doneAction:(id)sender;

@end

@implementation WMParticipantTableViewController

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
    // Do any additional setup after loading the view from its nib.
    self.title = NSLocalizedString(@"Participants", @"Participants");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                           target:self
                                                                                           action:@selector(cancelAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneAction:)];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)cancelAction:(id)sender
{
    [self.delegate participantTableViewControllerDidCancel:self];
}

- (IBAction)doneAction:(id)sender
{
    [self.delegate participantTableViewController:self didSelectParticipant:_participant];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _participant = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [tableView reloadData];
}

#pragma mark - UITableViewDataSource

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    WMParticipant *participant = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = participant.name;
    cell.detailTextLabel.text = participant.participantType.title;
    cell.accessoryType = (participant == _participant ? UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone);
}

#pragma mark - NSFetchedResultsController

- (NSString *)fetchedResultsControllerEntityName
{
    return [WMParticipant entityName];
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
    return self.delegate.participantPredicate;
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
    return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]];
}

@end
