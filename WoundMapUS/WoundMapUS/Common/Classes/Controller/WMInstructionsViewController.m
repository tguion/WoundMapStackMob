//
//  WMInstructionsViewController.m
//  WoundPUMP
//
//  Created by Todd Guion on 6/21/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMInstructionsViewController.h"
#import "WMInstructionContentViewController.h"
#import "WMInstruction.h"
#import "WMInstructionTableViewCell.h"

#define kVerticalMargin 4.0
#define kIconWidth 40.0

NSString *const kWoundMAPInstructionURL = @"http://www.mobilehealthware.com/app/woundmap-pump/";

@interface WMInstructionsViewController ()

@property (readonly, nonatomic) WMInstructionContentViewController *instructionContentViewController;
@property (readonly, nonatomic) NSDictionary *titleAttributes;
@property (readonly, nonatomic) NSDictionary *textAttributes;

- (IBAction)doneAction:(id)sender;

@end

@implementation WMInstructionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // navigation
    self.title = @"Instructions";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
    [self.tableView registerClass:[WMInstructionTableViewCell class] forCellReuseIdentifier:@"ModuleCell"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core

- (NSDictionary *)titleAttributes
{
    static NSDictionary *InstructionsTitleAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        InstructionsTitleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIFont systemFontOfSize:15.0], NSFontAttributeName,
                                                [UIColor blackColor], NSForegroundColorAttributeName,
                                                paragraphStyle, NSParagraphStyleAttributeName,
                                                nil];
    });
    return InstructionsTitleAttributes;
}

- (NSDictionary *)textAttributes
{
    static NSDictionary *InstructionsTextAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        InstructionsTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [UIFont systemFontOfSize:12.0], NSFontAttributeName,
                                       [UIColor darkGrayColor], NSForegroundColorAttributeName,
                                       paragraphStyle, NSParagraphStyleAttributeName,
                                       nil];
    });
    return InstructionsTextAttributes;
}

- (WMInstructionContentViewController *)instructionContentViewController
{
    return [[WMInstructionContentViewController alloc] initWithNibName:@"WMInstructionContentViewController" bundle:nil];
}

#pragma mark - Actions

- (IBAction)doneAction:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [self clearAllReferences];
    }];
}

#pragma mark - BaseViewController

- (void)updateTitle
{
    // nothing
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WMInstruction *instruction = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return [WMInstructionTableViewCell heightForTitle:instruction.title
                                               text:instruction.desc
                                    titleAttributes:self.titleAttributes
                                     textAttributes:self.textAttributes
                                              width:CGRectGetWidth(UIEdgeInsetsInsetRect(tableView.bounds, tableView.separatorInset)) - 32.0 // account for accessory view width
                                     verticalMargin:kVerticalMargin];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WMInstruction *instruction = [self.fetchedResultsController objectAtIndexPath:indexPath];
    WMInstructionContentViewController *instructionContentViewController = self.instructionContentViewController;
    instructionContentViewController.title = instruction.title;
    instructionContentViewController.url = [[NSBundle mainBundle] URLForResource:instruction.contentFileName withExtension:instruction.contentFileExtension];
    [self.navigationController pushViewController:instructionContentViewController animated:YES];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"ModuleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    WMInstruction *instruction = [self.fetchedResultsController objectAtIndexPath:indexPath];
    WMInstructionTableViewCell *myCell = (WMInstructionTableViewCell *)cell;
    myCell.verticalMargin = kVerticalMargin;
    myCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    myCell.title = instruction.title;
    myCell.text = instruction.desc;
    myCell.titleAttributes = self.titleAttributes;
    myCell.textAttributes = self.textAttributes;
}

#pragma mark - NSFetchedResultsController

- (NSString *)fetchedResultsControllerEntityName
{
    return @"WMInstruction";
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
    return nil;
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
    return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES]];
}

@end
