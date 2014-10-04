//
//  WMWelcomeToWoundMapViewController_iPad.m
//  WoundMAP
//
//  Created by Todd Guion on 11/12/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMWelcomeToWoundMapViewController_iPad.h"
#import "ConstraintPack.h"

@interface WMWelcomeToWoundMapViewController_iPad ()

@property (strong, nonatomic) IBOutlet WMWelcomeToWoundMapViewController *welcomeViewController;      // loaded from nib
@property (strong, nonatomic) IBOutlet UIView *containerView;

@end

@implementation WMWelcomeToWoundMapViewController_iPad

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
    self.title = @"Welcome to WoundMap";
    
    UINavigationController *viewController = [[UINavigationController alloc] initWithRootViewController:self.welcomeViewController];
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    [self addChildViewController:viewController];
    UIView *childView = viewController.view;
    childView.translatesAutoresizingMaskIntoConstraints = NO;
    [_containerView addSubview:childView];
    
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_containerView, childView);
    
    NSMutableArray *constraints = [NSMutableArray array];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[childView]|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[childView]|" options:0 metrics:nil views:views]];

    [_containerView addConstraints:constraints];

    [viewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
