//
//  WMAssessmentTableViewCell.h
//  WoundPUMP
//
//  Created by Todd Guion on 5/17/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "APTableViewCell.h"
#import "WoundCareProtocols.h"

@class WMAssessmentTableViewCell;

@protocol AssessmentTableViewCellDelegate <NSObject, UITextFieldDelegate>

@property (readonly, nonatomic) UIView *inputAccessoryToolbar;

- (id)valueForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup;
- (UIKeyboardType)keyboardTypeForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup;
- (BOOL)isIndexPathForDelayedFirstResponder:(WMAssessmentTableViewCell *)assessmentTableViewCell;
- (BOOL)shouldShowSelectionImageForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup;

- (void)handleWillOpenOrClose:(BOOL)openFlag forCell:(WMAssessmentTableViewCell *)assessmentTableViewCell width:(CGFloat)width;
- (void)drawSummaryViewForAssessmentGroup:(id)assessmentGroup inRect:(CGRect)rect;
- (NSAttributedString *)attributedStringForSummary:(id)assessmentGroup;

- (IBAction)segmentedControlValueChangedAction:(id)sender;
- (IBAction)switchValueChangedAction:(id)sender;
- (IBAction)sliderPercentValueChangedAction:(id)sender;

@optional
- (NSInteger)selectionCountForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup;

@end

@interface WMAssessmentTableViewCell : APTableViewCell

@property (weak, nonatomic) id<AssessmentTableViewCellDelegate> delegate;
@property (strong, nonatomic) id<AssessmentGroup> assessmentGroup;
@property (nonatomic) NSInteger selectionCount;                             // set to NSNotFound to hide image
@property (nonatomic) BOOL openFlag;
@property (nonatomic) BOOL showSecondaryOptionsArray;                       // YES if showing secondary options array of assessmentGroup
@property (readonly, nonatomic) CGFloat preferredHeight;

@property (weak, nonatomic) UITextField *valueTextField;
@property (weak, nonatomic) UILabel *valueLabel;
@property (weak, nonatomic) UISegmentedControl *valueSegmentedControl;
@property (weak, nonatomic) UISwitch *valueSwitch;
@property (weak, nonatomic) UISlider *valueSlider;

+ (CGFloat)defaultPreferredHeightForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup width:(CGFloat)width;

- (void)configureForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup selectionCount:(NSInteger)selectionCount openFlag:(BOOL)openFlag;
- (void)updateContentForAssessmentGroup;

@end
