//
//  WMIdListViewController
//  WoundMapUS
//
//  Created by etreasure consulting LLC on 2/20/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMIdListViewController.h"
#import "WMIdEditorViewController.h"
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
    return self.delegate.managedObjectContext;
}

- (BOOL)isAddIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row == [self.delegate.source.ids count];
}

- (WMIdEditorViewController *)idEditorViewController
{
    WMIdEditorViewController *idEditorViewController = [[WMIdEditorViewController alloc] initWithNibName:@"WMIdEditorViewController" bundle:nil];
    idEditorViewController.delegate = self;
    return idEditorViewController;
}

- (void)navigateToIdEditorForAddress:(WMId *)anId
{
    WMIdEditorViewController *idEditorViewController = self.idEditorViewController;
    idEditorViewController.anId = anId;
    [self.navigationController pushViewController:idEditorViewController animated:YES];
}

#pragma mark - Actions

- (IBAction)addAction:(id)sender
{
    WMId *anId = [WMId instanceWithManagedObjectContext:self.managedObjectContext persistentStore:nil];
    [self navigateToIdEditorForAddress:anId];
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
            // this should undo the insert of new person
            [self.managedObjectContext.undoManager undoNestedGroup];
        }
    }
    if (_removeUndoManagerWhenDone) {
        self.managedObjectContext.undoManager = nil;
    }
    [self.delegate idListViewControllerDidCancel:self];
}

#pragma mark - idEditorViewControllerDelegate

- (void)idEditorViewController:(WMIdEditorViewController *)viewController didEditId:(WMId *)anId
{
    
}

- (void)idEditorViewControllerDidCancel:(WMIdEditorViewController *)viewController
{
    
}

@end
