//
//  WMIdListViewController
//  WoundMapUS
//
//  Created by etreasure consulting LLC on 2/20/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMIdListViewController.h"
#import "WMIdEditorViewController.h"
#import "WMValue1TableViewCell.h"
#import "WMId.h"

@interface WMIdListViewController () <idEditorViewControllerDelegate>

@property (nonatomic) BOOL removeUndoManagerWhenDone;
@property (readonly, nonatomic) WMIdEditorViewController *idEditorViewController;
@property (strong, nonatomic) NSArray *ids;

- (BOOL)isAddIndexPath:(NSIndexPath *)indexPath;

@end

@implementation WMIdListViewController

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
    self.title = @"Identifiers";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneAction:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelAction:)];
    [self.tableView registerClass:[WMValue1TableViewCell class] forCellReuseIdentifier:@"ValueCell"];
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
    return self.delegate.managedObjectContext;
}

- (NSString *)cellReuseIdentifier:(NSIndexPath *)indexPath
{
    NSString *cellReuseIdentifier = @"ValueCell";
    if ([self isAddIndexPath:indexPath]) {
        cellReuseIdentifier = @"AddCell";
    }
    return cellReuseIdentifier;
}

- (BOOL)isAddIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row == [self.delegate.source.ids count];
}

- (WMId *)idForIndex:(NSInteger)index
{
    if (nil == _ids) {
        _ids = [[self.delegate.source.ids allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:YES]]];
    }
    return _ids[index];
}

- (WMIdEditorViewController *)idEditorViewController
{
    WMIdEditorViewController *idEditorViewController = [[WMIdEditorViewController alloc] initWithNibName:@"WMIdEditorViewController" bundle:nil];
    idEditorViewController.delegate = self;
    return idEditorViewController;
}

- (void)navigateToIdEditorForId:(WMId *)anId
{
    WMIdEditorViewController *idEditorViewController = self.idEditorViewController;
    idEditorViewController.anId = anId;
    [self.navigationController pushViewController:idEditorViewController animated:YES];
}

#pragma mark - Core

- (void)clearDataCache
{
    [super clearDataCache];
    _ids = nil;
}

#pragma mark - Actions

- (IBAction)addAction:(id)sender
{
    WMId *anId = [WMId MR_createInContext:self.managedObjectContext];
    [self navigateToIdEditorForId:anId];
}

- (IBAction)doneAction:(id)sender
{
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
    }
    if (_removeUndoManagerWhenDone) {
        self.managedObjectContext.undoManager = nil;
    }
    [self.delegate idListViewControllerDidFinish:self];
}

- (IBAction)cancelAction:(id)sender
{
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
        if (self.managedObjectContext.undoManager.canUndo) {
            // this should undo the insert of new id
            [self.managedObjectContext.undoManager undoNestedGroup];
        }
    }
    if (_removeUndoManagerWhenDone) {
        self.managedObjectContext.undoManager = nil;
    }
    [self.delegate idListViewControllerDidCancel:self];
}

#pragma mark - WMBaseViewController

#pragma mark - idEditorViewControllerDelegate

- (void)idEditorViewController:(WMIdEditorViewController *)viewController didEditId:(WMId *)anId
{
    [self.delegate.source addIdsObject:anId];
    [self.navigationController popViewControllerAnimated:YES];
    _ids = nil;
    [self.tableView reloadData];
    [viewController clearAllReferences];
}

- (void)idEditorViewControllerDidCancel:(WMIdEditorViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    [viewController clearAllReferences];
}

#pragma mark - UITableViewDelegate

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
        // add id
        [self addAction:nil];
    } else {
        // edit id
        [self navigateToIdEditorForId:[self idForIndex:indexPath.row]];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.delegate.source.ids count] + 1;
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
        cell.textLabel.text = @"Add ID";
    } else {
        WMId *anId = [self idForIndex:indexPath.row];
        cell.textLabel.text = anId.extension;
        cell.detailTextLabel.text = anId.root;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WMId *anId = [self idForIndex:indexPath.row];
        [self.delegate.source removeIdsObject:anId];
        _ids = nil;
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [self.tableView endUpdates];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        [self addAction:nil];
    }
}

@end
