//
//  WMCreateConsultingGroupViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 4/29/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMCreateConsultingGroupViewController.h"
#import "WMTextFieldTableViewCell.h"
#import "WMValue1TableViewCell.h"
#import "MBProgressHUD.h"
#import "WMParticipant.h"
#import "WMTeam.h"
#import "WMConsultingGroup.h"
#import "WMFatFractal.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"
#import "NSObject+performBlockAfterDelay.h"

@interface WMCreateConsultingGroupViewController () <UITextFieldDelegate>

@property (readonly, nonatomic) WMTeam *team;
@property (strong, nonatomic) WMConsultingGroup *consultingGroup;

@property (strong, nonatomic) NSString *consultingGroupNameInput;
@property (strong, nonatomic) NSString *websiteInput;

- (IBAction)cancelAction:(id)sender;
- (IBAction)createConsultingGroupAction:(id)sender;

@end

@implementation WMCreateConsultingGroupViewController

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
    self.title = @"Create Consulting Group";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(createConsultingGroupAction:)];
    [self.tableView registerClass:[WMTextFieldTableViewCell class] forCellReuseIdentifier:@"TextCell"];
    [self.tableView registerClass:[WMValue1TableViewCell class] forCellReuseIdentifier:@"ValueCell"];
    // initialize
    _consultingGroupNameInput = self.consultingGroup.name;
    _websiteInput = self.consultingGroup.webURL;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Accessors

- (WMTeam *)team
{
    return self.appDelegate.participant.team;
}
- (WMConsultingGroup *)consultingGroup
{
    if (nil == _consultingGroup) {
        _consultingGroup = [WMConsultingGroup MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"team == %@", self.team] inContext:self.managedObjectContext];
        if (nil == _consultingGroup) {
            _consultingGroup = [WMConsultingGroup MR_createInContext:self.managedObjectContext];
        }
    }
    return _consultingGroup;
}

#pragma mark - Core

- (NSString *)cellReuseIdentifier:(NSIndexPath *)indexPath
{
    NSString *cellReuseIdentifier = nil;
    switch (indexPath.section) {
        case 0: {
            cellReuseIdentifier = @"TextCell";
            break;
        }
        case 1: {
            cellReuseIdentifier = @"TextCell";
            break;
        }
        case 2: {
            cellReuseIdentifier = @"ValueCell";
            break;
        }
    }
    return cellReuseIdentifier;
}

- (BOOL)hasSufficientInput
{
    return ([_consultingGroupNameInput length] > 3 && [_websiteInput length] > 9);
}

- (void)updateNavigation
{
    if (self.hasSufficientInput) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

#pragma mark - Actions

- (IBAction)cancelAction:(id)sender
{
    [self.managedObjectContext rollback];
    [self.delegate createConsultantViewControllerDidCancel:self];
}

- (IBAction)createConsultingGroupAction:(id)sender
{
    [self.view endEditing:YES];
    WMTeam *team = self.team;
    WMConsultingGroup *consultingGroup = self.consultingGroup;
    consultingGroup.name = _consultingGroupNameInput;
    consultingGroup.webURL = _websiteInput;
    consultingGroup.team = team;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES].labelText = @"Building Consulting Group...";
    __weak __typeof(&*self)weakSelf = self;
    FFHttpMethodCompletion onCompleteUpdate = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        [weakSelf.delegate createConsultantViewControllerDidFinish:weakSelf];
    };
    FFHttpMethodCompletion onComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        [ff updateObj:team onComplete:onCompleteUpdate onOffline:onCompleteUpdate];
    };
    [managedObjectContext saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (error) {
            [WMUtilities logError:error];
        } else {
            [ff createObj:consultingGroup
                    atUri:[NSString stringWithFormat:@"/%@", [WMConsultingGroup entityName]]
               onComplete:onComplete
                onOffline:onComplete];
        }
    }];
}

#pragma mark - WMBaseViewController

- (void)clearDataCache
{
    [super clearDataCache];
    _consultingGroup = nil;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    __weak __typeof(&*self)weakSelf = self;
    [self performBlock:^{
        switch (textField.tag) {
            case 1000: {
                weakSelf.consultingGroupNameInput = textField.text;
                break;
            }
            case 1001: {
                weakSelf.websiteInput = textField.text;
                break;
            }
        }
        [weakSelf updateNavigation];
    } afterDelay:0.1];
    return YES;
}

// called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[WMTextFieldTableViewCell class]]) {
        WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
        [myCell.textField becomeFirstResponder];
        return nil;
    }
    // else
    return indexPath;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    switch (section) {
        case 0: {
            count = 1;
            break;
        }
        case 1: {
            count = 1;
            break;
        }
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [self cellReuseIdentifier:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: {
            // consulting group name
            cell.accessoryType = UITableViewCellAccessoryNone;
            WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
            UITextField *textField = myCell.textField;
            textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            textField.spellCheckingType = UITextAutocorrectionTypeYes;
            textField.returnKeyType = UIReturnKeyDefault;
            textField.keyboardType = UIKeyboardTypeDefault;
            textField.delegate = self;
            textField.tag = 1000;
            [myCell updateWithLabelText:@"Group Name" valueText:_consultingGroupNameInput valuePrompt:@"Enter Consulting Group Name"];
            break;
        }
        case 1: {
            // web address
            cell.accessoryType = UITableViewCellAccessoryNone;
            WMTextFieldTableViewCell *myCell = (WMTextFieldTableViewCell *)cell;
            UITextField *textField = myCell.textField;
            textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            textField.spellCheckingType = UITextAutocorrectionTypeYes;
            textField.returnKeyType = UIReturnKeyDefault;
            textField.keyboardType = UIKeyboardTypeURL;
            textField.delegate = self;
            textField.tag = 1001;
            [myCell updateWithLabelText:@"Web Site" valueText:_websiteInput valuePrompt:@"Enter website URL"];
            break;
        }
    }
    
}

@end
