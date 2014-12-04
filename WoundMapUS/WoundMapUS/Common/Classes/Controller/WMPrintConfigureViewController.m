//
//  WMPrintConfigureViewController.m
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 2/24/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//

#import "WMPrintConfigureViewController.h"
#import "MBProgressHUD.h"
#import "WMParticipant.h"
#import "WMPatient.h"
#import "WMWound.h"
#import "WMWoundPhoto.h"
#import "UIView+Custom.h"
#import "PrintConfiguration.h"
#import "WMPDFPrintManager.h"
#import "WMUserDefaultsManager.h"
#import "WMFatFractal.h"
#import "WMDesignUtilities.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"

#define kInsufficientDataForReport 1000

@interface WMPrintConfigureViewController () <UIAlertViewDelegate>

@property (readonly, nonatomic) BOOL hasSelectedWounds;
@property (strong, nonatomic) NSMutableSet *selectedWounds;
@property (readonly, nonatomic) NSArray *sortedSelectedWounds;
@property (strong, nonatomic) WMWound *selectedWound;
@property (strong, nonatomic) UISwitch *selectAllWoundsSwitch;
@property (strong, nonatomic) UISwitch *printRiskAssessmentSwitch;
@property (strong, nonatomic) UISwitch *printSkinAssessmentSwitch;
@property (strong, nonatomic) UISwitch *printCarePlanSwitch;
@property (nonatomic) PrintTemplate printTemplate;
@property (strong, nonatomic) NSMutableDictionary *selectedWoundPhotosMap;
@property (strong, nonatomic) NSArray *sortedWounds;
@property (strong, nonatomic) IBOutlet UITableViewCell *passwordCell;
@property (strong, nonatomic) NSString *password;
@property (readonly, nonatomic) BOOL printRiskAssessment;
@property (readonly, nonatomic) BOOL printSkinAssessment;
@property (readonly, nonatomic) BOOL printCarePlan;
@property (readonly, nonatomic) WMSelectWoundPhotoViewController *selectWoundPhotoViewController;

@end

@interface WMPrintConfigureViewController (PrivateMethods)
- (NSArray *)sortedWoundPhotosForWound:(WMWound *)wound;
- (void)updateUI;
- (BOOL)indexPathIsPasswordCell:(NSIndexPath *)indexPath;
@end

@implementation WMPrintConfigureViewController (PrivateMethods)

- (NSArray *)sortedWoundPhotosForWound:(WMWound *)wound
{
    NSArray *woundPhotos = [[self.selectedWoundPhotosMap objectForKey:[wound objectID]] allObjects];
    return [woundPhotos sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]]];
}

- (void)updateUI
{
    BOOL nextButtonEnabled = YES;
    if (!self.hasSelectedWounds) {
        nextButtonEnabled = NO;
    }
    if ([self.selectedWounds count] < [self.patient.wounds count]) {
        self.selectAllWoundsSwitch.on = NO;
    }
    self.navigationItem.rightBarButtonItem.enabled = nextButtonEnabled;
}

- (BOOL)indexPathIsPasswordCell:(NSIndexPath *)indexPath
{
    if (!self.delegate.shouldRequestPassword || !self.hasSelectedWounds) {
        return NO;
    }
    // else
    NSInteger section = indexPath.section;
    if (!self.patient.hasMultipleWounds) {
        ++section;
    }
    WMPDFPrintManager *pdfPrintManager = [WMPDFPrintManager sharedInstance];
    if (!pdfPrintManager.hasMoreThanOneTemplate) {
        ++section;
    }
    return section == 2;
}

@end

@implementation WMPrintConfigureViewController

@synthesize delegate;
@synthesize selectedWounds=_selectedWounds, selectedWound=_selectedWound, printTemplate=_printTemplate, selectedWoundPhotosMap=_selectedWoundPhotosMap, sortedWounds=_sortedWounds;
@synthesize selectAllWoundsSwitch=_selectAllWoundsSwitch, printSkinAssessmentSwitch=_printSkinAssessmentSwitch, printRiskAssessmentSwitch=_printRiskAssessmentSwitch;
@dynamic sortedSelectedWounds, hasSelectedWounds;
@synthesize passwordCell=_passwordCell, password=_password;
@dynamic printRiskAssessment, printSkinAssessment, printCarePlan;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Print Configuration";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(nextAction:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    // get wounds
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    [MBProgressHUD showHUDAddedToViewController:self animated:YES].labelText = @"Acquiring latest wound data";
    WMPatient *patient = self.patient;
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    __weak __typeof(&*self)weakSelf = self;
    [ff getArrayFromUri:[NSString stringWithFormat:@"%@/%@?depthGb=2&depthRef=1", patient.ffUrl, WMPatientRelationships.wounds] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:NO];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUI];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.hasSelectedWounds) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Insufficient data"
                                                            message:@"The patient does not have enough data to generate a report."
                                                           delegate:self
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        alertView.tag = kInsufficientDataForReport;
        [alertView show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Add code to clean up any of your own resources that are no longer necessary.
}

// clear any strong references to views
- (void)clearViewReferences
{
    [super clearViewReferences];
    _passwordCell = nil;
    _selectAllWoundsSwitch = nil;
    _printRiskAssessmentSwitch = nil;
    _printSkinAssessmentSwitch = nil;
    _printCarePlanSwitch = nil;
}

#pragma mark - Core

- (WMSelectWoundPhotoViewController *)selectWoundPhotoViewController
{
    WMSelectWoundPhotoViewController *selectWoundPhotoViewController  = [[WMSelectWoundPhotoViewController alloc] initWithNibName:@"WMSelectWoundPhotoViewController" bundle:nil];
    selectWoundPhotoViewController.delegate = self;
    return selectWoundPhotoViewController;
}

- (void)setPrintTemplate:(PrintTemplate)printTemplate
{
    if (_printTemplate == printTemplate) {
        return;
    }
    // else
    [self willChangeValueForKey:@"printTemplate"];
    _printTemplate = printTemplate;
    [self didChangeValueForKey:@"printTemplate"];
    [self.tableView reloadData];
}

- (BOOL)hasSelectedWounds
{
    return [self.selectedWounds count] > 0;
}

- (NSMutableSet *)selectedWounds
{
    if (nil == _selectedWounds) {
        _selectedWounds = [[NSMutableSet alloc] initWithCapacity:16];
        id obj = self.patient.lastActiveWound;
        if (obj) {
            [_selectedWounds addObject:obj];
        }
    }
    return _selectedWounds;
}

- (NSArray *)sortedSelectedWounds
{
    return [[self.selectedWounds allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]]];
}

- (NSMutableDictionary *)selectedWoundPhotosMap
{
    if (nil == _selectedWoundPhotosMap) {
        _selectedWoundPhotosMap = [[NSMutableDictionary alloc] initWithCapacity:16];
    }
    return _selectedWoundPhotosMap;
}

- (NSArray *)sortedWounds
{
    if (nil == _sortedWounds) {
        _sortedWounds = [[NSArray alloc] initWithArray:self.patient.sortedWounds];
    }
    return _sortedWounds;
}

- (NSString *)password
{
    if (nil == _password && self.delegate.shouldRequestPassword) {
        _password = self.userDefaultsManager.encryptionPassword;
    }
    return _password;
}

- (void)setPassword:(NSString *)password
{
    if (_password == password) {
        return;
    }
    // else
    [self willChangeValueForKey:@"password"];
    _password = password;
    [self didChangeValueForKey:@"password"];
    if ([password length] > 0) {
        self.userDefaultsManager.encryptionPassword = _password;
    }
}

- (BOOL)printRiskAssessment
{
    return self.printRiskAssessmentSwitch.isOn;
}

- (BOOL)printSkinAssessment
{
    return self.printSkinAssessmentSwitch.isOn;
}

- (BOOL)printCarePlan
{
    return self.printCarePlanSwitch.isOn;
}

#pragma mark - BaseViewController

- (void)clearDataCache
{
    [super clearDataCache];
    _selectedWounds = nil;
    _selectedWound = nil;
    _selectedWoundPhotosMap = nil;
    _sortedWounds = nil;
}

#pragma mark - Actions

- (IBAction)allWoundsSwitchValueChangedAction:(id)sender
{
    UISwitch *aSwitch = (UISwitch *)sender;
    if (aSwitch.isOn) {
        [self.selectedWounds addObjectsFromArray:[self.patient.wounds allObjects]];
    } else {
        [self.selectedWounds removeAllObjects];
    }
    [self updateUI];
    [self.tableView reloadData];
}

- (IBAction)printRiskAssessmentValueChangedAction:(id)sender
{
    // nothing
}

- (IBAction)printSkinAssessmentValueChangedAction:(id)sender
{
    // nothing
}

- (IBAction)printCarePlanValueChangedAction:(id)sender
{
    // nothing
}

- (IBAction)cancelAction:(id)sender
{
    [self.delegate printConfigureViewControllerDidCancel:self];
}

- (IBAction)nextAction:(id)sender
{
    [self.view endEditing:YES];
    if (self.delegate.shouldRequestPassword && [_password length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Password is Required"
                                                            message:@"A password is required to encrypt the attachment"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    // else make sure we have the data from back end
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    [MBProgressHUD showHUDAddedToViewController:self animated:YES].labelText = @"Updating Patient Data";
    WMPatient *patient = self.patient;
    WMParticipant *participant = self.appDelegate.participant;
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    __weak __typeof(&*self)weakSelf = self;
    __block NSInteger counter = 0;
    FFHttpMethodCompletion onComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        if (counter == 0 || --counter == 0) {
            [managedObjectContext MR_saveToPersistentStoreAndWait];
            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:NO];
            PrintConfiguration *printConfiguration = [[PrintConfiguration alloc] init];
            printConfiguration.printTemplate = weakSelf.printTemplate;
            printConfiguration.selectedWoundPhotosMap = weakSelf.selectedWoundPhotosMap;
            printConfiguration.managedObjectContext = weakSelf.managedObjectContext;
            printConfiguration.password = weakSelf.password;
            printConfiguration.printRiskAssessment = weakSelf.printRiskAssessment;
            printConfiguration.printSkinAssessment = weakSelf.printSkinAssessment;
            printConfiguration.printCarePlan = weakSelf.printCarePlan;
            [weakSelf.delegate printConfigureViewController:weakSelf
                    didConfigurePrintWithConfigureation:printConfiguration
                                      fromBarButtonItem:nil];
        }
    };
    if (nil == participant.team) {
        onComplete(nil, nil, nil);
    } else {
        ++counter;
        [ff getArrayFromUri:[NSString stringWithFormat:@"%@/%@?depthGb=1&depthRef=1", patient.ffUrl, WMPatientRelationships.medicalHistoryGroups] onComplete:onComplete];
        if (self.printSkinAssessment) {
            ++counter;
            [ff getArrayFromUri:[NSString stringWithFormat:@"%@/%@?depthGb=2&depthRef=1", patient.ffUrl, WMPatientRelationships.skinAssessmentGroups] onComplete:onComplete];
        }
        if (self.printRiskAssessment) {
            counter += 4;
            [ff getArrayFromUri:[NSString stringWithFormat:@"%@/%@?depthGb=2&depthRef=1", patient.ffUrl, WMPatientRelationships.bradenScales] onComplete:onComplete];
            [ff getArrayFromUri:[NSString stringWithFormat:@"%@/%@?depthGb=2&depthRef=1", patient.ffUrl, WMPatientRelationships.medicationGroups] onComplete:onComplete];
            [ff getArrayFromUri:[NSString stringWithFormat:@"%@/%@?depthGb=2&depthRef=1", patient.ffUrl, WMPatientRelationships.deviceGroups] onComplete:onComplete];
            [ff getArrayFromUri:[NSString stringWithFormat:@"%@/%@?depthGb=2&depthRef=1", patient.ffUrl, WMPatientRelationships.psychosocialGroups] onComplete:onComplete];
        }
        if (self.printCarePlan) {
            ++counter;
            [ff getArrayFromUri:[NSString stringWithFormat:@"%@/%@?depthGb=4&depthRef=1", patient.ffUrl, WMPatientRelationships.carePlanGroups] onComplete:onComplete];
        }
        NSSet *selectedWounds = self.selectedWounds;
        counter += [selectedWounds count] * 2;
        for (WMWound *wound in selectedWounds) {
            [ff getArrayFromUri:[NSString stringWithFormat:@"%@/%@?depthGb=1&depthRef=1", wound.ffUrl, WMWoundRelationships.measurementGroups] onComplete:onComplete];
            [ff getArrayFromUri:[NSString stringWithFormat:@"%@/%@?depthGb=1&depthRef=1", wound.ffUrl, WMWoundRelationships.treatmentGroups] onComplete:onComplete];
        }
        NSArray *woundPhotoSets = [self.selectedWoundPhotosMap allValues];
        for (NSSet *woundPhotoSet in woundPhotoSets) {
            for (WMWoundPhoto *woundPhoto in woundPhotoSet) {
                if (nil == woundPhoto.thumbnailLarge) {
                    ++counter;
                    [[[ff newReadRequest] prepareGetFromUri:[NSString stringWithFormat:@"%@/%@", woundPhoto.ffUrl, WMWoundPhotoAttributes.thumbnailLarge]] executeAsyncWithBlock:^(FFReadResponse *response) {
                        NSData *photoData = [response rawResponseData];
                        woundPhoto.thumbnailLarge = [[UIImage alloc] initWithData:photoData];
                        onComplete(nil, nil, nil);
                    }];
                }
            }
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kInsufficientDataForReport) {
        [self cancelAction:nil];
    }
}

#pragma mark - SelectWoundPhotoViewControllerDelegate

- (NSArray *)selectedWoundPhotos
{
    return [[self.selectedWoundPhotosMap objectForKey:[self.selectedWound objectID]] allObjects];
}

- (void)selectWoundPhotoViewController:(WMSelectWoundPhotoViewController *)viewController didSelectWoundPhotos:(NSArray *)woundPhotos
{
    [self.selectedWoundPhotosMap setObject:[[NSMutableSet alloc] initWithArray:woundPhotos] forKey:[self.selectedWound objectID]];
    [self.navigationController popViewControllerAnimated:YES];
    [self updateUI];
    // clear cache
    [viewController clearAllReferences];
}

- (void)selectWoundPhotoViewControllerDidCancel:(WMSelectWoundPhotoViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    // clear cache
    [viewController clearAllReferences];
}

#pragma mark - UITextFieldDelegate

// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.password = textField.text;
}

// called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITableViewDelegate

// return 'depth' of row for hierarchies
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger depth = 0;
    NSInteger section = indexPath.section;
    if (!self.patient.hasMultipleWounds) {
        ++section;
    }
    WMPDFPrintManager *pdfPrintManager = [WMPDFPrintManager sharedInstance];
    if (!pdfPrintManager.hasMoreThanOneTemplate) {
        ++section;
    }
    if (!self.delegate.shouldRequestPassword) {
        ++section;
    }
    if (!self.delegate.hasRiskAssessment && !self.delegate.hasSkinAssessment && !self.delegate.hasCarePlan) {
        ++section;
    }
    if (section > 3 && indexPath.row > 0) {
        depth = 1;
    }
    return depth;
}

// Returning NO to that message halts the selection process and does not cause the currently selected row to lose its selected look while the touch is down.
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    BOOL sectionDeterminedFlag = NO;
    BOOL returnNilFlag = NO;
    if (!self.patient.hasMultipleWounds) {
        // skip select wounds
        ++section;
    } else if (section == 0) {
        sectionDeterminedFlag = YES;
        returnNilFlag = indexPath.row == 0;
    }
    WMPDFPrintManager *pdfPrintManager = [WMPDFPrintManager sharedInstance];
    if (!pdfPrintManager.hasMoreThanOneTemplate && !sectionDeterminedFlag) {
        // skip select template
        ++section;
    } else if (section == 1) {
        sectionDeterminedFlag = YES;
    }
    if (!self.delegate.shouldRequestPassword && !sectionDeterminedFlag) {
        // skip password
        ++section;
    } else if (section == 2) {
        returnNilFlag = YES;
        sectionDeterminedFlag = YES;
    }
    if (!self.delegate.hasRiskAssessment && !self.delegate.hasSkinAssessment && !self.delegate.hasCarePlan && !sectionDeterminedFlag) {
        // skip options
        ++section;
    } else if (section == 3) {
        returnNilFlag = YES;
        sectionDeterminedFlag = YES;
    }
    if (indexPath.section > 3 && !sectionDeterminedFlag) {
        // must be wound photo
        returnNilFlag = indexPath.row > 0;
    }
    return (returnNilFlag ? nil:indexPath);
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // be sure to nil the _sortedWoundPhotos if selecting a woundPhoto to print and updateUI
    NSInteger section = indexPath.section;
    BOOL sectionDeterminedFlag = NO;
    if (!self.patient.hasMultipleWounds) {
        // skip select wounds
        ++section;
    } else if (section == 0) {
        sectionDeterminedFlag = YES;
    }
    WMPDFPrintManager *pdfPrintManager = [WMPDFPrintManager sharedInstance];
    if (!pdfPrintManager.hasMoreThanOneTemplate && !sectionDeterminedFlag) {
        // skip select template
        ++section;
    } else if (section == 1) {
        sectionDeterminedFlag = YES;
    }
    if (!self.delegate.shouldRequestPassword && !sectionDeterminedFlag) {
        // skip password
        ++section;
    } else if (section == 2) {
        sectionDeterminedFlag = YES;
    }
    if (!self.delegate.hasRiskAssessment && !self.delegate.hasSkinAssessment && !self.delegate.hasCarePlan && !sectionDeterminedFlag) {
        // skip options
        ++section;
    } //else if (section == 3) {
//        sectionDeterminedFlag = YES;
//    }
    switch (section) {
        case 0: {
            // wound
            WMWound *wound = [self.sortedWounds objectAtIndex:(indexPath.row - 1)];
            if ([self.selectedWounds containsObject:wound]) {
                [self.selectedWounds removeObject:wound];
            } else {
                [self.selectedWounds addObject:wound];
            }
            [tableView reloadData];
            [self updateUI];
            break;
        }
        case 1: {
            // template
            self.printTemplate = indexPath.row;
            [tableView reloadData];
            break;
        }
        case 2: {
            // password
            break;
        }
        case 3: {
            // assessment options
            break;
        }
        default: {
            // photos
            self.selectedWound = [self.sortedSelectedWounds objectAtIndex:(section - 4)];
            if (indexPath.row == 0) {
                // select photo
                [self.navigationController pushViewController:self.selectWoundPhotoViewController animated:YES];
            }
            break;
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if (!self.patient.hasMultipleWounds) {
        ++section;
    }
    WMPDFPrintManager *pdfPrintManager = [WMPDFPrintManager sharedInstance];
    if (!pdfPrintManager.hasMoreThanOneTemplate) {
        ++section;
    }
    if (!self.delegate.shouldRequestPassword) {
        ++section;
    }
    if (!self.delegate.hasRiskAssessment && !self.delegate.hasSkinAssessment && !self.delegate.hasCarePlan) {
        ++section;
    }
    return (section - 4) == 0 && indexPath.row > 0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSInteger section = indexPath.section;
        if (!self.patient.hasMultipleWounds) {
            ++section;
        }
        WMPDFPrintManager *pdfPrintManager = [WMPDFPrintManager sharedInstance];
        if (!pdfPrintManager.hasMoreThanOneTemplate) {
            ++section;
        }
        if (!self.delegate.shouldRequestPassword) {
            ++section;
        }
        if (!self.delegate.hasRiskAssessment && !self.delegate.hasSkinAssessment && !self.delegate.hasCarePlan) {
            ++section;
        }
        // delete the woundPhoto
        WMWound *wound = [self.sortedWounds objectAtIndex:(section - 4)];
        WMWoundPhoto *woundPhoto = [[self sortedWoundPhotosForWound:wound] objectAtIndex:(indexPath.row - 1)];
        NSMutableSet *set = [self.selectedWoundPhotosMap objectForKey:[wound objectID]];
        [set removeObject:woundPhoto];
        [tableView reloadData];
    }
}



#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (nil == self.managedObjectContext) {
        return 0;
    }
    // else
    NSInteger count = 0;
    if (self.patient.hasMultipleWounds) {
        // section to allow user to select wounds
        ++count;
    }
    if (!self.hasSelectedWounds) {
        // must select wounds first
        return count;
    }
    // else add template section
    WMPDFPrintManager *pdfPrintManager = [WMPDFPrintManager sharedInstance];
    if (pdfPrintManager.hasMoreThanOneTemplate) {
        ++count;
    }
    // add section for each selected wound
    count += [self.selectedWounds count];
    // option to password protect PDF
    count += (self.delegate.shouldRequestPassword ? 1:0);
    // check for Risk Assessment or Care Plan
    if (self.delegate.hasRiskAssessment || self.delegate.hasSkinAssessment || self.delegate.hasCarePlan) {
        ++count;
    }
    return count;
}

// fixed font style. use custom view (UILabel) if you want something different
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    BOOL sectionDeterminedFlag = NO;
    if (!self.patient.hasMultipleWounds) {
        // skip select wounds
        ++section;
    } else if (section == 0) {
        title = @"Select Wounds to Print";
        sectionDeterminedFlag = YES;
    }
    WMPDFPrintManager *pdfPrintManager = [WMPDFPrintManager sharedInstance];
    if (!pdfPrintManager.hasMoreThanOneTemplate && !sectionDeterminedFlag) {
        // skip select template
        ++section;
    } else if (section == 1) {
        title = @"Select Print Template";
        sectionDeterminedFlag = YES;
    }
    if (!self.delegate.shouldRequestPassword && !sectionDeterminedFlag) {
        // skip password
        ++section;
    } else if (section == 2) {
        title = (self.delegate.shouldRequestPassword ? @"Password":@"Optional Password");
    }
    if (!self.delegate.hasRiskAssessment && !self.delegate.hasSkinAssessment && !self.delegate.hasCarePlan && !sectionDeterminedFlag) {
        // skip section
        ++section;
    } else if (section == 3) {
        title = @"Select Options";
    }
    if ([title length] > 0) {
        return title;
    }
    // must be woundPhotos section
    WMWound *wound = [self.sortedSelectedWounds objectAtIndex:(section - 4)];
    return [NSString stringWithFormat:@"Select Wound Photos for '%@'", wound.shortName];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    BOOL sectionDeterminedFlag = NO;
    if (!self.patient.hasMultipleWounds) {
        // skip select wounds
        ++section;
    } else if (section == 0) {
        sectionDeterminedFlag = YES;
        count = ([self.patient.wounds count] + 1);
    }
    WMPDFPrintManager *pdfPrintManager = [WMPDFPrintManager sharedInstance];
    if (!pdfPrintManager.hasMoreThanOneTemplate && !sectionDeterminedFlag) {
        // skip select template
        ++section;
    } else if (section == 1) {
        sectionDeterminedFlag = YES;
        count = [pdfPrintManager.templateTitles count];
    }
    if (!self.delegate.shouldRequestPassword && !sectionDeterminedFlag) {
        // skip password
        ++section;
    } else if (section == 2) {
        sectionDeterminedFlag = YES;
        count = 1;
    }
    if (!self.delegate.hasRiskAssessment && !self.delegate.hasSkinAssessment && !self.delegate.hasCarePlan && !sectionDeterminedFlag) {
        // skip options
        ++section;
    } else if (section == 3) {
        if (self.delegate.hasRiskAssessment) {
            ++count;
        }
        if (self.delegate.hasSkinAssessment) {
            ++count;
        }
        if (self.delegate.hasCarePlan) {
            ++count;
        }
    }
    if (count > 0) {
        return count;
    }
    // else woundPhoto section - number of woundPhotos in each wound
    WMWound *wound = [self.sortedSelectedWounds objectAtIndex:(section - 4)];
    return ([[self.selectedWoundPhotosMap objectForKey:[wound objectID]] count] + 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        if ([self indexPathIsPasswordCell:indexPath]) {
            cell = self.passwordCell;
        } else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
    }
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    BOOL sectionDeterminedFlag = NO;
    if (!self.patient.hasMultipleWounds) {
        // skip select wounds
        ++section;
    } else if (section == 0) {
        sectionDeterminedFlag = YES;
    }
    WMPDFPrintManager *pdfPrintManager = [WMPDFPrintManager sharedInstance];
    if (!pdfPrintManager.hasMoreThanOneTemplate && !sectionDeterminedFlag) {
        // skip select template
        ++section;
    } else if (section == 1) {
        sectionDeterminedFlag = YES;
    }
    if (!self.delegate.shouldRequestPassword && !sectionDeterminedFlag) {
        // skip password
        ++section;
    } else if (section == 2) {
        sectionDeterminedFlag = YES;
    }
    if (!self.delegate.hasRiskAssessment && !self.delegate.hasSkinAssessment && !self.delegate.hasCarePlan && !sectionDeterminedFlag) {
        // skip options
        ++section;
    }
    switch (section) {
        case 0: {
            // wounds
            switch (row) {
                case 0: {
                    // select all cell
                    cell.textLabel.text = @"Select All Wounds";
                    id accessoryView = cell.accessoryView;
                    if (![accessoryView isKindOfClass:[UISwitch class]]) {
                        UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
                        aSwitch.onImage = [UIImage imageNamed:@"yesSwitch.png"];
                        aSwitch.offImage = [UIImage imageNamed:@"noSwitch.png"];
                        [aSwitch addTarget:self action:@selector(allWoundsSwitchValueChangedAction:) forControlEvents:UIControlEventValueChanged];
                        cell.accessoryView = aSwitch;
                        self.selectAllWoundsSwitch = aSwitch;
                    }
                    break;
                }
                default: {
                    WMWound *wound = [self.sortedWounds objectAtIndex:(indexPath.row - 1)];
                    cell.textLabel.text = wound.shortName;
                    cell.imageView.image = ([self.selectedWounds containsObject:wound] ? [WMDesignUtilities selectedWoundTableCellImage]:[WMDesignUtilities unselectedWoundTableCellImage]);
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    break;
                }
            }
            break;
        }
        case 1: {
            // templates
            WMPDFPrintManager *pdfPrintManager = [WMPDFPrintManager sharedInstance];
            NSString *templateTitle = [pdfPrintManager.templateTitles objectAtIndex:indexPath.row];
            cell.textLabel.text = templateTitle;
            cell.imageView.image = ([templateTitle isEqualToString:[pdfPrintManager templateTitleForPrintTemplate:self.printTemplate]] ? [WMDesignUtilities selectedWoundTableCellImage]:[WMDesignUtilities unselectedWoundTableCellImage]);
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 2: {
            // password
            UITextField *textField = (UITextField *)[cell.contentView viewWithTag:1000];
            textField.text = self.userDefaultsManager.encryptionPassword;
            self.password = textField.text;
            break;
        }
        case 3: {
            // options
            if (!self.delegate.hasRiskAssessment) {
                ++row;
            }
            if (row > 0 && !self.delegate.hasSkinAssessment) {
                ++row;
            }
            switch (row) {
                case 0: {
                    // Risk Assessment
                    cell.textLabel.text = @"Print Risk Assessment";
                    id accessoryView = cell.accessoryView;
                    if (![accessoryView isKindOfClass:[UISwitch class]]) {
                        UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
                        aSwitch.onImage = [UIImage imageNamed:@"yesSwitch.png"];
                        aSwitch.offImage = [UIImage imageNamed:@"noSwitch.png"];
                        [aSwitch addTarget:self action:@selector(printRiskAssessmentValueChangedAction:) forControlEvents:UIControlEventValueChanged];
                        cell.accessoryView = aSwitch;
                        self.printRiskAssessmentSwitch = aSwitch;
                    }
                    break;
                }
                case 1: {
                    // Skin Assessment
                    cell.textLabel.text = @"Print Skin Assessment";
                    id accessoryView = cell.accessoryView;
                    if (![accessoryView isKindOfClass:[UISwitch class]]) {
                        UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
                        aSwitch.onImage = [UIImage imageNamed:@"yesSwitch.png"];
                        aSwitch.offImage = [UIImage imageNamed:@"noSwitch.png"];
                        [aSwitch addTarget:self action:@selector(printSkinAssessmentValueChangedAction:) forControlEvents:UIControlEventValueChanged];
                        cell.accessoryView = aSwitch;
                        self.printSkinAssessmentSwitch = aSwitch;
                    }
                    break;
                }
                case 2: {
                    // Care Plan
                    cell.textLabel.text = @"Print Care Plan";
                    id accessoryView = cell.accessoryView;
                    if (![accessoryView isKindOfClass:[UISwitch class]]) {
                        UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
                        aSwitch.onImage = [UIImage imageNamed:@"yesSwitch.png"];
                        aSwitch.offImage = [UIImage imageNamed:@"noSwitch.png"];
                        [aSwitch addTarget:self action:@selector(printCarePlanValueChangedAction:) forControlEvents:UIControlEventValueChanged];
                        cell.accessoryView = aSwitch;
                        self.printCarePlanSwitch = aSwitch;
                    }
                    break;
                }
            }
            break;
        }
        default: {
            // wound photos
            WMWound *wound = [self.sortedSelectedWounds objectAtIndex:(section - 4)];
            switch (indexPath.row) {
                case 0: {
                    cell.textLabel.text = @"Select Photos";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
                default: {
                    NSArray *sortedWoundPhotos = [self sortedWoundPhotosForWound:wound];
                    WMWoundPhoto *woundPhoto = [sortedWoundPhotos objectAtIndex:(indexPath.row - 1)];
                    cell.textLabel.text = [NSString stringWithFormat:@"Photo taken %@", [NSDateFormatter localizedStringFromDate:woundPhoto.createdAt dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle]];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    break;
                }
            }
            break;
        }
    }
}

@end
