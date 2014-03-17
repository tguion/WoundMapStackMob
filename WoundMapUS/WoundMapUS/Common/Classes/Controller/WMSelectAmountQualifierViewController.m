//
//  WMSelectAmountQualifierViewController.m
//  WoundPUMP
//
//  Created by etreasure consulting LLC on 4/25/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMSelectAmountQualifierViewController.h"
#import "WCAmountQualifier+Custom.h"

@interface WMSelectAmountQualifierViewController ()

@end

@implementation WMSelectAmountQualifierViewController

@synthesize delegate;
@synthesize amountQualifier=_amountQualifier;

#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Select Amount";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
    [self.tableView registerNib:[UINib nibWithNibName:@"SelectCell" bundle:nil] forCellReuseIdentifier:@"SelectCell"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

#pragma mark - Memory

- (void)clearDataCache
{
    [super clearDataCache];
    _amountQualifier = nil;
}

#pragma mark - Core

- (WCAmountQualifier *)amountQualifier
{
    if (nil == _amountQualifier) {
        _amountQualifier = self.delegate.selectedAmountQualifier;
    }
    return _amountQualifier;
}

#pragma mark - Actions

- (IBAction)cancelAction:(id)sender
{
    [self.delegate selectAmountQualifierViewControllerDidCancel:self];
}

- (IBAction)doneAction:(id)sender
{
    [self.delegate selectAmountQualifierViewController:self didSelectQualifierAmount:self.amountQualifier];
}

#pragma mark - BaseViewController

- (void)updateTitle
{
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.amountQualifier = [self.fetchedResultsController objectAtIndexPath:indexPath];
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
    WCAmountQualifier *amountQualifier = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = amountQualifier.title;
    if ([self.amountQualifier isEqual:amountQualifier]) {
        cell.imageView.image = [UIImage imageNamed:@"ui_checkmark.png"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"ui_circle.png"];
    }
}

#pragma mark - NSFetchedResultsController

- (NSString *)fetchedResultsControllerEntityName
{
    return @"WCAmountQualifier";
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
