//
//  WMTelecomListViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 3/16/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMTelecomListViewController.h"
#import "WMTelecomEditorViewController.h"
#import "MBProgressHUD.h"
#import "WMTelecom.h"
#import "WMTelecom+CoreText.h"
#import "WMUtilities.h"

@interface WMTelecomListViewController () <TelecomEditorViewControllerDelegate>

@property (weak, nonatomic) NSManagedObjectContext *moc;

@property (nonatomic) BOOL removeUndoManagerWhenDone;
@property (readonly, nonatomic) WMTelecomEditorViewController *telecomEditorViewController;
@property (strong, nonatomic) NSArray *telecoms;

- (BOOL)isAddIndexPath:(NSIndexPath *)indexPath;

@end

@implementation WMTelecomListViewController

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
    self.title = @"Telecoms";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneAction:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelAction:)];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"AddCell"];
    // allow editing
    [self.tableView setEditing:YES animated:NO];
    // we want to support cancel, so make sure we have an undoManager
    if (nil == self.managedObjectContext.undoManager) {
        self.managedObjectContext.undoManager = [[NSUndoManager alloc] init];
        _removeUndoManagerWhenDone = YES;
    }
    [self.managedObjectContext.undoManager beginUndoGrouping];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core

- (NSManagedObjectContext *)managedObjectContext
{
    if (nil == _moc) {
        _moc = self.delegate.managedObjectContext;
    }
    return _moc;
}

- (NSString *)cellReuseIdentifier:(NSIndexPath *)indexPath
{
    NSString *cellReuseIdentifier = @"Cell";
    if ([self isAddIndexPath:indexPath]) {
        cellReuseIdentifier = @"AddCell";
    }
    return cellReuseIdentifier;
}

- (NSArray *)telecoms
{
    if (nil == _telecoms) {
        _telecoms = [[self.delegate.telecomSource.telecoms allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:YES]]];
        if (_attemptAcquireFromBackEnd) {
            __weak __typeof(&*self)weakSelf = self;
            [MBProgressHUD showHUDAddedToViewController:self animated:YES];
            [self.delegate.telecomSource telecomsWithRefreshHandler:^{
                WM_ASSERT_MAIN_THREAD;
                [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
                weakSelf.telecoms = [[weakSelf.delegate.telecomSource.telecoms allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:YES]]];
                [weakSelf.tableView reloadData];
            }];
        }
    }
    return _telecoms;
}

- (BOOL)isAddIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row == [self.delegate.telecomSource.telecoms count];
}

- (WMTelecomEditorViewController *)telecomEditorViewController
{
    WMTelecomEditorViewController *telecomEditorViewController = [[WMTelecomEditorViewController alloc] initWithNibName:@"WMTelecomEditorViewController" bundle:nil];
    telecomEditorViewController.delegate = self;
    return telecomEditorViewController;
}

- (void)navigateToTelecomEditorForTelecom:(WMTelecom *)telecom
{
    WMTelecomEditorViewController *telecomEditorViewController = self.telecomEditorViewController;
    telecomEditorViewController.telecom = telecom;
    [self.navigationController pushViewController:telecomEditorViewController animated:YES];
}

- (WMTelecom *)telecomForIndex:(NSInteger)index
{
    if (nil == _telecoms) {
        _telecoms = [[self.delegate.telecomSource.telecoms allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:YES]]];
    }
    return _telecoms[index];
}

#pragma mark - WMBaseViewController

- (void)clearDataCache
{
    [super clearDataCache];
    _telecoms = nil;
}

#pragma mark - Actions

- (IBAction)addAction:(id)sender
{
    WMTelecom *telecom = [WMTelecom MR_createInContext:self.managedObjectContext];
    [self navigateToTelecomEditorForTelecom:telecom];
}

- (IBAction)doneAction:(id)sender
{
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
    }
    if (_removeUndoManagerWhenDone) {
        self.managedObjectContext.undoManager = nil;
    }
    [self.delegate telecomListViewControllerDidFinish:self];
}

- (IBAction)cancelAction:(id)sender
{
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
        if (self.managedObjectContext.undoManager.canUndo) {
            // this should undo the insert of new person
            [self.managedObjectContext.undoManager undoNestedGroup];
        }
    }
    if (_removeUndoManagerWhenDone) {
        self.managedObjectContext.undoManager = nil;
    }
    [self.delegate telecomListViewControllerDidCancel:self];
}

#pragma mark - WMBaseViewController

#pragma mark - TelecomEditorViewControllerDelegate

- (void)telecomEditorViewController:(WMTelecomEditorViewController *)viewController didEditTelecom:(WMTelecom *)telecom
{
    [self.delegate.telecomSource addTelecomsObject:telecom];
    [self.navigationController popViewControllerAnimated:YES];
    _telecoms = nil;
    [self.tableView reloadData];
    [viewController clearAllReferences];
}

- (void)telecomEditorViewControllerDidCancel:(WMTelecomEditorViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44.0;
    if (![self isAddIndexPath:indexPath]) {
        WMTelecom *telecom = [self telecomForIndex:indexPath.row];
        NSAttributedString *attributedString = [telecom descriptionAsMutableAttributedStringWithBaseFontSize:15.0];
        CGSize aSize = CGSizeMake(CGRectGetWidth(self.tableView.bounds) - self.tableView.separatorInset.left - self.tableView.separatorInset.right, CGFLOAT_MAX);
        height = ceilf([attributedString boundingRectWithSize:aSize
                                                      options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                      context:nil].size.height) + 32.0;
    }
    return height;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([self isAddIndexPath:indexPath] ? UITableViewCellEditingStyleInsert:UITableViewCellEditingStyleDelete);
}

// Controls whether the background is indented while editing.  If not implemented, the default is YES.
// This is unrelated to the indentation level below.  This method only applies to grouped style table views.
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self isAddIndexPath:indexPath]) {
        // add telecom
        [self addAction:nil];
    } else {
        // edit address
        [self navigateToTelecomEditorForTelecom:[self telecomForIndex:indexPath.row]];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.delegate.telecomSource.telecoms count] + 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [self cellReuseIdentifier:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([self isAddIndexPath:indexPath]) {
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.textLabel.text = @"Add Telecom";
    } else {
        WMTelecom *telecom = [self telecomForIndex:indexPath.row];
        NSAttributedString *attributedString = [telecom descriptionAsMutableAttributedStringWithBaseFontSize:15.0];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.attributedText = attributedString;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WMTelecom *telecom = [self telecomForIndex:indexPath.row];
        [self.delegate.telecomSource removeTelecomsObject:telecom];
        _telecoms = nil;
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [self.tableView endUpdates];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        [self addAction:nil];
    }
}

// FRC did not work
// 2014-02-20 14:04:49.272 WoundMapUS[2323:70b] *** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: 'Cannot retrieve referenceObject from an objectID that was not created by this store'

@end
