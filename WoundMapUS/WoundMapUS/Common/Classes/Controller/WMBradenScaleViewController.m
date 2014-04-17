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
    WMBradenScaleInputViewController *bradenScaleInputViewController = self.bradenScaleInputViewController;
    bradenScaleInputViewController.bradenScale = self.bradenScale;
    bradenScaleInputViewController.newBradenScaleFlag = self.didCreateBradenScale;
	[self.navigationController pushViewController:bradenScaleInputViewController animated:animated];
}

#pragma mark - Actions

- (IBAction)addBradenScaleAction:(id)sender
{
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    __block NSInteger counter = 0;
    __weak __typeof(&*self)weakSelf = self;
    FFHttpMethodCompletion grabBagHandler = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        } else {
            --counter;
            if (counter == 0) {
                [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
                [weakSelf navigateToBradenScaleEditor:YES];
            }
        }
    };
    FFHttpMethodCompletion createHandler = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        } else {
            if ([object isKindOfClass:[WMBradenScale class]]) {
                --counter;
            } else if ([object isKindOfClass:[WMBradenSection class]]) {
                [ff grabBagAddItemAtFfUrl:[object valueForKey:@"ffUrl"]
                             toObjAtFfUrl:[object valueForKeyPath:@"bradenScale.ffUrl"]
                              grabBagName:WMBradenScaleRelationships.sections
                               onComplete:grabBagHandler];
            } else if ([object isKindOfClass:[WMBradenCell class]]) {
                [ff grabBagAddItemAtFfUrl:[object valueForKey:@"ffUrl"]
                             toObjAtFfUrl:[object valueForKeyPath:@"section.ffUrl"]
                              grabBagName:WMBradenScaleRelationships.sections
                               onComplete:grabBagHandler];
            }
        }
    };
    WMProcessCallback callback = ^(NSError *error, NSArray *objectIDs, NSString *collection) {
        // update backend from main thread
        counter = [objectIDs count];
        for (NSManagedObjectID *objectID in objectIDs) {
            NSManagedObject *object = [managedObjectContext objectWithID:objectID];
            NSString *ffUrl = [NSString stringWithFormat:@"/%@", [[object entity] name]];
            [ff createObj:object atUri:ffUrl onComplete:createHandler];
        }
    };
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	self.bradenScale = [WMBradenScale createNewBradenScaleForPatient:self.patient handler:callback];
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
    FFHttpMethodCompletion updateHandler = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
    };
    for (WMBradenSection *bradenSection in _bradenScale.sections) {
        for (WMBradenCell *bradenCell in bradenSection.cells) {
            [ff updateObj:bradenCell onComplete:updateHandler];
        }
        [ff updateObj:bradenSection onComplete:updateHandler];
    }
    [ff updateObj:_bradenScale onComplete:updateHandler];
    // save local
    NSManagedObjectContext *managedObjectContext = [bradenScale managedObjectContext];
    [managedObjectContext MR_saveToPersistentStoreAndWait];
    [self.navigationController popViewControllerAnimated:YES];
    self.didCreateBradenScale = NO;
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
