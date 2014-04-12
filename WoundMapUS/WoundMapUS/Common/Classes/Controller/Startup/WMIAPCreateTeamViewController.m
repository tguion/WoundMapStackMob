//
//  WMIAPCreateTeamViewController.m
//  WoundMapUS
//
//  Created by Todd Guion on 2/16/14.
//  Copyright (c) 2014 MobileHealthWare. All rights reserved.
//

#import "WMIAPCreateTeamViewController.h"
#import "ConstraintPack.h"

@interface WMIAPCreateTeamViewController ()

@property (strong, nonatomic) IBOutlet UITextView *textView;

@property (nonatomic) UIEdgeInsets contentInsets;

- (IBAction)purchaseAction:(id)sender;
- (IBAction)declineAction:(id)sender;

@end

@implementation WMIAPCreateTeamViewController

@synthesize contentInsets = _contentInsets;

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
    [self setEdgesForExtendedLayout:UIRectEdgeNone];    // don't understand why need this
    // Do any additional setup after loading the view from its nib.
    self.title = @"Create Team";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(declineAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Continue" style:UIBarButtonItemStylePlain target:self action:@selector(purchaseAction:)];
    // load the text view
    NSURL *htmlString = [[NSBundle mainBundle]
                         URLForResource: @"TeamMemberIAPDesc" withExtension:@"html"];
    NSAttributedString *stringWithHTMLAttributes = [[NSAttributedString alloc] initWithFileURL:htmlString
                                                                                       options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType}
                                                                            documentAttributes:nil
                                                                                         error:NULL];
    _textView.attributedText = stringWithHTMLAttributes;
}

- (void)updateTextViewContraints
{
    UIEdgeInsets insets = self.contentInsets;

    RemoveConstraints(self.view.constraints);
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings (_textView);
    NSDictionary *metrics = @{@"Top" : @(insets.top + 20),
                              @"Bottom" : @(insets.bottom + 20)};
    NSMutableArray *constraints = [NSMutableArray array];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-Top-[_textView]-Bottom-|"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:viewsDictionary]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_textView]-|" options:NSLayoutFormatAlignAllLeading metrics:nil views:viewsDictionary]];
    [self.view addConstraints:constraints];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self updateTextViewContraints];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)purchaseAction:(id)sender
{
    [self.delegate iapCreateTeamViewControllerDidPurchase:self];
}

- (IBAction)declineAction:(id)sender
{
    [self.delegate iapCreateTeamViewControllerDidDecline:self];
}

- (UIEdgeInsets)contentInsets
{
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    
    // grab our frame in window coordinates
    CGRect rect = [self.view convertRect:self.view.frame toView:nil];
    
    // No value has been assigned, so we need to compute it
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    UITabBar *tabBar = self.tabBarController.tabBar;
    UIApplication *application = [UIApplication sharedApplication];
    
    UIEdgeInsets insets = UIEdgeInsetsZero;
    
    if (!application.statusBarHidden) {
        // The status bar is WEIRD. It doesn't seem to adjust when rotated.
        CGFloat height = (UIInterfaceOrientationIsPortrait(orientation) ? CGRectGetHeight(application.statusBarFrame) : CGRectGetWidth(application.statusBarFrame));
        
        if (CGRectGetMinY(rect) < height)
            insets.top += 20;
    }
    
    // If the navigation bar ISN'T hidden, we'll set our top inset to the bottom of the navigation bar. This allows the system to position things correctly to account for the double height status bar.
    if (!navigationBar.hidden) {
        // During rotation, the navigation bar (and possibly tab bar) doesn't resize immediately. Force it to have it's new size.
        [navigationBar sizeToFit];
        CGRect frame = navigationBar.frame;
        if (CGRectIntersectsRect(rect, frame))
            insets.top = CGRectGetMaxY(frame);
    }
    
    if (!tabBar.hidden) {
        // During rotation, the navigation bar (and possibly tab bar) doesn't resize immediately. Force it to have it's new size.
        [tabBar sizeToFit];
        CGRect frame = tabBar.frame;
        if (CGRectIntersectsRect(rect, frame))
            insets.bottom = CGRectGetHeight(frame);
    }
    
    _contentInsets = insets;
    
    return insets;
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets
{
    _contentInsets = contentInsets;
    // I hope this triggers the VCs -viewDidLayoutSubviews method, which is where view layout should occur.
    [self.view setNeedsLayout];
}

@end
