//
//  WMIdEditorViewController.m
//  WoundMapUS
//
//  Created by etreasure consulting LLC on 2/20/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMIdEditorViewController.h"
#import "WMBarScanViewController.h"
#import "WMTextFieldTableViewCell.h"
#import "WMValue1TableViewCell.h"
#import "WMId.h"
#import "CoreDataHelper.h"
#import "WMFatFractal.h"
#import "WMUtilities.h"

@interface WMIdEditorViewController () <UITextFieldDelegate, BarScanViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *tableHeaderView;

@property (weak, nonatomic) NSManagedObjectContext *moc;
@property (nonatomic) BOOL removeUndoManagerWhenDone;

@property (readonly, nonatomic) WMBarScanViewController *barScanViewController;

- (IBAction)readBarCodeAction:(id)sender;

@end

@implementation WMIdEditorViewController


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
    self.title = @"ID Details";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneAction:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelAction:)];
    [self.tableView registerClass:[WMTextFieldTableViewCell class] forCellReuseIdentifier:@"TextCell"];
    [self.tableView registerClass:[WMValue1TableViewCell class] forCellReuseIdentifier:@"ValueCell"];
    self.tableView.tableHeaderView = _tableHeaderView;
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
    NSString *cellReuseIdentifier = nil;
    switch (indexPath.row) {
        case 0: {
            // extension
            cellReuseIdentifier = @"TextCell";
            break;
        }
        case 1: {
            // root
            cellReuseIdentifier = @"TextCell";
            break;
        }
    }
    return cellReuseIdentifier;
}

- (WMBarScanViewController *)barScanViewController
{
    WMBarScanViewController *viewController = [[WMBarScanViewController alloc] initWithNibName:@"WMBarScanViewController" bundle:nil];
    viewController.delegate = self;
    return viewController;
}

#pragma mark - Actions

- (IBAction)doneAction:(id)sender
{
    [self.view endEditing:YES];
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
    }
    if (_removeUndoManagerWhenDone) {
        self.managedObjectContext.undoManager = nil;
    }
    [self.delegate idEditorViewController:self didEditId:_anId];
}

- (IBAction)cancelAction:(id)sender
{
    [self.view endEditing:YES];
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
    [self.delegate idEditorViewControllerDidCancel:self];
}

- (IBAction)readBarCodeAction:(id)sender
{
    [self presentViewController:self.barScanViewController animated:YES completion:^{
        // nothing
    }];
}

#pragma mark - WMBaseViewController

- (void)clearDataCache
{
    [super clearDataCache];
    _anId = nil;
}

#pragma mark - BarScanViewControllerDelegate

- (void)barScanViewController:(WMBarScanViewController *)viewController didCaptureBarScan:(NSString *)barScanValue
{
    __weak __typeof(&*self)weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        weakSelf.anId.extension = barScanValue;
        [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (void)barScanViewControllerDidCancel:(WMBarScanViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

#pragma mark - UITextFieldDelegate

// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    UITableViewCell *cell = [self cellForView:textField];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    switch (indexPath.row) {
        case 0: {
            // extension
            self.anId.extension = textField.text;
            break;
        }
        case 1: {
            // street 1
            self.anId.root = textField.text;
            break;
        }
    }
}

#pragma mark - UITableViewDelegate

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [self cellReuseIdentifier:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if ([cell isKindOfClass:[WMTextFieldTableViewCell class]]) {
        WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
        myCell.textField.delegate = self;
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0: {
            // extension
            WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
            [myCell updateWithLabelText:@"Extension" valueText:self.anId.extension valuePrompt:@"ID extension"];
            break;
        }
        case 1: {
            // street
            WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
            [myCell updateWithLabelText:@"Root" valueText:self.anId.root valuePrompt:@"ID root"];
            break;
        }
    }
}

@end
