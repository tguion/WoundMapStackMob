//
//  WMBradenScaleViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBradenScaleViewController.h"
#import "WMBradenScaleInputViewController.h"
#import "WMPatient.h"
#import "WMBradenScale.h"
#import "WMFatFractalManager.h"
#import "WMUtilities.h"
#import "WMDesignUtilities.h"
#import "WCAppDelegate.h"

@interface WMBradenScaleViewController () <BradenScaleInputDelegate>

@property (readonly, nonatomic) WMBradenScaleInputViewController *bradenScaleInputViewController;
@property (nonatomic) BOOL didCancelBradenScaleEdit;
@property (nonatomic) BOOL didCreateBradenScale;

- (void)navigateToBradenScaleEditor:(BOOL)animated;

@end

@implementation WMBradenScaleViewController

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.modalInPopover = YES;
        self.preferredContentSize = CGSizeMake(320.0, 380.0);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	self.title = @"Braden Scales";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																						   target:self
																						   action:@selector(addBradenScaleAction:)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
    self.didCancelBradenScaleEdit = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core

- (WMBradenScaleInputViewController *)bradenScaleInputViewController
{
    WMBradenScaleInputViewController *bradenScaleInputViewController = [[WMBradenScaleInputViewController alloc] initWithNibName:@"WMBradenScaleInputViewController" bundle:nil];
    bradenScaleInputViewController.delegate = self;
    return bradenScaleInputViewController;
}

- (void)navigateToBradenScaleEditor:(BOOL)animated
{
    WMBradenScaleInputViewController *bradenScaleInputViewController = self.bradenScaleInputViewController;
    bradenScaleInputViewController.bradenScale = self.bradenScale;
	[self.navigationController pushViewController:bradenScaleInputViewController animated:animated];
}

#pragma mark - Actions

- (IBAction)addBradenScaleAction:(id)sender
{
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    NSAssert([self.patient.ffUrl length] > 0, @"Expected patient to be persisted to backend");
    NSAssert(ffm.isCacheEmpty, @"Expected ffm cache to be empty");
	self.bradenScale = [WMBradenScale createNewBradenScaleForPatient:self.patient];
    // prepare to create backend
    __weak __typeof(&*self)weakSelf = self;
    [ffm createObject:self.bradenScale
                ffUrl:[WMBradenScale entityName]
                   ff:ff
           addToQueue:NO
    completionHandler:^(NSError *error, NSManagedObject *object, BOOL signInRequired) {
        WMBradenScale *bradenScale = (WMBradenScale *)object;
        [[bradenScale managedObjectContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            if (error) {
                [WMUtilities logError:error];
            } else {
                [[WMFatFractal sharedInstance] queueGrabBagAddItemAtUri:bradenScale.ffUrl toObjAtUri:weakSelf.patient.ffUrl grabBagName:WMPatientRelationships.bradenScales];
            }
        }];
    }];
    self.didCreateBradenScale = YES;
    [self navigateToBradenScaleEditor:YES];
}

- (IBAction)doneAction:(id)sender
{
    [self.delegate bradenScaleControllerDidFinish:self];
}

#pragma mark - BaseViewController

- (void)clearDataCache
{
    [super clearDataCache];
    _bradenScale = nil;
}

#pragma mark - BradenScaleInputDelegate

- (void)bradenScaleInputController:(WMBradenScaleInputViewController *)viewController didFinishWithBradenScale:(WMBradenScale *)bradenScale
{
    // consider as cancel if no score
    if (bradenScale.scoreValue == 0) {
        [self bradenScaleInputControllerDidCancel:viewController];
        return;
    }
    // ele
    NSManagedObjectContext *managedObjectContext = [bradenScale managedObjectContext];
    [managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (error) {
            [WMUtilities logError:error];
        } else {
            WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
            [ffm submitOperationsToQueue];
            [self.navigationController popViewControllerAnimated:YES];
            self.didCreateBradenScale = NO;
        }
    }];
}

- (void)bradenScaleInputControllerDidCancel:(WMBradenScaleInputViewController *)viewController
{
    self.didCancelBradenScaleEdit = YES;
    if (self.didCreateBradenScale) {
        [self.managedObjectContext deleteObject:_bradenScale];
        _bradenScale = nil;
        [self.managedObjectContext MR_saveOnlySelfAndWait];
    }
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    [ffm clearOperationCache];
    [self.navigationController popViewControllerAnimated:YES];
    [self refetchDataForTableView];
    self.didCreateBradenScale = NO;
}

#pragma mark - NSFetchedResultsController

- (NSString *)fetchedResultsControllerEntityName
{
	return @"WMBradenScale";
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
	return nil;
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
	return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (nil == self.managedObjectContext) {
        return 0;
    }
    // else
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"BradenScaleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0];
    }
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	WMBradenScale *bradenScale = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *string = [NSDateFormatter localizedStringFromDate:bradenScale.createdAt dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    if (bradenScale.isClosed) {
        string = [string stringByAppendingFormat:@" (closed)"];
    }
	cell.textLabel.text = string;
	cell.detailTextLabel.text = (bradenScale.isScoredCalculated ?[NSString stringWithFormat:@"Score: %@", bradenScale.score]:@"Incomplete");
    cell.accessoryType = (bradenScale.isClosed ? UITableViewCellAccessoryNone:UITableViewCellAccessoryDisclosureIndicator);
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 44.0;
}

// Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WMBradenScale *bradenScale = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return (bradenScale.isClosed ? nil:indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	self.bradenScale = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (!self.bradenScale.isClosed) {
        // prepare back end
        WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        [ffm updateObject:self.bradenScale ff:ff addToQueue:NO completionHandler:nil];
        [self navigateToBradenScaleEditor:YES];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // delete the braden scale
        WMBradenScale *bradenScale = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSManagedObjectContext *managedObjectContext = [bradenScale managedObjectContext];
        [managedObjectContext deleteObject:bradenScale];
        WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
        [ffm deleteObject:bradenScale ff:[WMFatFractal sharedInstance] addToQueue:YES completionHandler:nil];
        [managedObjectContext MR_saveOnlySelfAndWait];
        self.fetchedResultsController = nil;
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
