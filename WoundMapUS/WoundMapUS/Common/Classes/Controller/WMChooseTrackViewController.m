//
//  WMChooseTrackViewController.m
//  WoundPUMP
//
//  Created by Todd Guion on 7/12/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMChooseTrackViewController.h"
#import "WMNavigationTrackTableViewCell.h"
#import "MBProgressHUD.h"
#import "WMNavigationTrack.h"
#import "WMNavigationNode.h"
#import "WMParticipant.h"
#import "WMTeam.h"
#import "CoreDataHelper.h"
#import "WMUserDefaultsManager.h"
#import "WMFatFractal.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"

@interface WMChooseTrackViewController ()

@property (readonly, nonatomic) WMParticipant *participant;
@property (strong, nonatomic) WMNavigationTrack *navigationTrack;

@property (nonatomic) BOOL buildingAccountFlag;

@end

@implementation WMChooseTrackViewController

#pragma mark - View

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        __weak __typeof(&*self)weakSelf = self;
        NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
        self.refreshCompletionHandler = ^(NSError *error, id object) {
            if ([[WMNavigationTrack entityName] isEqualToString:object]) {
                // we may need to seed, since tracks, stages, and nodes are scoped to participant or team
                WMFatFractal *ff = [WMFatFractal sharedInstance];
                dispatch_block_t block = ^{
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
                };
                WMProcessCallbackWithCallback completionHandler = ^(NSError *error, NSArray *objectIDs, NSString *collection, dispatch_block_t callBack) {
                    // update backend from main thread
                    NSString *ffUrl = [NSString stringWithFormat:@"/%@", collection];
                    for (NSManagedObjectID *objectID in objectIDs) {
                        NSManagedObject *object = [managedObjectContext objectWithID:objectID];
                        NSLog(@"*** WoundMap: Will create collection backend: %@", object);
                        [ff createObj:object atUri:ffUrl];
                        [managedObjectContext MR_saveToPersistentStoreAndWait];
                    }
                    if (callBack) {
                        callBack();
                    }
                    block();
                };
                WMParticipant *participant = weakSelf.participant;
                if (!weakSelf.buildingAccountFlag && nil == participant.team && [WMNavigationTrack MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"team = nil"] inContext:weakSelf.managedObjectContext] == 0) {
                    weakSelf.buildingAccountFlag = YES;
                    [MBProgressHUD showHUDAddedToViewController:weakSelf animated:NO].labelText = @"Building account on device";
                    [WMNavigationTrack seedDatabase:managedObjectContext completionHandler:completionHandler];
                }
            }
        };
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Choose Clinical Setting";
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(chooseTrackAction:)];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    barButtonItem.enabled = (nil != self.navigationTrack);
    if (nil != self.delegate) {
        barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
        self.navigationItem.leftBarButtonItem = barButtonItem;
    }
    // tableView
    [self.tableView registerClass:[WMNavigationTrackTableViewCell class] forCellReuseIdentifier:@"TrackCell"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    _navigationTrack = nil;
}

#pragma mark - Core

- (WMParticipant *)participant
{
    return self.appDelegate.participant;
}

- (WMNavigationTrack *)navigationTrack
{
    if (nil == _navigationTrack) {
        if (nil == self.delegate) {
            _navigationTrack = [self.userDefaultsManager defaultNavigationTrack:self.managedObjectContext];
        } else {
            _navigationTrack = self.delegate.selectedTrack;
        }
    }
    return _navigationTrack;
}

#pragma mark - Actions

- (IBAction)chooseTrackAction:(id)sender
{
    // make sure we have the navigation data
    __weak __typeof(&*self)weakSelf = self;
    FFHttpMethodCompletion onComplete = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:NO];
        [weakSelf.delegate chooseTrackViewController:weakSelf didChooseNavigationTrack:weakSelf.navigationTrack];
    };
    WMNavigationStage *stage = self.navigationTrack.initialStage;
    if (nil == stage) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedToViewController:self animated:YES];
        hud.labelText = @"Acquiring policies";
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        [ff getArrayFromUri:[NSString stringWithFormat:@"/%@?depthRef=2", [WMNavigationNode entityName]] onComplete:onComplete];
    } else {
        onComplete(nil, nil, nil);
    }
}

- (IBAction)cancelAction:(id)sender
{
    [self.delegate chooseTrackViewControllerDidCancel:self];
}

#pragma mark - BaseViewController

- (void)clearDataCache
{
    [super clearDataCache];
    _navigationTrack = nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [WMNavigationTrackTableViewCell heightTheFitsForTrack:[self.fetchedResultsController objectAtIndexPath:indexPath] width:(CGRectGetWidth(self.view.frame) - 52.0)];
}

// select existing patient document
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.navigationTrack = [self.fetchedResultsController objectAtIndexPath:indexPath];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"TrackCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    WMNavigationTrackTableViewCell *myCell = (WMNavigationTrackTableViewCell *)cell;
    WMNavigationTrack *navigationTrack = [self.fetchedResultsController objectAtIndexPath:indexPath];
    myCell.navigationTrack = navigationTrack;
    myCell.imageView.image = (navigationTrack == _navigationTrack ? [UIImage imageNamed:@"ui_checkmark"]:[UIImage imageNamed:@"ui_circle"]);
    myCell.accessoryType = UITableViewCellAccessoryNone;
}

#pragma mark - NSFetchedResultsController

- (NSArray *)ffQuery
{
    return nil;
}

- (NSArray *)backendSeedEntityNames
{
    return @[[WMNavigationTrack entityName]];
}

- (NSString *)fetchedResultsControllerEntityName
{
	return @"WMNavigationTrack";
}

// TODO: scope the tracks to participant.team
- (NSPredicate *)fetchedResultsControllerPredicate
{
    return self.delegate.navigationTrackPredicate;
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
    return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES]];
}

@end
