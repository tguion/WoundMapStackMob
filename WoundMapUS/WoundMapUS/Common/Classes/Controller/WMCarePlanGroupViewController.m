//
//  WMCarePlanGroupViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMCarePlanGroupViewController.h"
#import "WMCarePlanSummaryViewController.h"
#import "WMCarePlanGroupHistoryViewController.h"
#import "MBProgressHUD.h"
#import "WMParticipant.h"
#import "WMPatient.h"
#import "WMCarePlanGroup.h"
#import "WMCarePlanGroup+CoreText.h"
#import "WMCarePlanCategory.h"
#import "WMCarePlanValue.h"
#import "WMInterventionEvent.h"
#import "WMInterventionStatus.h"
#import "WMInterventionEventType.h"
#import "WMDefinition.h"
#import "WMWound.h"
#import "WMWoundType.h"
#import "WMFatFractal.h"
#import "PDFRenderer.h"
#import "WCModelTextKitAtrributes.h"
#import "WMDesignUtilities.h"
#import "WCAppDelegate.h"
#import "WMUtilities.h"

@interface WMCarePlanGroupViewController () <CarePlanGroupViewControllerDelegate>

@property (strong, nonatomic) WMCarePlanGroup *carePlanGroup;

@property (nonatomic) BOOL removeUndoManagerWhenDone;

@property (strong, nonatomic) WMCarePlanCategory *parentCategory;                   // category that has subcategories or items
@property (readonly, nonatomic) WMCarePlanGroupViewController *subcategoriesViewController;
@property (strong, nonatomic) WMCarePlanCategory *selectedCarePlanCategory;         // selected category, navigate to subcategories
@property (readonly, nonatomic) WMCarePlanSummaryViewController *carePlanSummaryViewController;
@property (readonly, nonatomic) WMCarePlanGroupHistoryViewController *carePlanGroupHistoryViewController;

- (void)grabBagRemoveCarePlanValues:(NSArray *)values;

@end

@interface WMCarePlanGroupViewController (PrivateMethods)
- (void)navigateToSubcategories;
- (void)reloadRowsForSelectedCarePlanItem:(id)itemOrCategory previousIndexPath:(NSIndexPath *)previousIndexPath;
@end

@implementation WMCarePlanGroupViewController (PrivateMethods)

- (void)navigateToSubcategories
{
    WMCarePlanGroupViewController *subcategoriesViewController = self.subcategoriesViewController;
    subcategoriesViewController.carePlanGroup = self.carePlanGroup;
    subcategoriesViewController.parentCategory = self.selectedCarePlanCategory;
    [self clearOpenHeightsForAssessmentGroup:self.selectedCarePlanCategory];
    [self.navigationController pushViewController:subcategoriesViewController animated:YES];
}

- (void)reloadRowsForSelectedCarePlanItem:(id)itemOrCategory previousIndexPath:(NSIndexPath *)previousIndexPath
{
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:itemOrCategory];
    if ([indexPath isEqual:previousIndexPath]) {
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, previousIndexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end

@implementation WMCarePlanGroupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        __weak __typeof(&*self)weakSelf = self;
        self.refreshCompletionHandler = ^(NSError *error, id object) {
            if (!weakSelf.didCreateGroup) {
                [weakSelf.tableView reloadData];
            }
        };
    }
    return self;
}

#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];
    WMPatient *patient = self.patient;
    NSManagedObjectContext *managedObjectContext = [patient managedObjectContext];
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    WMFatFractalManager *ffm = [WMFatFractalManager sharedInstance];
    _carePlanGroup = [WMCarePlanGroup activeCarePlanGroup:patient];
    if (_carePlanGroup.ffUrl || _parentCategory) {
        dispatch_block_t block = ^{
            // we want to support cancel, so make sure we have an undoManager
            if (nil == managedObjectContext.undoManager) {
                managedObjectContext.undoManager = [[NSUndoManager alloc] init];
                _removeUndoManagerWhenDone = YES;
            }
            [managedObjectContext.undoManager beginUndoGrouping];
        };
        // values may not have been aquired from back end
        if (_parentCategory) {
            if ([_parentCategory.values count] == 0) {
                [ffm updateGrabBags:@[WMCarePlanGroupRelationships.values] aggregator:_parentCategory ff:ff completionHandler:^(NSError *error) {
                    [managedObjectContext MR_saveToPersistentStoreAndWait];
                    block();
                }];
            } else {
                block();
            }
        } else {
            if ([_carePlanGroup.values count] == 0) {
                [ffm updateGrabBags:@[WMCarePlanGroupRelationships.values] aggregator:_carePlanGroup ff:ff completionHandler:^(NSError *error) {
                    [managedObjectContext MR_saveToPersistentStoreAndWait];
                    block();
                }];
            } else {
                block();
            }
        }
    } else if (nil == _carePlanGroup) {
        _carePlanGroup = [WMCarePlanGroup carePlanGroupForPatient:patient];
        self.didCreateGroup = YES;
        WMInterventionEvent *event = [_carePlanGroup interventionEventForChangeType:InterventionEventChangeTypeUpdateStatus
                                                                              path:nil
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
        __weak __typeof(&*self)weakSelf = self;
        FFHttpMethodCompletion block = ^(NSError *error, id object, NSHTTPURLResponse *response) {
            if (error) {
                [WMUtilities logError:error];
            } else {
                [ff grabBagAddItemAtFfUrl:_carePlanGroup.ffUrl
                             toObjAtFfUrl:weakSelf.patient.ffUrl
                              grabBagName:WMPatientRelationships.carePlanGroups
                               onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                                   if (error) {
                                       [WMUtilities logError:error];
                                   }
                               }];
            }
        };
        [ff createObj:_carePlanGroup
                atUri:[NSString stringWithFormat:@"/%@", [WMCarePlanGroup entityName]]
           onComplete:block
            onOffline:block];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.recentlyClosedCount > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please Note"
                                                            message:[NSString stringWithFormat:@"Your Policy has closed %ld open Care Plan records. A new Care Plan has been created for you.", (long)self.recentlyClosedCount]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
        self.recentlyClosedCount = 0;
    }
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clearDataCache
{
    [super clearDataCache];
    _carePlanGroup = nil;
    _parentCategory = nil;
    _selectedCarePlanCategory = nil;
}

#pragma mark - BuildGroupViewController

- (BOOL)shouldShowToolbar
{
    return YES;
}

- (void)updateToolbarItems
{
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:8];
    if ([WMCarePlanGroup carePlanGroupsHaveHistory:self.patient]) {
        [items addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ui_segmented_Notepad"]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(showCarePlanGroupHistoryAction:)]];
    }
    [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                   target:nil
                                                                   action:nil]];
    NSString *title = (self.carePlanGroup.status.isActive ? [NSString stringWithFormat:@"Current Status: %@", self.carePlanGroup.status.title]:self.carePlanGroup.status.title);
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:title
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(updateStatusCarePlanGroupAction:)];
    barButtonItem.enabled = self.carePlanGroup.status.isActive;
    [items addObject:barButtonItem];
    [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                   target:nil
                                                                   action:nil]];
    if (self.carePlanGroup.hasInterventionEvents) {
        [items addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ui_segmented_List-bullets"]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(showCarePlanGroupEventsAction:)]];
    }
    self.toolbarItems = items;
}

- (void)updateUIForDataChange
{
    [super updateUIForDataChange];
    self.title = (nil == _parentCategory ? @"Care Plan":_parentCategory.title);
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)updateUIForSearch
{
    [super updateUIForSearch];
    self.title = @"Search Definitions";
}

- (UIKeyboardType)keyboardTypeForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup
{
    WMCarePlanCategory *carePlanCategory = (WMCarePlanCategory *)assessmentGroup;
    UIKeyboardType keyboardType = [carePlanCategory.keyboardType intValue];
    if (self.isIPadIdiom && keyboardType == UIKeyboardTypeDecimalPad) {
        keyboardType = UIKeyboardTypeNumberPad;
    }
    return keyboardType;
}

- (id)valueForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup
{
    WMCarePlanValue *carePlanValue = nil;
    if ([assessmentGroup isKindOfClass:[WMCarePlanCategory class]]) {
        WMCarePlanCategory *carePlanCategory = (WMCarePlanCategory *)assessmentGroup;
        carePlanValue = [self.carePlanGroup carePlanValueForCarePlanCategory:carePlanCategory
                                                                      create:NO
                                                                       value:nil];
    }
    if (nil == carePlanValue) {
        return nil;
    }
    // else
    if (assessmentGroup.groupValueTypeCode == GroupValueTypeCodeSelect) {
        return carePlanValue;
    }
    // else
    return carePlanValue.value;
}

- (void)updateAssessmentGroup:(id<AssessmentGroup>)assessmentGroup withValue:(id)value
{
    WMCarePlanCategory *parentCarePlanCategory = nil;
    BOOL createValue = (nil != value);
    if ([value isKindOfClass:[NSString class]]) {
        createValue = [value length] > 0;
    }
    if (createValue) {
        // unselect any other selection in category (section)
        if (nil != parentCarePlanCategory && !parentCarePlanCategory.allowMultipleChildSelection) {
            NSArray *values = [self.carePlanGroup removeCarePlanValuesForCarePlanCategory:parentCarePlanCategory];
            // update back end
            [self grabBagRemoveCarePlanValues:values];
        }
    }
    WMCarePlanValue *carePlanValue = nil;
    if ([assessmentGroup isKindOfClass:[WMCarePlanCategory class]]) {
        WMCarePlanCategory *carePlanCategory = (WMCarePlanCategory *)assessmentGroup;
        carePlanValue = [self.carePlanGroup carePlanValueForCarePlanCategory:carePlanCategory
                                                                      create:createValue
                                                                       value:nil];
    }
    if (createValue) {
        carePlanValue.value = value;
    } else if (nil != carePlanValue) {
        [self.carePlanGroup removeValuesObject:carePlanValue];
        [self.managedObjectContext deleteObject:carePlanValue];
        [self grabBagRemoveCarePlanValues:@[carePlanValue]];
    }
}

#pragma mark - Core

- (void)grabBagRemoveCarePlanValues:(NSArray *)values
{
    WMFatFractal *ff = [WMFatFractal sharedInstance];
    FFHttpMethodCompletion block = ^(NSError *error, id object, NSHTTPURLResponse *response) {
        if (error) {
            [WMUtilities logError:error];
        }
    };
    for (WMCarePlanValue *value in values) {
        if (value.ffUrl) {
            [ff grabBagRemoveItemAtFfUrl:value.ffUrl
                          fromObjAtFfUrl:_carePlanGroup.ffUrl
                             grabBagName:WMCarePlanGroupRelationships.values
                              onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                                  if (error) {
                                      [WMUtilities logError:error];
                                  } else {
                                      [ff deleteObj:value onComplete:block onOffline:block];
                                  }
                              }];
        }
    }
}

- (WMCarePlanGroupViewController *)subcategoriesViewController
{
    WMCarePlanGroupViewController *subcategoriesViewController = [[WMCarePlanGroupViewController alloc] initWithNibName:@"WMCarePlanGroupViewController" bundle:nil];
    subcategoriesViewController.delegate = self;
    return subcategoriesViewController;
}

- (WMCarePlanSummaryViewController *)carePlanSummaryViewController
{
    WMCarePlanSummaryViewController *carePlanSummaryViewController = [[WMCarePlanSummaryViewController alloc] initWithNibName:@"WMCarePlanSummaryViewController" bundle:nil];
    return carePlanSummaryViewController;
}

- (WMCarePlanGroupHistoryViewController *)carePlanGroupHistoryViewController
{
    WMCarePlanGroupHistoryViewController *carePlanGroupHistoryViewController = [[WMCarePlanGroupHistoryViewController alloc] initWithNibName:@"WMCarePlanGroupHistoryViewController" bundle:nil];
    return carePlanGroupHistoryViewController;
}

#pragma mark - Actions

- (IBAction)showCarePlanGroupHistoryAction:(id)sender
{
    [self.navigationController pushViewController:self.carePlanGroupHistoryViewController animated:YES];
}

- (IBAction)updateStatusCarePlanGroupAction:(id)sender
{
    [self presentInterventionStatusViewController];
}

- (IBAction)showCarePlanGroupEventsAction:(id)sender
{
    [self presentInterventionEventViewController];
}

- (IBAction)cancelAction:(id)sender
{
    [super cancelAction:sender];
    BOOL hasValues = [_carePlanGroup.values count] > 0;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext.undoManager.groupingLevel > 0) {
        [managedObjectContext.undoManager endUndoGrouping];
        if (managedObjectContext.undoManager.canUndo) {
            [managedObjectContext.undoManager undoNestedGroup];
        }
        if (_removeUndoManagerWhenDone) {
            managedObjectContext.undoManager = nil;
        }
    }
    if (self.didCreateGroup || !hasValues) {
        [managedObjectContext deleteObject:_carePlanGroup];
        // update backend
        WMFatFractal *ff = [WMFatFractal sharedInstance];
        NSError *error = nil;
        [ff grabBagRemove:_carePlanGroup from:self.patient grabBagName:WMPatientRelationships.carePlanGroups error:&error];
        if (error) {
            [WMUtilities logError:error];
        }
        [ff deleteObj:_carePlanGroup error:&error];
        if (error) {
            [WMUtilities logError:error];
        }
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        _carePlanGroup = nil;
        self.didCreateGroup = NO;
    }
    [self.delegate carePlanGroupViewControllerDidCancel:self];
}

- (IBAction)saveAction:(id)sender
{
    BOOL hasValues = [_carePlanGroup.values count] > 0;
    if (!hasValues) {
        [self cancelAction:sender];
        return;
    }
    // else
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext.undoManager.groupingLevel > 0) {
        [managedObjectContext.undoManager endUndoGrouping];
        if (_removeUndoManagerWhenDone) {
            managedObjectContext.undoManager = nil;
        }
    }
    [super saveAction:sender];
    WMParticipant *participant = self.appDelegate.participant;
    // create intervention events before super
    [self.carePlanGroup createEditEventsForParticipant:participant];
    // update backend
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __block NSInteger counter = 0;
    __weak __typeof(&*self)weakSelf = self;
    dispatch_block_t block = ^{
        [managedObjectContext MR_saveToPersistentStoreAndWait];
        [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
        [weakSelf.delegate carePlanGroupViewControllerDidSave:weakSelf];
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
    for (WMInterventionEvent *interventionEvent in participant.interventionEvents) {
        if (interventionEvent.ffUrl) {
            continue;
        }
        // else
        ++counter;
        ++counter;
        [ff createObj:interventionEvent atUri:[NSString stringWithFormat:@"/%@", [WMInterventionEvent entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
            [ff grabBagAddItemAtFfUrl:interventionEvent.ffUrl toObjAtFfUrl:participant.ffUrl grabBagName:WMParticipantRelationships.interventionEvents onComplete:completionHandler];
            [ff grabBagAddItemAtFfUrl:interventionEvent.ffUrl toObjAtFfUrl:_carePlanGroup.ffUrl grabBagName:WMCarePlanGroupRelationships.interventionEvents onComplete:completionHandler];
        }];
    }
    for (WMCarePlanValue *value in _carePlanGroup.values) {
        ++counter;
        if (value.ffUrl) {
            [ff updateObj:value onComplete:completionHandler onOffline:completionHandler];
        } else {
            [ff createObj:value atUri:[NSString stringWithFormat:@"/%@", [WMCarePlanValue entityName]] onComplete:^(NSError *error, id object, NSHTTPURLResponse *response) {
                [ff grabBagAddItemAtFfUrl:value.ffUrl toObjAtFfUrl:_carePlanGroup.ffUrl grabBagName:WMCarePlanGroupRelationships.values onComplete:completionHandler];
            }];
        }
    }
    ++counter;
    [ff updateObj:_carePlanGroup onComplete:completionHandler];
}

#pragma mark - AssessmentTableViewCellDelegate

- (CGFloat)updatedHeightForOpenState
{
    CGFloat height = 44.0;
    if (nil != self.selectedCarePlanCategory) {
        // resize if open
        id<AssessmentGroup> assessmentGroup = (id<AssessmentGroup>)self.selectedCarePlanCategory;
        BOOL openFlag = [self isCellOpenForAssessmentGroup:assessmentGroup];
        if (openFlag && ![self isHeightRegisteredForOpenState:openFlag assessmentGroup:assessmentGroup]) {
            height = [self preferredHeightWithBaseHeight:[WMAssessmentTableViewCell defaultPreferredHeightForAssessmentGroup:assessmentGroup width:(UIEdgeInsetsInsetRect(self.tableView.bounds, self.tableView.separatorInset).size.width)]
                                                   width:self.lastWidthForSummaryView
                                                openFlag:openFlag
                                         assessmentGroup:assessmentGroup];
        }
    }
    return height;
}

- (CGFloat)preferredHeightWithBaseHeight:(CGFloat)baseHeight width:(CGFloat)width openFlag:(BOOL)openFlag assessmentGroup:(id)assessmentGroup
{
    NSAssert1([assessmentGroup isKindOfClass:[WMCarePlanCategory class]], @"Wrong class. Expected WMCarePlanCategory, %@", assessmentGroup);
    WMCarePlanCategory *carePlanCategory = (WMCarePlanCategory *)assessmentGroup;
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
    [self.carePlanGroup appendToMutableAttributedString:mutableAttributedString
                              forParentCarePlanCategory:carePlanCategory
                                            indentLevel:0
                                       withBaseFontSize:9.0];
    // trim first \n
    if ([mutableAttributedString.string hasPrefix:@"\n"]) {
        [mutableAttributedString deleteCharactersInRange:NSMakeRange(0, 1)];
    }
    CGSize aSize = CGSizeMake(width, CGFLOAT_MAX);
    CGFloat height = ceilf([mutableAttributedString boundingRectWithSize:aSize
                                                                 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                 context:nil].size.height);
    return (baseHeight + height + 8.0);
}

- (void)drawSummaryViewForAssessmentGroup:(id)assessmentGroup inRect:(CGRect)rect
{
    NSAssert1([assessmentGroup isKindOfClass:[WMCarePlanCategory class]], @"Wrong class. Expected WMCarePlanCategory, %@", assessmentGroup);
    NSAttributedString *attributedString = [self attributedStringForSummary:assessmentGroup];
    [attributedString drawWithRect:rect
                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                           context:nil];
}

- (NSAttributedString *)attributedStringForSummary:(id)assessmentGroup
{
    WMCarePlanCategory *carePlanCategory = (WMCarePlanCategory *)assessmentGroup;
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
    [self.carePlanGroup appendToMutableAttributedString:mutableAttributedString
                              forParentCarePlanCategory:carePlanCategory
                                            indentLevel:0
                                       withBaseFontSize:9.0];
    // trim first \n
    if ([mutableAttributedString.string hasPrefix:@"\n"]) {
        [mutableAttributedString deleteCharactersInRange:NSMakeRange(0, 1)];
    }
    return mutableAttributedString;
}

#pragma mark - CarePlanGroupViewControllerDelegate

- (void)carePlanGroupViewControllerDidSave:(WMCarePlanGroupViewController *)viewController
{
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:_selectedCarePlanCategory];
    [self.navigationController popViewControllerAnimated:YES];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)carePlanGroupViewControllerDidCancel:(WMCarePlanGroupViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - InterventionStatusViewControllerDelegate

- (NSString *)summaryButtonTitle
{
    return @"Plan Summary";
}

- (UIViewController *)summaryViewController
{
    WMCarePlanSummaryViewController *carePlanSummaryViewController = self.carePlanSummaryViewController;
    carePlanSummaryViewController.carePlanGroup = self.carePlanGroup;
    return carePlanSummaryViewController;
}

- (WMInterventionStatus *)selectedInterventionStatus
{
    return self.carePlanGroup.status;
}

- (void)interventionStatusViewController:(WMInterventionStatusViewController *)viewController didSelectInterventionStatus:(WMInterventionStatus *)interventionStatus
{
    self.carePlanGroup.status = interventionStatus;
    WMInterventionEvent *event = [self.carePlanGroup interventionEventForChangeType:InterventionEventChangeTypeUpdateStatus
                                                                               path:nil
                                                                              title:nil
                                                                          valueFrom:nil
                                                                            valueTo:nil
                                                                               type:[WMInterventionEventType interventionEventTypeForStatusTitle:interventionStatus.title
                                                                                                                            managedObjectContext:self.managedObjectContext]
                                                                        participant:self.appDelegate.participant
                                                                             create:YES
                                                               managedObjectContext:self.managedObjectContext];
    DLog(@"Created WMCarePlanInterventionEvent %@ for WMInterventionStatus %@", event.eventType.title, interventionStatus.title);
    [super interventionStatusViewController:viewController didSelectInterventionStatus:interventionStatus];
    [self updateToolbarItems];
}

#pragma mark - InterventionEventViewControllerDelegate

- (id<AssessmentGroup>)assessmentGroup
{
    return self.carePlanGroup;
}

- (void)interventionEventViewControllerDidCancel:(WMInterventionEventViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing
    }];
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSearchActive) {
        return indexPath;
    }
    // else
    return (self.carePlanGroup.status.isActive ? indexPath:nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    if (self.isSearchActive) {
        return;
    }
    // else
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WMCarePlanCategory *carePlanCategory = [self.fetchedResultsController objectAtIndexPath:indexPath];
    // if parentCategory has subcategories, just go to subcategories
    if (carePlanCategory.hasSubcategories) {
        // select and navigate
        self.selectedCarePlanCategory = carePlanCategory;
        [self navigateToSubcategories];
        return;
    }
    // else save current selection if needed
    WMCarePlanCategory * previousCarePlanCategory = [self.carePlanGroup carePlanCategoryForParentCategory:self.parentCategory];
    WMCarePlanValue *previousCarePlanValue = nil;
    NSIndexPath *previousIndexPath = nil;
    if (nil != previousCarePlanCategory && carePlanCategory != previousCarePlanCategory && !self.parentCategory.allowMultipleChildSelection) {
        previousCarePlanValue = [self.carePlanGroup carePlanValueForCarePlanCategory:previousCarePlanCategory
                                                                              create:NO
                                                                               value:nil];
        previousIndexPath = [self.fetchedResultsController indexPathForObject:previousCarePlanCategory];
    }
    // else this is item or (category without items) level, so select
    WMCarePlanValue *carePlanValue = [self.carePlanGroup carePlanValueForCarePlanCategory:carePlanCategory
                                                                                   create:NO
                                                                                    value:nil];
    BOOL refreshRow = YES;
    if (nil == carePlanValue) {
        // no carePlanValue for this item or category - add one or make control first responder
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIResponder *responder = [self possibleFirstResponderInCell:cell];
        if (nil == responder) {
            // check for a control
            UISegmentedControl *segmentedControl = [self segmentedControlForTableViewCell:cell];
            UISwitch *aSwitch = [self switchForTableViewCell:cell];
            if (nil != segmentedControl) {
                if (segmentedControl.selectedSegmentIndex == UISegmentedControlNoSegment) {
                    // don't select
                    return;
                }
                // else go ahead and select
                [self.carePlanGroup carePlanValueForCarePlanCategory:carePlanCategory
                                                              create:YES
                                                               value:nil];
            } else if (nil != aSwitch) {
                // else go ahead and select
                [self.carePlanGroup carePlanValueForCarePlanCategory:carePlanCategory
                                                              create:YES
                                                               value:nil];
            } else {
                // else go ahead and select
                [self.carePlanGroup carePlanValueForCarePlanCategory:carePlanCategory
                                                              create:YES
                                                               value:nil];
                if (nil != previousCarePlanValue) {
                    [self.carePlanGroup removeValuesObject:previousCarePlanValue];
                    [self.managedObjectContext deleteObject:previousCarePlanValue];
                    [self grabBagRemoveCarePlanValues:@[previousCarePlanValue]];
                }
            }
        } else {
            refreshRow = NO;
            self.indexPathForDelayedFirstResponder = indexPath;
            [responder performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];
        }
    } else {
        // unselect - remove
        [self.carePlanGroup removeValuesObject:carePlanValue];
        [self.managedObjectContext deleteObject:carePlanValue];
        [self grabBagRemoveCarePlanValues:@[carePlanValue]];
    }
    if (refreshRow) {
        [self reloadRowsForSelectedCarePlanItem:carePlanCategory previousIndexPath:previousIndexPath];
    }
    // update remaining UI
    [self updateUIForDataChange];
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    [super configureCell:cell atIndexPath:indexPath];
    WMCarePlanCategory *carePlanCategory = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (carePlanCategory.hasSubcategories) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}

- (NSInteger)selectionCountForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup
{
    NSInteger count = 0;
    WMCarePlanCategory *carePlanCategory = (WMCarePlanCategory *)assessmentGroup;
    if (carePlanCategory.skipSelectionIcon) {
        count = NSNotFound;
    } else {
        count = [self.carePlanGroup valuesCountForCarePlanCategory:carePlanCategory];
        count = MIN(count, 10);
    }
    return count;
}

#pragma mark - NSFetchedResultsController

- (NSString *)ffQuery
{
    if (self.didCreateGroup) {
        return nil;
    }
    // else
    return [NSString stringWithFormat:@"%@/%@", self.carePlanGroup.ffUrl, WMCarePlanGroupRelationships.values];
}

- (NSArray *)backendSeedEntityNames
{
    return @[[WMCarePlanCategory entityName]];
}

- (NSString *)fetchedResultsControllerEntityName
{
    if (self.isSearchActive) {
        return @"WMDefinition";
    }
    // else
    return @"WMCarePlanCategory";
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
    NSPredicate *predicate = nil;
    if (self.isSearchActive) {
        if ([self.searchDisplayController.searchBar.text length] > 0) {
            if (self.searchDisplayController.searchBar.selectedScopeButtonIndex == 0) {
                predicate = [WMDefinition predicateForSearchInput:self.searchDisplayController.searchBar.text section:WoundPUMPScopeWoundCarePlan];
            } else {
                predicate = [WMDefinition predicateForSearchInput:self.searchDisplayController.searchBar.text];
            }
        }
    } else {
        predicate = [WMCarePlanCategory predicateForParent:self.parentCategory woundType:self.wound.woundType];
    }
    return predicate;
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
    NSArray *sortDescriptors = nil;
    if (self.isSearchActive) {
        sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"term" ascending:YES]];
    } else {
        sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES]];
    }
    return sortDescriptors;
}

- (NSString *)fetchedResultsControllerSectionNameKeyPath
{
    return nil;
}

@end
