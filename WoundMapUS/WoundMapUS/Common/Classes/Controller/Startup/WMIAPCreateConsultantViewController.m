//
//  WMIAPCreateConsultantViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/19/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMIAPCreateConsultantViewController.h"
#import "WMUtilities.h"

@interface WMIAPCreateConsultantViewController ()

@property (weak, nonatomic) IBOutlet UILabel *valuePropositionLabel;

- (IBAction)purchaseAction:(id)sender;
- (IBAction)declineAction:(id)sender;

@end

@implementation WMIAPCreateConsultantViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Become a Consultant";
    NSURL *valuePropositionURL = [[NSBundle mainBundle] URLForResource:@"CreateConsultantValueProposition" withExtension:@"txt"];
    NSError *error = nil;
    NSAttributedString *string = [[NSAttributedString alloc] initWithFileURL:valuePropositionURL options:nil documentAttributes:NULL error:&error];
    [WMUtilities logError:error];
    _valuePropositionLabel.attributedText = string;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)purchaseAction:(id)sender
{
    [self.delegate iapCreateConsultantViewControllerDidPurchase:self];
}

- (IBAction)declineAction:(id)sender
{
    [self.delegate iapCreateConsultantViewControllerDidDecline:self];
}

@end
