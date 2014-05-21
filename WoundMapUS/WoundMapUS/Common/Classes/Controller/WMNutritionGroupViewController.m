//
//  WMNutritionGroupViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 5/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMNutritionGroupViewController.h"
#import "WMNoteViewController.h"
#import "MBProgressHUD.h"
#import "WMPatient.h"
#import "WMParticipant.h"
#import "WMNutritionGroup.h"
#import "WMNutritionItem.h"
#import "WMNutritionValue.h"
#import "WMInterventionEvent.h"
#import "WMInterventionEventType.h"
#import "WMDefinition.h"
#import "WMInterventionStatus.h"
#import "WMUtilities.h"
#import "WMFatFractal.h"
#import "WMFatFractalManager.h"
#import "WCAppDelegate.h"

@interface WMNutritionGroupViewController () <NoteViewControllerDelegate>

@property (strong, nonatomic) WMNutritionGroup *nutritionGroup;
@property (strong, nonatomic) WMNutritionItem *selectedNutritionItem;

@property (nonatomic) BOOL removeUndoManagerWhenDone;

@property (readonly, nonatomic) WMNoteViewController *noteViewController;

@end

@implementation WMNutritionGroupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.modalInPopover = YES;
        self.preferredContentSize = CGSizeMake(320.0, 860.0);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Nutrition";
    WMPatient *patient = self.patient;
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    _nutritionGroup = [WMNutritionGroup activeNutritionGroup:patient];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    if (nil == _nutritionGroup) {
        _nutritionGroup = [WMNutritionGroup nutritionGroupForPatient:patient];
        self.didCreateGroup = YES;
        WMInterventionEvent *event = [_nutritionGroup interventionEventForChangeType:InterventionEventChangeTypeUpdateStatus
                                                                                title:nil
                                                                            valueFrom:nil
                                                                              valueTo:nil
                                                                                 type:[WMInterventionEventType interventionEventTypeForTitle:kInterventionEventTypePlan
                                                                                                                                      create:YES
                                                                                                                        managedObjectContext:managedObjectContext]
                                                                          participant:self.appDelegate.participant
                                                                               create:YES
                                                                 managedObjectContext:managedObjectContext];
        DLog(@"Created event %@", event.eventType.title);
        // update backend
        FFHttpMethodCompletion block = ^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            } else {
                [managedObjectContext MR_saveToPersistentStoreAndWait];
                [ff grabBagAddItemAtFfUrl:_nutritionGroup.ffUrl
                             toObjAtFfUrl:patient.ffUrl
                              grabBagName:WMPatientRelationships.nutritionGroups
                               onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                                   if (error) {
                                       [WMUtilities logError:error];
                                   }
                               }];
            }
        };
        [ff createObj:_nutritionGroup
                atUri:[NSString stringWithFormat:@"/%@", [WMNutritionGroup entityName]]
           onComplete:block
            onOffline:block];
    } else {
        dispatch_block_t block = ^{
            // we want to support cancel, so make sure we have an undoManager
            if (nil == managedObjectContext.undoManager) {
                managedObjectContext.undoManager = [[NSUndoManager alloc] init];
                _removeUndoManagerWhenDone = YES;
            }
            [managedObjectContext.undoManager beginUndoGrouping];
        };
        // values may not have been aquired from back end
        if ([_nutritionGroup.values count] == 0) {
            [ffm updateGrabBags:@[WMNutritionGroupRelationships.values] aggregator:_nutritionGroup ff:ff completionHandler:^(NSError *error) {
                [managedObjectContext MR_saveToPersistentStoreAndWait];
                block();
            }];
        } else {
            block();
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.recentlyClosedCount > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please Note"
                                                            message:[NSString stringWithFormat:@"Your Policy has closed %ld open Nutrition records.", (long)self.recentlyClosedCount]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
        self.recentlyClosedCount = 0;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core

- (void)navigateToNoteViewController:(WMNutritionItem *)nutritionItem
{
    self.selectedNutritionItem = nutritionItem;
    [self.navigationController pushViewController:self.noteViewController animated:YES];
}

- (WMNoteViewController *)noteViewController
{
    WMNoteViewController *noteViewController = [[WMNoteViewController alloc] initWithNibName:@"WMNoteViewController" bundle:nil];
    noteViewController.delegate = self;
    return noteViewController;
}

// assume deleting will remove from grabBag
- (void)deleteNutritionValuesFromBackEnd:(NSArray *)nutritionValues
{
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    for (WMNutritionValue *nutritionValue in nutritionValues) {
        if (nutritionValue.ffUrl) {
            [ff deleteObj:nutritionValue
               onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                   if (error) {
                       [WMUtilities logError:error];
                   }
               } onOffline:^(NSError *error, id object, NSHTTPURLResponse *response) {
                   if (error) {
                       [WMUtilities logError:error];
                   }
               }];
        }
    }
}

#pragma mark - Actions

- (IBAction)cancelAction:(id)sender
{
    [super cancelAction:sender];
    BOOL hasValues = [_nutritionGroup.values count] > 0;
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
        if (self.managedObjectContext.undoManager.canUndo) {
            [self.managedObjectContext.undoManager undoNestedGroup];
        }
        if (_removeUndoManagerWhenDone) {
            self.managedObjectContext.undoManager = nil;
        }
    }
    if (self.didCreateGroup || !hasValues) {
        [self.managedObjectContext deleteObject:_nutritionGroup];
        // update backend
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        NSError *error = nil;
        [ff grabBagRemove:_nutritionGroup from:self.patient grabBagName:WMPatientRelationships.nutritionGroups error:&error];
        if (error) {
            [WMUtilities logError:error];
        }
        [ff deleteObj:_nutritionGroup error:&error];
        if (error) {
            [WMUtilities logError:error];
        }
        [self.managedObjectContext MR_saveToPersistentStoreAndWait];
    }
    [self.delegate nutritionGroupViewControllerDidCancel:self];
}

- (IBAction)saveAction:(id)sender
{
    if ([_nutritionGroup.values count] == 0) {
        [self cancelAction:sender];
        return;
    }
    // else
    if (self.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.managedObjectContext.undoManager endUndoGrouping];
        if (_removeUndoManagerWhenDone) {
            self.managedObjectContext.undoManager = nil;
        }
    }
    [super saveAction:sender];
    // create intervention events before super
    [_nutritionGroup createEditEventsForParticipant:self.appDelegate.participant];
    // update backend
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __block NSInteger counter = 0;
    __weak __typeof(&*self)weakSelf = self;
    dispatch_block_t block = ^{
        WM_ASSERT_MAIN_THREAD;
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        [weakSelf.managedObjectContext MR_saveToPersistentStoreAndWait];
        [weakSelf.delegate nutritionGroupViewControllerDidSave:weakSelf];
    };
    // update back end
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    FFHttpMethodCompletion completionHandler = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
        if (--counter == 0) {
            block();
        }
    };
    WMParticipant *participant = self.appDelegate.participant;
    for (WMInterventionEvent *interventionEvent in participant.interventionEvents) {
        if (interventionEvent.ffUrl) {
            continue;
        }
        // else
        ++counter;
        ++counter;
        [ff createObj:interventionEvent atUri:[NSString stringWithFormat:@"/%@", [WMInterventionEvent entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
            [ff grabBagAddItemAtFfUrl:interventionEvent.ffUrl toObjAtFfUrl:participant.ffUrl grabBagName:WMParticipantRelationships.interventionEvents onComplete:completionHandler];
            [ff grabBagAddItemAtFfUrl:interventionEvent.ffUrl toObjAtFfUrl:_nutritionGroup.ffUrl grabBagName:WMNutritionGroupRelationships.interventionEvents onComplete:completionHandler];
        }];
    }
    for (WMNutritionValue *value in _nutritionGroup.values) {
        if (value.ffUrl) {
            continue;
        }
        // else
        ++counter;
        [ff createObj:value atUri:[NSString stringWithFormat:@"/%@", [WMNutritionValue entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            }
            [ff grabBagAddItemAtFfUrl:value.ffUrl toObjAtFfUrl:_nutritionGroup.ffUrl grabBagName:WMNutritionGroupRelationships.values onComplete:completionHandler];
        }];
    }
    ++counter;
    [ff updateObj:_nutritionGroup onComplete:completionHandler];
}

#pragma mark - BuildGroupViewController

- (BOOL)shouldShowToolbar
{
    return NO;
}

- (id)valueForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup
{
    WMNutritionItem *item = (WMNutritionItem *)assessmentGroup;
    WMNutritionValue *nutritionValue = [self.nutritionGroup nutritionValueForItem:item
                                                                           create:NO
                                                                            value:nil];
    if (nil == nutritionValue) {
        return nil;
    }
    // else
    if (item.groupValueTypeCode == GroupValueTypeCodeSelect) {
        return nutritionValue;
    }
    // else
    return nutritionValue.value;
}

- (void)updateAssessmentGroup:(id<AssessmentGroup>)assessmentGroup withValue:(id)value
{
    BOOL createNutritionValue = (nil != value);
    if ([value isKindOfClass:[NSString class]]) {
        createNutritionValue = [value length] > 0;
    }
    WMNutritionValue *nutritionValue = [self.nutritionGroup nutritionValueForItem:assessmentGroup
                                                                           create:createNutritionValue
                                                                            value:nil];
    if (createNutritionValue) {
        nutritionValue.value = value;
        [self.nutritionGroup addValuesObject:nutritionValue];
    } else if (nil != nutritionValue) {
        [self.nutritionGroup removeValuesObject:nutritionValue];
        [self deleteNutritionValuesFromBackEnd:@[nutritionValue]];
        [self.managedObjectContext deleteObject:nutritionValue];
    }
}

#pragma mark - NoteViewControllerDelegate

- (NSString *)note
{
    WMNutritionValue *value = [_nutritionGroup nutritionValueForItem:_selectedNutritionItem create:NO value:nil];
    return value.value;
}

- (NSString *)label
{
    return _selectedNutritionItem.title;
}

- (void)noteViewController:(WMNoteViewController *)viewController didUpdateNote:(NSString *)note
{
    WMNutritionValue *value = [_nutritionGroup nutritionValueForItem:_selectedNutritionItem create:YES value:nil];
    value.value = note;
    [self.navigationController popViewControllerAnimated:YES];
    // reload the section if only one selection allowed
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:_selectedNutritionItem];
    if (indexPath) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    _selectedNutritionItem = nil;
}

- (void)noteViewControllerDidCancel:(WMNoteViewController *)viewController withNote:(NSString *)note
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSearchActive) {
        return indexPath;
    }
    // else
    return (_nutritionGroup.status.isActive ? indexPath:nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    if (self.isSearchActive) {
        return;
    }
    // else
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WMNutritionItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (item.groupValueTypeCode == GroupValueTypeCodeNavigateToNote) {
        [self navigateToNoteViewController:item];
        return;
    }
    [self updateUIForDataChange];
}

#pragma mark - UITableViewDataSource

#pragma mark - NSFetchedResultsController

- (NSString *)ffQuery
{
    if (self.didCreateGroup) {
        return nil;
    }
    // else
    return [NSString stringWithFormat:@"%@/%@", self.nutritionGroup.ffUrl, WMNutritionGroupRelationships.values];
}

- (NSArray *)backendSeedEntityNames
{
    return @[[WMNutritionItem entityName]];
}

- (NSString *)fetchedResultsControllerEntityName
{
	return (self.isSearchActive ? @"WMDefinition":@"WMNutritionItem");
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
    NSPredicate *predicate = nil;
    if (self.isSearchActive) {
        if ([self.searchDisplayController.searchBar.text length] > 0) {
            if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == 0) {
                predicate = [WMDefinition predicateForSearchInput:self.searchDisplayController.searchBar.text section:WoundPUMPScopeMedications];
            } else {
                predicate = [WMDefinition predicateForSearchInput:self.searchDisplayController.searchBar.text];
            }
        }
    }
    return predicate;
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
    NSArray *sortDescriptors = nil;
    if (self.isSearchActive) {
        sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"term" ascending:YES]];
    } else {
        sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES]];
    }
    return sortDescriptors;
}

@end
