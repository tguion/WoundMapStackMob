
//
//  WMAssessmentTableViewCell.m
//  WoundPUMP
//
//  Created by Todd Guion on 5/17/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMAssessmentTableViewCell.h"
#import "WMDisclosureImageView.h"

CGFloat const kValueSlideWidth = 96.0;
CGFloat const kValueSliderHeight = 23.0;
CGFloat const kPercentageTextFieldWidth = 32.0;
CGFloat const kLabelHeight = 21.0;
CGFloat const kSelectionIconInset = 48.0;
CGFloat const kLabelMarginY = 4.0;

NSDictionary * kAssessmentTableViewCellLabelAttributes;
NSDictionary * kAssessmentTableViewCellValueAttributes;
NSDictionary * kAssessmentTableViewCellSubtextAttributes;

@interface WMAssessmentTableViewCell ()

@property (strong, nonatomic) id assessmentGroupValue;
@property (readonly, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UILabel *titleLabel;
@property (weak, nonatomic) UILabel *extendsOutLabel;
@property (weak, nonatomic) UILabel *extendsOutUnitLabel;
@property (weak, nonatomic) UILabel *unitLabel;
@property (weak, nonatomic) WMDisclosureImageView *disclosureImageView;
@property (readonly, nonatomic) UIView *control;
@property (weak, nonatomic) UILabel *prefixLabel;
@property (weak, nonatomic) UILabel *subtitleLabel;
@property (weak, nonatomic) UISegmentedControl *optionsSegmentedControl;
@property (weak, nonatomic) UILabel *summaryLabel;

@property (readonly, nonatomic) UIFont *labelFont;
@property (readonly, nonatomic) UIFont *valueFont;
@property (readonly, nonatomic) UIFont *subtitleFont;
@property (readonly, nonatomic) CGFloat valueOrControlWidthRequested;

- (UILabel *)addPrefixLabelSubview;
- (void)removePrefixLabel;
- (UILabel *)addSubtitleLabelSubview;
- (void)removeSubtitleLabel;
- (UISegmentedControl *)addOptionsSegmentedControlSubview;
- (void)removeOptionsSegmentedControl;
- (UILabel *)addUnitLabelSubview;
- (void)removeUnitLabeSubview;
- (UILabel *)addTitleLabelSubview;
- (void)removeTitleLabelSubview;
- (void)addExtendsOutLabelSubviews;
- (void)removeExtendsOutLabelSubviews;
- (UILabel *)addValueLabelSubview;
- (void)removeValueLabelSubview;
- (void)removeControlSubviews;
- (void)removeControlSubviewsExceptForClass:(Class)aClass;
- (void)removeControlSubviewsExceptForClasses:(NSArray *)classes;
- (UITextField *)addValueTextFieldSubview;
- (UISegmentedControl *)addSegmentedControlSubview;
- (UISwitch *)addSwitchSubview;
- (UISlider *)addSliderSubview;
- (WMDisclosureImageView *)addDisclosureImageView;
- (void)removeDisclosureImageView;
- (UILabel *)addSummaryLabelSubview;
- (void)removeSummaryLabel;

- (void)updateImageViewForSelectionCount;

@end

@implementation WMAssessmentTableViewCell

+ (void)initialize
{
    if (self == [WMAssessmentTableViewCell class]) {
        NSMutableParagraphStyle *paragraphStyle0 = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle0.alignment = NSTextAlignmentLeft;
        paragraphStyle0.lineBreakMode = NSLineBreakByWordWrapping;
        kAssessmentTableViewCellLabelAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   [UIFont systemFontOfSize:15.0], NSFontAttributeName,
                                                   [UIColor blackColor], NSForegroundColorAttributeName,
                                                   paragraphStyle0, NSParagraphStyleAttributeName,
                                                   nil];
        NSMutableParagraphStyle *paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle1.alignment = NSTextAlignmentRight;
        paragraphStyle1.lineBreakMode = NSLineBreakByTruncatingTail;
        kAssessmentTableViewCellValueAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                            [UIFont systemFontOfSize:15.0], NSFontAttributeName,
                            [UIColor blackColor], NSForegroundColorAttributeName,
                            paragraphStyle1, NSParagraphStyleAttributeName,
                            nil];
        NSMutableParagraphStyle *paragraphStyle2 = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle2.alignment = NSTextAlignmentLeft;
        paragraphStyle2.lineBreakMode = NSLineBreakByWordWrapping;
        kAssessmentTableViewCellSubtextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                     [UIFont systemFontOfSize:12.0], NSFontAttributeName,
                                                     [UIColor blackColor], NSForegroundColorAttributeName,
                                                     paragraphStyle2, NSParagraphStyleAttributeName,
                                                     nil];
    }
}

#pragma mark - Add / Remove subviews

- (UILabel *)addPrefixLabelSubview
{
    if (nil != _prefixLabel) {
        return _prefixLabel;
    }
    // else
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, kPercentageTextFieldWidth, kLabelHeight)];
    label.font = self.labelFont;
    label.numberOfLines = 1;
    label.backgroundColor = [UIColor clearColor];
    [self.customContentView addSubview:label];
    _prefixLabel = label;
    return _prefixLabel;
}

- (void)removePrefixLabel
{
    [_prefixLabel removeFromSuperview];
    _prefixLabel = nil;
}

- (UILabel *)addSubtitleLabelSubview
{
    if (nil != _subtitleLabel) {
        return _subtitleLabel;
    }
    // else
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, kPercentageTextFieldWidth, kLabelHeight)];
    label.font = self.subtitleFont;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    [self.customContentView addSubview:label];
    _subtitleLabel = label;
    return _subtitleLabel;
}

- (void)removeSubtitleLabel
{
    [_subtitleLabel removeFromSuperview];
    _subtitleLabel = nil;
}

- (UISegmentedControl *)addOptionsSegmentedControlSubview
{
    if (nil != _optionsSegmentedControl) {
        return _optionsSegmentedControl;
    }
    // else
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithFrame:CGRectZero];
    [self.customContentView addSubview:segmentedControl];
    _optionsSegmentedControl = segmentedControl;
    return _optionsSegmentedControl;
}

- (void)removeOptionsSegmentedControl
{
    [_optionsSegmentedControl removeFromSuperview];
    _optionsSegmentedControl = nil;
}

- (UILabel *)addUnitLabelSubview
{
    if (nil != _unitLabel) {
        return _unitLabel;
    }
    // else
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, kPercentageTextFieldWidth, kLabelHeight)];
    label.backgroundColor = [UIColor clearColor];
    [self.customContentView addSubview:label];
    _unitLabel = label;
    return _unitLabel;
}

- (void)removeUnitLabeSubview
{
    [_unitLabel removeFromSuperview];
    _unitLabel = nil;
}

- (UILabel *)addTitleLabelSubview
{
    if (nil != _titleLabel) {
        return _titleLabel;
    }
    // else
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, kPercentageTextFieldWidth, kLabelHeight)];
    label.font = self.labelFont;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    [self.customContentView addSubview:label];
    _titleLabel = label;
    return _titleLabel;
}

- (void)removeTitleLabelSubview
{
    [_titleLabel removeFromSuperview];
    _titleLabel = nil;
}

- (void)addExtendsOutLabelSubviews
{
    if (nil != _extendsOutLabel) {
        return;
    }
    // else
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, kPercentageTextFieldWidth, kLabelHeight)];
    label.backgroundColor = [UIColor clearColor];
    [self.customContentView addSubview:label];
    label.text = @"Extends out";
    label.font = [UIFont systemFontOfSize:13.0];
    [label sizeToFit];
    _extendsOutLabel = label;
    label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, kPercentageTextFieldWidth, kLabelHeight)];
    label.backgroundColor = [UIColor clearColor];
    [self.customContentView addSubview:label];
    label.text = @"cm";
    label.font = [UIFont systemFontOfSize:13.0];
    [label sizeToFit];
    _extendsOutUnitLabel = label;
}

- (void)removeExtendsOutLabelSubviews
{
    [_extendsOutLabel removeFromSuperview];
    _extendsOutLabel = nil;
    [_extendsOutUnitLabel removeFromSuperview];
    _extendsOutUnitLabel = nil;
}

- (UILabel *)addValueLabelSubview;
{
    if (nil != _valueLabel) {
        return _valueLabel;
    }
    // else
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, kPercentageTextFieldWidth, kLabelHeight)];
    label.font = self.valueFont;
    label.backgroundColor = [UIColor clearColor];
    [self.customContentView addSubview:label];
    label.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];
    label.textAlignment = NSTextAlignmentRight;
    _valueLabel = label;
    return _valueLabel;
}

- (void)removeValueLabelSubview
{
    [_valueLabel removeFromSuperview];
    _valueLabel = nil;
}

- (void)removeControlSubviews
{
    for (UIView *view in self.customContentView.subviews) {
        if ([view isKindOfClass:[UIControl class]]) {
            [view removeFromSuperview];
        }
    }
}

- (void)removeControlSubviewsExceptForClass:(Class)aClass
{
    for (UIView *view in self.customContentView.subviews) {
        if ([view isKindOfClass:[UIControl class]] && ![view isKindOfClass:aClass]) {
            [view removeFromSuperview];
        }
    }
}

- (void)removeControlSubviewsExceptForClasses:(NSArray *)classes
{
    for (UIView *view in self.customContentView.subviews) {
        if ([view isKindOfClass:[UIControl class]] && ![classes containsObject:[view class]]) {
            [view removeFromSuperview];
        }
    }
}

- (UITextField *)addValueTextFieldSubview
{
    if (nil != _valueTextField) {
        return _valueTextField;
    }
    // else
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, kPercentageTextFieldWidth, kLabelHeight)];
    textField.delegate = self.delegate;
    textField.textAlignment = NSTextAlignmentRight;
    [self.customContentView addSubview:textField];
    _valueTextField = textField;
    return _valueTextField;
}

- (UISegmentedControl *)addSegmentedControlSubview
{
    if (nil != _valueSegmentedControl) {
        return _valueSegmentedControl;
    }
    // else
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithFrame:CGRectZero];
    [self.customContentView addSubview:segmentedControl];
    _valueSegmentedControl = segmentedControl;
    return _valueSegmentedControl;
}

- (UISwitch *)addSwitchSubview
{
    if (nil != _valueSwitch) {
        return _valueSwitch;
    }
    // else
    UISwitch *valueSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [self.customContentView addSubview:valueSwitch];
    _valueSwitch = valueSwitch;
    return _valueSwitch;
}

- (UISlider *)addSliderSubview
{
    if (nil != _valueSlider) {
        return _valueSlider;
    }
    // else
    UISlider *valueSlider = [[UISlider alloc] initWithFrame:CGRectMake(0.0, 0.0, kValueSlideWidth, kValueSliderHeight)];
    [self.customContentView addSubview:valueSlider];
    _valueSlider = valueSlider;
    return _valueSlider;
}

- (WMDisclosureImageView *)addDisclosureImageView
{
    if (nil != _disclosureImageView) {
        return _disclosureImageView;
    }
    // else
    WMDisclosureImageView *disclosureImageView = [[WMDisclosureImageView alloc] initWithFrame:CGRectZero];
    [self.customContentView addSubview:disclosureImageView];
    _disclosureImageView = disclosureImageView;
    [disclosureImageView sizeToFit];
    // add tap gesture recognizer
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [_disclosureImageView addGestureRecognizer:gestureRecognizer];
    return _disclosureImageView;
}

- (void)removeDisclosureImageView
{
    [_disclosureImageView removeFromSuperview];
    _disclosureImageView = nil;
}

- (UILabel *)addSummaryLabelSubview
{
    if (nil != _summaryLabel) {
        return _summaryLabel;
    }
    // else
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, kPercentageTextFieldWidth, kLabelHeight)];
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    [self.customContentView addSubview:label];
    _summaryLabel = label;
    return _summaryLabel;
}

- (void)removeSummaryLabel
{
    [_summaryLabel removeFromSuperview];
    _summaryLabel = nil;
}

#pragma mark - Lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _selectionCount = NSNotFound;
        self.backgroundColor = [UIColor clearColor];
        self.customContentView.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        _selectionCount = NSNotFound;
        self.customContentView.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _selectionCount = NSNotFound;
        self.customContentView.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (UITableView *)tableView
{
    UIView *view = [self superview];
    while (nil != view) {
        if ([view isKindOfClass:[UITableView class]]) {
            return (UITableView *)view;
        }
        // else
        view = view.superview;
    }
    // else
    return nil;
}

- (BOOL)openFlag
{
    return _disclosureImageView.openFlag;
}

- (void)setOpenFlag:(BOOL)openFlag
{
    _disclosureImageView.openFlag = openFlag;
    if (openFlag) {
        [self addSummaryLabelSubview];
    } else {
        [self removeSummaryLabel];
    }
}

- (void)setShowSecondaryOptionsArray:(BOOL)showSecondaryOptionsArray
{
    if (_showSecondaryOptionsArray == showSecondaryOptionsArray) {
        return;
    }
    // else
    [self willChangeValueForKey:@"showSecondaryOptionsArray"];
    _showSecondaryOptionsArray = showSecondaryOptionsArray;
    [self didChangeValueForKey:@"showSecondaryOptionsArray"];
    [self setNeedsDisplay];
}

- (UIView *)control
{
    UIView *control = nil;
    for (UIView *view in self.customContentView.subviews) {
        if ([view isKindOfClass:[UIControl class]]) {
            control = view;
            break;
        }
    }
    return control;
}

- (UIFont *)labelFont
{
    return [UIFont systemFontOfSize:15.0];
}

- (UIFont *)valueFont
{
    return [UIFont systemFontOfSize:15.0];
}

- (UIFont *)subtitleFont
{
    return [UIFont systemFontOfSize:12.0];
}

- (CGFloat)valueOrControlWidthRequested
{
    CGFloat valueOrControlWidthRequested = 0.0;
    if (nil != self.valueSwitch) {
        valueOrControlWidthRequested = CGRectGetWidth(self.valueSwitch.frame);
    } else if (nil != self.valueSlider) {
        valueOrControlWidthRequested = kValueSlideWidth;
    } else if (nil != self.valueSegmentedControl) {
        valueOrControlWidthRequested = CGRectGetWidth(self.valueSegmentedControl.frame);
    }
    // add for text
    if (nil != self.valueTextField) {
        GroupValueTypeCode groupValueTypeCode = _assessmentGroup.groupValueTypeCode;
        switch (groupValueTypeCode) {
            case GroupValueTypeCodeInlineExtendsTextField: {
                valueOrControlWidthRequested += (CGRectGetWidth(self.extendsOutLabel.frame) + kPercentageTextFieldWidth + CGRectGetWidth(self.extendsOutUnitLabel.frame));
                break;
            }
            case GroupValueTypeCodeInlineSliderPercentage: {
                valueOrControlWidthRequested += kPercentageTextFieldWidth;
                break;
            }
            case GroupValueTypeCodeInlineSlider: {
                // make room for label on right
                valueOrControlWidthRequested += kPercentageTextFieldWidth;
                break;
            }
            default: {
                valueOrControlWidthRequested += 80.0;
                break;
            }
        }
    }
    // add for unit
    if (nil != self.unitLabel) {
        valueOrControlWidthRequested += CGRectGetWidth(self.unitLabel.frame);
    }
    return valueOrControlWidthRequested;
}

- (void)configureForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup selectionCount:(NSInteger)selectionCount openFlag:(BOOL)openFlag
{
    self.assessmentGroup = assessmentGroup;
    self.selectionCount = selectionCount;
    self.openFlag = openFlag;
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

+ (CGFloat)defaultPreferredHeightForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup width:(CGFloat)width
{
    return [self heightForAssessmentGroup:assessmentGroup width:(CGFloat)width];
}

+ (CGFloat)heightForAssessmentGroup:(id<AssessmentGroup>)assessmentGroup  width:(CGFloat)width
{
    width -= 8.0;   // accound for right margin
    CGFloat height = 0.0;
    switch (assessmentGroup.groupValueTypeCode) {
        case GroupValueTypeCodeInlineOptions:
        case GroupValueTypeCodeInlineNoImageOptions: {
            height = 54.0;
            break;
        }
        case GroupValueTypeCodeQuestionWithOptions: {
            // finish
            height += 2.0 * kLabelMarginY;
            NSString *string = assessmentGroup.title;
            CGRect textRect = [string boundingRectWithSize:CGSizeMake(width, 10000)
                                                                 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                              attributes:kAssessmentTableViewCellLabelAttributes
                                                                 context:nil];
            height += textRect.size.height;
            string = [(id)assessmentGroup valueForKey:@"subtitle"];
            if ([string length] > 0) {
                textRect = [string boundingRectWithSize:CGSizeMake(width, 10000)
                                                options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                             attributes:kAssessmentTableViewCellSubtextAttributes
                                                context:nil];
                height += textRect.size.height;
            }
            height += 4.0;
            height += 32.0; // segmented control
            break;
        }
        case GroupValueTypeCodeQuestionNavigateOptions: {
            width -= 44.0;                  // account for chevron
            width -= kSelectionIconInset;   // account for selection icon
            CGRect textRect = CGRectZero;
            height += 2.0 * kLabelMarginY;
            NSString *string = [(id)assessmentGroup valueForKey:@"prefixTitle"];
            if ([string length] > 0) {
                textRect = [string boundingRectWithSize:CGSizeMake(width, 10000)
                                                options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                             attributes:kAssessmentTableViewCellLabelAttributes
                                                context:nil];
                height += textRect.size.height;
            }
            string = assessmentGroup.title;
            textRect = [string boundingRectWithSize:CGSizeMake(width, 10000)
                                            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                         attributes:kAssessmentTableViewCellLabelAttributes
                                            context:nil];
            height += textRect.size.height;
            break;
        }
        default: {
            height = 44.0;
            break;
        }
    }
    return fmaxf(44.0, ceilf(height));
}

- (void)setAssessmentGroup:(id<AssessmentGroup>)assessmentGroup
{
    if (_assessmentGroup == assessmentGroup) {
        // assessmentGroup may not have changed, but value might have changed
        self.assessmentGroupValue = [self.delegate valueForAssessmentGroup:_assessmentGroup];
        return;
    }
    // else
    [self willChangeValueForKey:@"assessmentGroup"];
    _assessmentGroup = assessmentGroup;
    [self didChangeValueForKey:@"assessmentGroup"];
    // update view content
    [self updateContentForAssessmentGroup];
    [self setNeedsDisplay];
}

- (void)setAssessmentGroupValue:(id)assessmentGroupValue
{
    if ([_assessmentGroupValue isEqual:assessmentGroupValue]) {
        return;
    }
    // else
    [self willChangeValueForKey:@"assessmentGroupValue"];
    _assessmentGroupValue = assessmentGroupValue;
    [self didChangeValueForKey:@"assessmentGroupValue"];
    // update view content
    [self updateContentForAssessmentGroup];
    [self setNeedsDisplay];
}

- (void)setSelectionCount:(NSInteger)selectionCount
{
    if (_selectionCount == selectionCount) {
        return;
    }
    // else
    [self willChangeValueForKey:@"selectionCount"];
    _selectionCount = selectionCount;
    [self didChangeValueForKey:@"selectionCount"];
    // update image content
    [self updateImageViewForSelectionCount];
}

- (void)updateContentForAssessmentGroup
{
    id value = [self.delegate valueForAssessmentGroup:_assessmentGroup];
    GroupValueTypeCode groupValueTypeCode = _assessmentGroup.groupValueTypeCode;
    switch (groupValueTypeCode) {
        case GroupValueTypeCodeSelect: {
            // select with no value
            UILabel *label = [self addTitleLabelSubview];
            label.text = _assessmentGroup.title;
            [self removeControlSubviews];
            [self removeValueLabelSubview];
            [self removeExtendsOutLabelSubviews];
            self.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case GroupValueTypeCodeDefaultNavigateToOptions:
        case GroupValueTypeCodeUndermineTunnel: {
            // select with no value
            UILabel *label = [self addTitleLabelSubview];
            label.text = _assessmentGroup.title;
            [self removeControlSubviews];
            [self removeValueLabelSubview];
            [self removeExtendsOutLabelSubviews];
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case GroupValueTypeCodeValue1NavigateToOdors:
        case GroupValueTypeCodeValue1NavigateToAmounts:
        case GroupValueTypeCodeValue1NavigateToOptions:
        case GroupValueTypeCodeSubtitleNavigateToOptions:
        case GroupValueTypeCodeValue1Select: {
            // select with value
            UILabel *label = [self addTitleLabelSubview];
            label.text = _assessmentGroup.title;
            if ([value isKindOfClass:[NSString class]]) {
                UILabel *valueLabel = [self addValueLabelSubview];
                valueLabel.text = value;
            } else {
                [self removeValueLabelSubview];
            }
            [self removeControlSubviews];
            [self removeExtendsOutLabelSubviews];
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case GroupValueTypeCodeInlineTextField: {
            // plac text field into cell
            UILabel *label = [self addTitleLabelSubview];
            label.text = _assessmentGroup.title;
            UITextField *textField = [self addValueTextFieldSubview];
            if ([value isKindOfClass:[NSString class]]) {
                textField.text = value;
            } else {
                textField.text = nil;
            }
            textField.placeholder = self.assessmentGroup.placeHolder;
            if (nil == textField.inputAccessoryView) {
                textField.inputAccessoryView = self.delegate.inputAccessoryToolbar;
                textField.delegate = self.delegate;
            }
            textField.keyboardType = [self.delegate keyboardTypeForAssessmentGroup:self.assessmentGroup];
            [self removeControlSubviewsExceptForClass:[UITextField class]];
            [self removeExtendsOutLabelSubviews];
            [self removeValueLabelSubview];
            self.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case GroupValueTypeCodeInlineExtendsTextField: {
            [self removeControlSubviewsExceptForClass:[UITextField class]];
            UILabel *label = [self addTitleLabelSubview];
            label.text = _assessmentGroup.title;
            [self addExtendsOutLabelSubviews];
            UITextField *textField = [self addValueTextFieldSubview];
            textField.placeholder = self.assessmentGroup.placeHolder;
            textField.inputAccessoryView = self.delegate.inputAccessoryToolbar;
            textField.keyboardType = [self.delegate keyboardTypeForAssessmentGroup:self.assessmentGroup];
            textField.delegate = self.delegate;
            if ([value isKindOfClass:[NSString class]]) {
                textField.text = value;
            } else {
                textField.text = nil;
            }
            if ([self.delegate isIndexPathForDelayedFirstResponder:self]) {
                [textField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];
            }
            self.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case GroupValueTypeCodeInlineNoImageOptions: {
            [self removeTitleLabelSubview];
            [self removeValueLabelSubview];
            UISegmentedControl *segmentedControl = [self addSegmentedControlSubview];
            NSArray *options = (self.showSecondaryOptionsArray ? self.assessmentGroup.secondaryOptionsArray:self.assessmentGroup.optionsArray);
            // check if titles have changed
            BOOL reloadSegments = NO;
            NSInteger segment = 0;
            if (segmentedControl.numberOfSegments == [options count]) {
                // check titles
                for (segment = 0; segment < [options count]; ++segment) {
                    if (![options containsObject:[segmentedControl titleForSegmentAtIndex:segment]]) {
                        reloadSegments = YES;
                        break;
                    }
                }
            } else {
                reloadSegments = YES;
            }
            if (reloadSegments) {
                [segmentedControl removeAllSegments];
                segment = 0;
                for (id option in options) {
                    [segmentedControl insertSegmentWithTitle:option atIndex:segment++ animated:NO];
                }
            }
            segmentedControl.selectedSegmentIndex = (nil == value ? UISegmentedControlNoSegment:[value intValue]);
            // target/action
            if ([segmentedControl.allTargets count] == 0) {
                [segmentedControl addTarget:self.delegate action:@selector(segmentedControlValueChangedAction:) forControlEvents:UIControlEventValueChanged];
            }
            [self removeControlSubviewsExceptForClass:[UISegmentedControl class]];
            self.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case GroupValueTypeCodeInlineOptions: {
            UILabel *label = [self addTitleLabelSubview];
            label.text = _assessmentGroup.title;
            UISegmentedControl *segmentedControl = [self addSegmentedControlSubview];
            [segmentedControl removeAllSegments];
            NSArray *options = self.assessmentGroup.optionsArray;
            NSInteger segment = 0;
            for (id option in options) {
                [segmentedControl insertSegmentWithTitle:option atIndex:segment++ animated:NO];
            }
            segmentedControl.selectedSegmentIndex = (nil == value ? UISegmentedControlNoSegment:[value intValue]);
            // target/action
            if ([segmentedControl.allTargets count] == 0) {
                [segmentedControl addTarget:self.delegate action:@selector(segmentedControlValueChangedAction:) forControlEvents:UIControlEventValueChanged];
            }
            [self removeControlSubviewsExceptForClass:[UISegmentedControl class]];
            [self removeValueLabelSubview];
            self.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case GroupValueTypeCodeNoImageInlineSwitch:
        case GroupValueTypeCodeInlineSwitch: {
            UILabel *label = [self addTitleLabelSubview];
            label.text = _assessmentGroup.title;
            UISwitch *aSwitch = [self addSwitchSubview];
            aSwitch.on = [value boolValue];
            if ([aSwitch.allTargets count] == 0) {
                aSwitch.onImage = [UIImage imageNamed:@"yesSwitch.png"];
                aSwitch.offImage = [UIImage imageNamed:@"noSwitch.png"];
                [aSwitch addTarget:self.delegate action:@selector(switchValueChangedAction:) forControlEvents:UIControlEventValueChanged];
            }
            [self removeControlSubviewsExceptForClass:[UISwitch class]];
            [self removeValueLabelSubview];
            [self removeExtendsOutLabelSubviews];
            self.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case GroupValueTypeCodeInlineSlider: {
            UILabel *label = [self addTitleLabelSubview];
            label.text = _assessmentGroup.title;
            UISlider *slider = [self addSliderSubview];
            slider.minimumValue = 0.0;
            slider.maximumValue = 10.0;
            slider.value = [value floatValue];
            if ([[slider allTargets] count] == 0) {
                [slider addTarget:self.delegate action:@selector(sliderValueChangedAction:) forControlEvents:UIControlEventValueChanged];
            }
            label = [self addValueLabelSubview];
            if ([value isKindOfClass:[NSString class]]) {
                label.text = value;
            } else {
                label.text = nil;
            }
            [self removeControlSubviewsExceptForClass:[UISlider class]];
            self.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case GroupValueTypeCodeInlineSliderPercentage: {
            UILabel *label = [self addTitleLabelSubview];
            label.text = _assessmentGroup.title;
            UISlider *slider = [self addSliderSubview];
            if ([slider.allTargets count] == 0) {
                slider.minimumValue = 0.0;
                slider.maximumValue = 100.0;
                [slider addTarget:self.delegate action:@selector(sliderPercentValueChangedAction:) forControlEvents:UIControlEventValueChanged];
            }
            slider.value = [value floatValue];
            UITextField *textField = [self addValueTextFieldSubview];
            textField.placeholder = self.assessmentGroup.placeHolder;
            textField.inputAccessoryView = self.delegate.inputAccessoryToolbar;
            textField.keyboardType = [self.delegate keyboardTypeForAssessmentGroup:self.assessmentGroup];
            textField.delegate = self.delegate;
            if ([value isKindOfClass:[NSString class]]) {
                textField.text = value;
            } else {
                textField.text = nil;
            }
            if ([self.delegate isIndexPathForDelayedFirstResponder:self]) {
                [textField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];
            }
            [self removeControlSubviewsExceptForClasses:[NSArray arrayWithObjects:[UISlider class], [UITextField class], nil]];
            [self removeValueLabelSubview];
            self.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case GroupValueTypeCodeNavigateToNote: {
            UILabel *label = [self addTitleLabelSubview];
            label.text = _assessmentGroup.title;
            if ([value isKindOfClass:[NSString class]]) {
                UILabel *valueLabel = [self addValueLabelSubview];
                valueLabel.text = value;
            } else {
                [self removeValueLabelSubview];
            }
            [self removeControlSubviews];
            [self removeExtendsOutLabelSubviews];
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case GroupValueTypeCodeQuestionWithOptions: {
            UILabel *label = nil;
            NSString *string = [(id)_assessmentGroup valueForKey:@"prefixTitle"];
            if ([string length] > 0) {
                label = [self addPrefixLabelSubview];
                label.text = string;
            } else {
                [self removePrefixLabel];
            }
            label = [self addTitleLabelSubview];
            label.text = _assessmentGroup.title;
            string = [(id)_assessmentGroup valueForKey:@"subtitle"];
            if ([string length] > 0) {
                UILabel *subtitleLabel = [self addSubtitleLabelSubview];
                subtitleLabel.text = string;
            } else {
                [self removeSubtitleLabel];
            }
            UISegmentedControl *segmentedControl = [self addOptionsSegmentedControlSubview];
            [segmentedControl removeAllSegments];
            NSArray *options = self.assessmentGroup.optionsArray;
            NSInteger segment = 0;
            for (id option in options) {
                [segmentedControl insertSegmentWithTitle:option atIndex:segment++ animated:NO];
            }
            segmentedControl.selectedSegmentIndex = (nil == value ? UISegmentedControlNoSegment:[value intValue]);
            // target/action
            if ([segmentedControl.allTargets count] == 0) {
                [segmentedControl addTarget:self.delegate action:@selector(optionSegmentedControlValueChangedAction:) forControlEvents:UIControlEventValueChanged];
            }
            [self removeValueLabelSubview];
            [self removeExtendsOutLabelSubviews];
            self.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case GroupValueTypeCodeQuestionNavigateOptions: {
            UILabel *label = nil;
            NSString *string = [(id)_assessmentGroup valueForKey:@"prefixTitle"];
            if ([string length] > 0) {
                label = [self addPrefixLabelSubview];
                label.text = string;
            } else {
                [self removePrefixLabel];
            }
            label = [self addTitleLabelSubview];
            label.text = _assessmentGroup.title;
            if ([value isKindOfClass:[NSString class]]) {
                UILabel *valueLabel = [self addValueLabelSubview];
                valueLabel.text = value;
            } else {
                [self removeValueLabelSubview];
            }
            [self removeSubtitleLabel];
            [self removeControlSubviews];
            [self removeExtendsOutLabelSubviews];
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
    }
    [self.titleLabel sizeToFit];
    [self.valueLabel sizeToFit];
    [self.valueSegmentedControl sizeToFit];
    if ([_assessmentGroup.unit length] > 0) {
        [self addUnitLabelSubview];
        self.unitLabel.text = self.assessmentGroup.unit;
        [self.unitLabel sizeToFit];
    } else {
        [self removeUnitLabeSubview];
    }
    // update selection count
    if (nil != _disclosureImageView && [self.delegate respondsToSelector:@selector(selectionCountForAssessmentGroup:)]) {
        self.selectionCount = [self.delegate selectionCountForAssessmentGroup:self.assessmentGroup];
        [self updateImageViewForSelectionCount];
    }
}

- (void)updateImageViewForSelectionCount
{
    if (_selectionCount == NSNotFound) {
        [self removeDisclosureImageView];
    } else {
        if (nil == _disclosureImageView) {
            [self addDisclosureImageView];
        }
        _disclosureImageView.selectionCount = _selectionCount;
    }
}

- (IBAction)handleTapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    [self.delegate handleWillOpenOrClose:!self.openFlag forCell:self width:(CGRectGetWidth(self.customContentView.bounds) - kSelectionIconInset)];
}

#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect coreFrame = UIEdgeInsetsInsetRect(self.customContentView.bounds, self.tableView.separatorInset);
    CGFloat width = CGRectGetWidth(coreFrame);
    CGFloat height = CGRectGetHeight(coreFrame);
    // layout _disclosureImageView
    if (nil != _disclosureImageView) {
        CGRect aFrame = _disclosureImageView.frame;
        aFrame.origin.x = 8.0;
        if (self.openFlag) {
            aFrame.origin.y = 8.0;
        } else {
            aFrame.origin.y = roundf((height - CGRectGetHeight(_disclosureImageView.frame))/2.0);
        }
        _disclosureImageView.frame = aFrame;
    }
    GroupValueTypeCode groupValueTypeCode = self.assessmentGroup.groupValueTypeCode;
    // determine the ideal width for value or control
    CGFloat valueOrControlWidthRequested = self.valueOrControlWidthRequested;
    // determine the width available by titleLabel
    CGFloat x = (nil == _disclosureImageView ? CGRectGetMinX(coreFrame):kSelectionIconInset);
    CGFloat titleLabelAvailableWidth = width - 8.0 - x - valueOrControlWidthRequested;
    // layout label
    CGRect controlRect = CGRectInset(coreFrame, 8.0, 0.0);
    if (nil != self.titleLabel) {
        [self.titleLabel sizeToFit];
        CGRect textRect = [self.titleLabel.text boundingRectWithSize:CGSizeMake(titleLabelAvailableWidth, 10000)
                                                             options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                          attributes:kAssessmentTableViewCellLabelAttributes
                                                             context:nil];
        CGFloat lineWidth = ceilf(textRect.size.width);
        CGFloat lineHeight = ceilf(textRect.size.height);
        CGRect labelFrame = textRect;
        labelFrame.origin.x = x;
        if (self.openFlag) {
            CGFloat disclosureImageViewMinY = CGRectGetMinY(_disclosureImageView.frame);
            labelFrame.origin.y = disclosureImageViewMinY + roundf((CGRectGetHeight(_disclosureImageView.frame) - lineHeight)/2.0);
        } else {
            labelFrame.origin.y = roundf((height - lineHeight)/2.0);
        }
        labelFrame.size.width = fminf(lineWidth, titleLabelAvailableWidth);
        self.titleLabel.frame = labelFrame;
        controlRect.origin.x = roundf(CGRectGetMaxX(self.titleLabel.frame) + 8.0);
        controlRect.size.width = roundf(CGRectGetWidth(coreFrame) - controlRect.origin.x - 8.0);
    }
    // layout unit and adjust control frame
    if (nil != self.unitLabel) {
        CGRect unitFrame = self.unitLabel.frame;
        CGFloat unitWidth = CGRectGetWidth(unitFrame);
        unitFrame.origin.x = (CGRectGetMaxX(controlRect) - unitWidth);
        unitFrame.origin.y = roundf((height - CGRectGetHeight(unitFrame))/2.0);
        self.unitLabel.frame = unitFrame;
        controlRect.size.width -= (unitWidth + 2.0);
    }
    // layout controls aligned right in controlRect
    switch (groupValueTypeCode) {
        case GroupValueTypeCodeInlineExtendsTextField: {
            CGRect aFrame = self.extendsOutUnitLabel.frame;
            aFrame.origin.x = CGRectGetMaxX(controlRect) - CGRectGetWidth(aFrame);
            aFrame.origin.y = roundf((height - CGRectGetHeight(aFrame))/2.0);
            self.extendsOutUnitLabel.frame = aFrame;
            CGFloat minX = CGRectGetMinX(aFrame) - 2.0;
            aFrame = self.valueTextField.frame;
            aFrame.size.width = kPercentageTextFieldWidth;
            aFrame.origin.x = minX - kPercentageTextFieldWidth;
            aFrame.origin.y = roundf((height - CGRectGetHeight(aFrame))/2.0);
            self.valueTextField.frame = aFrame;
            minX = CGRectGetMinX(aFrame) - 2.0;
            aFrame = self.extendsOutLabel.frame;
            aFrame.origin.x = minX - CGRectGetWidth(aFrame);
            aFrame.origin.y = roundf((height - CGRectGetHeight(aFrame))/2.0);
            self.extendsOutLabel.frame = aFrame;
            break;
        }
        case GroupValueTypeCodeInlineSlider: {
            CGRect sliderFrame = self.valueSlider.frame;
            sliderFrame.size.width = kValueSlideWidth;
            sliderFrame.origin.x = CGRectGetMaxX(controlRect) - kValueSlideWidth - 2.0 - kPercentageTextFieldWidth;
            sliderFrame.origin.y = roundf((height - CGRectGetHeight(sliderFrame))/2.0);
            self.valueSlider.frame = sliderFrame;
            x = CGRectGetMaxX(sliderFrame);
            sliderFrame = self.valueLabel.frame;
            sliderFrame.size.width = kPercentageTextFieldWidth;
            sliderFrame.size.height = kLabelHeight;
            sliderFrame.origin.x = x;
            sliderFrame.origin.y = roundf((height - CGRectGetHeight(sliderFrame))/2.0);
            self.valueLabel.frame = sliderFrame;
            break;
        }
        case GroupValueTypeCodeInlineSliderPercentage: {
            CGRect sliderFrame = self.valueSlider.frame;
            sliderFrame.size.width = kValueSlideWidth;
            sliderFrame.origin.x = CGRectGetMaxX(controlRect) - kValueSlideWidth - 2.0 - kPercentageTextFieldWidth;
            sliderFrame.origin.y = roundf((height - CGRectGetHeight(sliderFrame))/2.0);
            self.valueSlider.frame = sliderFrame;
            x = CGRectGetMaxX(sliderFrame);
            sliderFrame = self.valueTextField.frame;
            sliderFrame.size.width = kPercentageTextFieldWidth;
            sliderFrame.origin.x = x;
            sliderFrame.origin.y = roundf((height - CGRectGetHeight(sliderFrame))/2.0);
            self.valueTextField.frame = sliderFrame;
            break;
        }
        case GroupValueTypeCodeQuestionWithOptions: {
            CGRect labelRect = self.titleLabel.frame;
            labelRect.origin.y = kLabelMarginY;
            self.titleLabel.frame = labelRect;
            CGFloat y = CGRectGetMaxY(labelRect);
            if (nil != _subtitleLabel) {
                labelRect = self.subtitleLabel.frame;
                CGRect textRect = [self.subtitleLabel.text boundingRectWithSize:CGSizeMake(titleLabelAvailableWidth, 10000)
                                                                        options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                     attributes:kAssessmentTableViewCellSubtextAttributes
                                                                        context:nil];
                CGFloat lineHeight = ceilf(textRect.size.height);
                labelRect.origin.x = x;
                labelRect.origin.y = ceilf(CGRectGetMaxY(self.titleLabel.frame));
                labelRect.size.width = titleLabelAvailableWidth;
                labelRect.size.height = lineHeight;
                self.subtitleLabel.frame = labelRect;
                y = CGRectGetMaxY(labelRect);
            }
            [self.optionsSegmentedControl sizeToFit];
            controlRect = self.optionsSegmentedControl.frame;
            controlRect.origin.y = y + 4.0;
            controlRect.origin.x = roundf((CGRectGetWidth(coreFrame) - CGRectGetWidth(controlRect))/2.0);
            self.optionsSegmentedControl.frame = controlRect;
            CGFloat offsetY = CGRectGetMaxY(self.optionsSegmentedControl.frame) - height;
            if (height > 0.0) {
                controlRect.origin.y -= (offsetY + 8.0);
                self.optionsSegmentedControl.frame = controlRect;
            }
            break;
        }
        case GroupValueTypeCodeQuestionNavigateOptions: {
            CGFloat y = kLabelMarginY;
            CGRect labelRect = CGRectZero;
            if (nil != _prefixLabel) {
                [_prefixLabel sizeToFit];
                labelRect = _prefixLabel.frame;
                labelRect.origin.x = x;
                labelRect.origin.y = y;
                _prefixLabel.frame = labelRect;
                y += CGRectGetHeight(labelRect);
            }
            labelRect = self.titleLabel.frame;
            labelRect.origin.x = x;
            labelRect.origin.y = y;
            self.titleLabel.frame = labelRect;
            // adjust value
            if (nil != self.valueLabel) {
                labelRect = self.valueLabel.frame;
                labelRect.origin.x = CGRectGetMaxX(controlRect) - CGRectGetWidth(labelRect);
                labelRect.origin.y = roundf((height - CGRectGetHeight(labelRect))/2.0);
                self.valueLabel.frame = labelRect;
            }
            break;
        }
        default: {
            BOOL adjustControlSize = YES;
            UIView *aView = self.valueLabel;
            if (nil == aView) {
                aView = self.valueTextField;
            }
            if (nil == aView) {
                aView = self.valueSegmentedControl;
            }
            if (nil == aView) {
                aView = self.valueSwitch;
                adjustControlSize = NO;
            }
            if (nil != aView) {
                CGRect aFrame = aView.frame;
                if (adjustControlSize) {
                    aFrame.origin.x = CGRectGetMinX(controlRect);
                    aFrame.size.width = CGRectGetWidth(controlRect);
                } else {
                    aFrame.origin.x = CGRectGetMaxX(controlRect) - CGRectGetWidth(aView.frame);
                }
                aFrame.origin.y = roundf((height - CGRectGetHeight(aView.frame))/2.0);
                aView.frame = aFrame;
            }
            break;
        }
    }
    // handle summary label
    if (self.openFlag) {
        CGRect rect = self.customContentView.bounds;
        CGFloat maxX = CGRectGetMaxX(rect);
        CGFloat minY = floorf(CGRectGetMinY(rect));
        CGFloat y = ceilf(CGRectGetMaxY(self.titleLabel.frame));
        rect.origin.y = y;
        rect.size.height -= (y - minY);
        rect.origin.x = CGRectGetMinX(self.titleLabel.frame) + 4.0;
        rect.size.width = (maxX - rect.origin.x - 8.0);
        UILabel *label = self.summaryLabel;
        label.attributedText = [self.delegate attributedStringForSummary:self.assessmentGroup];
        label.frame = rect;
    }
}

- (CGFloat)preferredHeight
{
    CGFloat width = UIEdgeInsetsInsetRect(self.customContentView.bounds, self.tableView.separatorInset).size.width;
    return [WMAssessmentTableViewCell defaultPreferredHeightForAssessmentGroup:self.assessmentGroup width:width];
}

- (void)drawContentView:(CGRect)rect
{
    if (self.isHighlighted || self.isSelected) {
        self.titleLabel.textColor = [UIColor whiteColor];
    } else {
        self.titleLabel.textColor = [UIColor blackColor];
    }
    self.valueTextField.textColor = [UIColor blueColor];
}

@end
