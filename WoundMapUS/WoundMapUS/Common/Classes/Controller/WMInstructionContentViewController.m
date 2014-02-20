//
//  WMInstructionContentViewController.m
//  WoundPUMP
//
//  Created by Todd Guion on 7/10/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "WMInstructionContentViewController.h"

@interface WMInstructionContentViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@end

@implementation WMInstructionContentViewController

@synthesize url=_url;
@synthesize webView=_webView, activityIndicatorView=_activityIndicatorView;

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
    self.webView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSError *error = nil;
    if ([_url isFileURL]) {
        [self.activityIndicatorView stopAnimating];
        NSString *introductionText = [NSString stringWithContentsOfURL:self.url encoding:NSUTF8StringEncoding error:&error];
        [_webView loadHTMLString:introductionText baseURL:nil];
    } else if (nil != _url) {
        [self.activityIndicatorView startAnimating];
        NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
        [self.webView loadRequest:request];
    } else {
        if (nil == _htmlString) {
            _htmlString = @"<div align=\"center\"><h2>No instuctional content available.</h2></div>";
        }
        [_webView loadHTMLString:_htmlString baseURL:nil];
    }
    self.navigationItem.backBarButtonItem.title = @"Back";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BaseViewController

- (void)updateTitle
{
    // nothing
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicatorView stopAnimating];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSURL *url = request.URL;
        [[UIApplication sharedApplication] openURL:url];
        return NO;
    }
    return YES;
}

@end
