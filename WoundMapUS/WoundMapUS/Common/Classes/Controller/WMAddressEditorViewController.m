//
//  WMAddressEditorViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/20/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMAddressEditorViewController.h"
#import "WMTextFieldTableViewCell.h"
#import "WMValue1TableViewCell.h"
#import "WMAddress.h"
#import "CoreDataHelper.h"
#import "WMUtilities.h"

@interface WMAddressEditorViewController () <UITextFieldDelegate>

@property (strong, nonatomic) NSManagedObjectContext *childManagedObjectContext;

@end

@implementation WMAddressEditorViewController

@synthesize address=_address;

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
    self.title = @"Address Details";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneAction:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelAction:)];
    [self.tableView registerClass:[WMTextFieldTableViewCell class] forCellReuseIdentifier:@"TextCell"];
    [self.tableView registerClass:[WMValue1TableViewCell class] forCellReuseIdentifier:@"ValueCell"];
    self.fetchPolicy = SMFetchPolicyCacheOnly;
    self.savePolicy = SMSavePolicyCacheOnly;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core

- (NSManagedObjectContext *)childManagedObjectContext
{
    if (nil == _childManagedObjectContext) {
        _childManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _childManagedObjectContext.parentContext = self.delegate.managedObjectContext;
    }
    return _childManagedObjectContext;
}

- (WMAddress *)address
{
    if (nil == _address) {
        _address = [WMAddress instanceWithManagedObjectContext:self.childManagedObjectContext persistentStore:self.store];
    }
    return _address;
}

- (void)setAddress:(WMAddress *)address
{
    if (nil == address) {
        _address = nil;
    } else {
        _address = (WMAddress *)[self.childManagedObjectContext objectWithID:[address objectID]];
    }
}

- (NSString *)cellReuseIdentifier:(NSIndexPath *)indexPath
{
    NSString *cellReuseIdentifier = nil;
    switch (indexPath.row) {
        case 0: {
            // street
            cellReuseIdentifier = @"TextCell";
            break;
        }
        case 1: {
            // street 1
            cellReuseIdentifier = @"TextCell";
            break;
        }
        case 2: {
            // city
            cellReuseIdentifier = @"TextCell";
            break;
        }
        case 3: {
            // state
            cellReuseIdentifier = @"TextCell";
            break;
        }
        case 4: {
            // postalCode
            cellReuseIdentifier = @"TextCell";
            break;
        }
        case 5: {
            // country
            cellReuseIdentifier = @"TextCell";
            break;
        }
    }
    return cellReuseIdentifier;
}

#pragma mark - Actions

- (IBAction)doneAction:(id)sender
{
    [self.view endEditing:YES];
    NSError *error = nil;
    BOOL success = [self.childManagedObjectContext save:&error];
    if (!success) {
        [WMUtilities logError:error];
    }
    WMAddress *address = (WMAddress *)[self.delegate.managedObjectContext objectWithID:[_address objectID]];
    [self.delegate addressEditorViewController:self didEditAddress:address];
}

- (IBAction)cancelAction:(id)sender
{
    [self.delegate addressEditorViewControllerDidCancel:self];
}

#pragma mark - WMBaseViewController

- (void)clearDataCache
{
    [super clearDataCache];
    _address = nil;
}

#pragma mark - UITextFieldDelegate

// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    UITableViewCell *cell = [self cellForView:textField];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    switch (indexPath.row) {
        case 0: {
            // street
            self.address.streetAddressLine = textField.text;
            break;
        }
        case 1: {
            // street 1
            self.address.streetAddressLine1 = textField.text;
            break;
        }
        case 2: {
            // city
            self.address.city = textField.text;
            break;
        }
        case 3: {
            // state
            self.address.state = textField.text;
            break;
        }
        case 4: {
            // postalCode
            self.address.postalCode = textField.text;
            break;
        }
        case 5: {
            // country
            self.address.country = textField.text;
            break;
        }
    }
}

#pragma mark - UITableViewDelegate

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // navigate to address
    // navigate to telecoms
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
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
            // street
            WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
            [myCell updateWithLabelText:@"Street" valueText:self.address.streetAddressLine valuePrompt:@"1 Somestreet"];
            break;
        }
        case 1: {
            // street
            WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
            [myCell updateWithLabelText:@"Street" valueText:self.address.streetAddressLine1 valuePrompt:@"Suite 100"];
            break;
        }
        case 2: {
            // city
            WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
            [myCell updateWithLabelText:@"City" valueText:self.address.city valuePrompt:@"Some City"];
            break;
        }
        case 3: {
            // state
            WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
            [myCell updateWithLabelText:@"State" valueText:self.address.state valuePrompt:@"WY"];
            break;
        }
        case 4: {
            // postalCode
            WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
            [myCell updateWithLabelText:@"Postal Code" valueText:self.address.postalCode valuePrompt:@"82801"];
            break;
        }
        case 5: {
            // country
            WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
            [myCell updateWithLabelText:@"Country" valueText:self.address.country valuePrompt:@"US"];
            break;
        }
    }
}

@end
