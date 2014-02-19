//
//  WMPersonEditorViewController.m
//  WoundMapUS
//
//  Created by etreasure consulting LLC on 2/17/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMPersonEditorViewController.h"
#import "WMValue1TableViewCell.h"
#import "WMTextFieldTableViewCell.h"
#import "WMPerson.h"
#import "CoreDataHelper.h"
#import "WMUtilities.h"

@interface WMPersonEditorViewController () <UITextFieldDelegate>

- (NSString *)cellReuseIdentifier:(NSIndexPath *)indexPath;

@end

@implementation WMPersonEditorViewController

@synthesize person=_person;

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
    self.title = @"Contact Details";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneAction:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                           target:self
                                                                                           action:@selector(cancelAction:)];
    [self.tableView registerClass:[WMTextFieldTableViewCell class] forCellReuseIdentifier:@"TextCell"];
    [self.tableView registerClass:[WMValue1TableViewCell class] forCellReuseIdentifier:@"ValueCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core

- (WMPerson *)person
{
    if (nil == _person) {
        _person = [WMPerson instanceWithManagedObjectContext:self.managedObjectContext persistentStore:self.store];
    }
    return _person;
}

- (NSString *)cellReuseIdentifier:(NSIndexPath *)indexPath
{
    NSString *cellReuseIdentifier = nil;
    switch (indexPath.row) {
        case 0: {
            // prefix
            cellReuseIdentifier = @"TextCell";
            break;
        }
        case 1: {
            // given name
            cellReuseIdentifier = @"TextCell";
            break;
        }
        case 2: {
            // family name
            cellReuseIdentifier = @"TextCell";
            break;
        }
        case 3: {
            // suffix
            cellReuseIdentifier = @"TextCell";
            break;
        }
        case 4: {
            // addresses
            cellReuseIdentifier = @"ValueCell";
            break;
        }
        case 5: {
            // telecoms
            cellReuseIdentifier = @"ValueCell";
            break;
        }
    }
    return cellReuseIdentifier;
}

#pragma mark - Actions

- (IBAction)doneAction:(id)sender
{
    [self.view endEditing:YES];
    [self.delegate personEditorViewController:self didEditPerson:_person];
}

- (IBAction)cancelAction:(id)sender
{
    [self.delegate personEditorViewControllerDidCancel:self];
}

#pragma mark - WMBaseViewController

- (void)clearDataCache
{
    [super clearDataCache];
    _person = nil;
}

#pragma mark - UITextFieldDelegate

// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    UITableViewCell *cell = [self cellForView:textField];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    switch (indexPath.row) {
        case 0: {
            // prefix
            self.person.namePrefix = textField.text;
            break;
        }
        case 1: {
            // given name
            self.person.nameGiven = textField.text;
            break;
        }
        case 2: {
            // family name
            self.person.nameFamily = textField.text;
            break;
        }
        case 3: {
            // suffix
            self.person.nameSuffix = textField.text;
            break;
        }
    }
}

// return NO to not change text
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    return YES;
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
            // prefix
            WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
            [myCell updateWithLabelText:@"Prefix" valueText:self.person.namePrefix valuePrompt:@"Dr, Mr, Ms, etc"];
            break;
        }
        case 1: {
            // given name
            WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
            [myCell updateWithLabelText:@"Given Name" valueText:self.person.nameGiven valuePrompt:@"Given or First Name"];
            break;
        }
        case 2: {
            // family name
            WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
            [myCell updateWithLabelText:@"Family Name" valueText:self.person.nameFamily valuePrompt:@"Family or Last Name"];
            break;
        }
        case 3: {
            // suffix
            WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
            [myCell updateWithLabelText:@"Suffix" valueText:self.person.nameSuffix valuePrompt:@"III, Esquire, etc"];
            break;
        }
        case 4: {
            // addresses
            cell.textLabel.text = @"Addresses";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case 5: {
            // telecoms
            cell.textLabel.text = @"Telecoms";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
    }
}

@end
