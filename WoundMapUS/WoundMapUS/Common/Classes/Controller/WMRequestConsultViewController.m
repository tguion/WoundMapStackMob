//
//  WMRequestConsultViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 5/19/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMRequestConsultViewController.h"
#import "WMUtilities.h"

@interface WMRequestConsultViewController ()

@property (strong, nonatomic) IBOutlet UIView *introductionContainerView;
@property (strong, nonatomic) IBOutlet UITextView *introductionTextView;

@end

@implementation WMRequestConsultViewController

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
    self.title = @"Request Consult";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
    NSURL *htmlURL = [[NSBundle mainBundle] URLForResource:@"RequestConsultIntroduction" withExtension:@"html"];
    NSError *error = nil;
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithFileURL:htmlURL
                                                                               options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType}
                                                                    documentAttributes:nil
                                                                                 error:&error];
    if (error) {
        [WMUtilities logError:error];
    }
    _introductionTextView.attributedText = attributedString;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGRect frame = self.view.frame;
    frame.origin.y += 64.0;
    frame.size.height -= 64.0;
    _introductionContainerView.frame = frame;
    [self.navigationController.view addSubview:_introductionContainerView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)dismissIntroduction:(id)sender
{
    [_introductionContainerView removeFromSuperview];
}

- (IBAction)doneAction:(id)sender
{
    [self.delegate requestConsultViewControllerDidFinish:self];
}

@end
