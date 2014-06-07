//
//  WMBradenScaleViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMBradenScaleViewController.h"
#import "WMBradenScaleInputViewController.h"
#import "MBProgressHUD.h"
#import "WMPatient.h"
#import "WMBradenScale.h"
#import "WMBradenSection.h"
#import "WMBradenCell.h"
#import "WMFatFractal.h"
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
    __weak __typeof(&*self)weakSelf = self;
    dispatch_block_t block = ^{
        WMBradenScaleInputViewController *bradenScaleInputViewController = weakSelf.bradenScaleInputViewController;
        bradenScaleInputViewController.newBradenScaleFlag = weakSelf.didCreateBradenScale;
        bradenScaleInputViewController.bradenScale = weakSelf.bradenScale;
        [weakSelf.navigationController pushViewController:bradenScaleInputViewController animated:animated];
    };
    // must make sure the sections and cells are downloaded
    if (self.bradenScale.ffUrl && [self.bradenScale.sections count] == 0) {
        NSManagedObjectContext *managedObjectContext = [self.bradenScale managedObjectContext];
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        __weak __typeof(&*self)weakSelf = self;
        [ff getObjFromUri:[NSString stringWithFormat:@"%@?depthGb=2", self.bradenScale.ffUrl] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
            [managedObjectContext MR_saveToPersistentStoreAndWait];
            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:NO];
            block();
        }];
    } else {
        block();
    }
}

#pragma mark - Actions

- (IBAction)addBradenScaleAction:(id)sender
{
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	_bradenScale = [WMBradenScale createNewBradenScaleForPatient:self.patient];
    __weak __typeof(&*self)weakSelf = self;
    FFHttpMethodCompletion onComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        [ff queueGrabBagAddItemAtUri:[object valueForKey:@"ffUrl"] toObjAtUri:weakSelf.patient.ffUrl grabBagName:WMPatientRelationships.bradenScales];
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        [weakSelf navigateToBradenScaleEditor:YES];
    };
    [ff createObj:_bradenScale
            atUri:[NSString stringWithFormat:@"/%@", [WMBradenScale entityName]]
       onComplete:onComplete onOffline:onComplete];
    self.didCreateBradenScale = YES;
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
    // else update back end
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    __block NSInteger counter = 0;
    __weak __typeof(&*self)weakSelf = self;
    FFHttpMethodCompletion updateHandler = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        if (counter == 0 || --counter == 0) {
            // save local
            NSManagedObjectContext *managedObjectContext = [bradenScale managedObjectContext];
            [managedObjectContext MR_saveToPersistentStoreAndWait];
            [weakSelf.navigationController popViewControllerAnimated:YES];
            weakSelf.didCreateBradenScale = NO;
        }
    };
    for (WMBradenSection *bradenSection in _bradenScale.sections) {
        ++counter;
        for (WMBradenCell *bradenCell in bradenSection.cells) {
            ++counter;
            [ff updateObj:bradenCell onComplete:updateHandler];
        }
        [ff updateObj:bradenSection onComplete:updateHandler];
    }
    ++counter;
    [ff updateObj:_bradenScale onComplete:updateHandler];
}

- (void)bradenScaleInputControllerDidCancel:(WMBradenScaleInputViewController *)viewController
{
    self.didCancelBradenScaleEdit = YES;
    if (self.didCreateBradenScale) {
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        NSError *error = nil;
        for (WMBradenSection *bradenSection in _bradenScale.sections) {
            for (WMBradenCell *bradenCell in bradenSection.cells) {
                [ff deleteObj:bradenCell error:&error];
                if (error) {
                    [WMUtilities logError:error];
                }
            }
            [ff deleteObj:bradenSection error:&error];
        }
        [ff deleteObj:_bradenScale error:&error];
        [self.managedObjectContext deleteObject:_bradenScale];
        _bradenScale = nil;
        [self.managedObjectContext MR_saveToPersistentStoreAndWait];
    }
    [self.navigationController popViewControllerAnimated:YES];
    [self refetchDataForTableView];
    self.didCreateBradenScale = NO;
    self.didCancelBradenScaleEdit = NO;
}

#pragma mark - NSFetchedResultsController

- (NSString *)ffQuery
{
    return [NSString stringWithFormat:@"%@/%@", self.patient.ffUrl, WMPatientRelationships.bradenScales];
}

- (NSString *)fetchedResultsControllerEntityName
{
	return @"WMBradenScale";
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
	return [NSPredicate predicateWithFormat:@"patient == %@", self.patient];
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
	cell.detailTextLabel.text = (bradenScale.completeFlagValue ?[NSString stringWithFormat:@"Score: %@", bradenScale.score]:@"Incomplete");
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

        [managedObjectContext MR_saveOnlySelfAndWait];
        self.fetchedResultsController = nil;
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
