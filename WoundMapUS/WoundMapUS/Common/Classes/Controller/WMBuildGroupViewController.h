//
//  WMBuildGroupViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 2/21/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMBaseViewController.h"
#import "WoundCareProtocols.h"
#import "WMInterventionStatusViewController.h"
#import "WMInterventionEventViewController.h"
#import "WMAssessmentTableViewCell.h"

@class PDFRenderer;

@interface WMBuildGroupViewController : WMBaseViewController <InterventionStatusViewControllerDelegate, InterventionEventViewControllerDelegate, AssessmentTableViewCellDelegate, UITextFieldDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic) BOOL willCancelFlag;                                  // cancelling the insert/edit
@property (nonatomic) BOOL didCreateGroup;                                  // YES if group instance was created/inserted
@property (readonly, nonatomic) BOOL shouldShowToolbar;                     // YES is the subclass shows toolbar
@property (readonly, nonatomic) UIResponder *nextTextFieldResponder;
@property (readonly, nonatomic) UIResponder *previousTextFieldResponder;
@property (strong, nonatomic) NSIndexPath *indexPathForDelayedFirstResponder;
@property (strong, nonatomic) PDFRenderer *renderer;
@property (nonatomic) CGFloat lastWidthForSummaryView;
@property (nonatomic) NSInteger recentlyClosedCount;

- (void)updateToolbarItems;
- (void)updateUIForDataChange;

- (IBAction)cancelAction:(id)sender;
- (IBAction)saveAction:(id)sender;

- (NSString *)cellIdentifierForValueTypeCode:(GroupValueTypeCode)valueTypeCode;
- (BOOL)shouldShowSelectionImageForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup;
- (NSInteger)selectionCountForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup;
- (UIResponder *)possibleFirstResponderInCell:(UITableViewCell *)cell;
- (UIControl *)controlInCell:(UITableViewCell *)cell;

- (UITextField *)textFieldForTableViewCell:(UITableViewCell *)cell;
- (UISegmentedControl *)segmentedControlForTableViewCell:(UITableViewCell *)cell;
- (UISwitch *)switchForTableViewCell:(UITableViewCell *)cell;
- (UISlider *)sliderForTableViewCell:(UITableViewCell *)cell;

- (id)valueForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup;
- (void)updateAssessmentGroup:(id<AssessmentGroup>)assessmentGroup withValue:(id)value;

- (UIKeyboardType)keyboardTypeForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup;

- (BOOL)isCellOpenForAssessmentGroup:(id)assessmentGroup;
- (BOOL)isHeightRegisteredForOpenState:(BOOL)openFlag assessmentGroup:(id)assessmentGroup;
- (NSMutableDictionary *)registerOpenState:(BOOL)openFlag withHeight:(CGFloat)height forAssessmentGroup:(id)assessmentGroup;
- (CGFloat)preferredHeightWithBaseHeight:(CGFloat)baseHeight width:(CGFloat)width openFlag:(BOOL)openFlag assessmentGroup:(id)assessmentGroup;
- (void)clearOpenHeightsForAssessmentGroup:(id)assessmentGroup;
- (CGFloat)updatedHeightForOpenState;

- (void)presentInterventionStatusViewController;
- (void)presentInterventionEventViewController;

@end
