//
//  WMNoteViewController.m
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 2/22/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//

#import "WMNoteViewController.h"

@interface WMNoteViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@end

@implementation WMNoteViewController

@synthesize label=_label, textView=_textView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];    // don't understand why need this
    // Do any additional setup after loading the view from its nib.
    self.title = @"Enter Data";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAction:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.textView.text = self.delegate.note;
    // adjust for label
    NSString *labelText = self.delegate.label;
    if ([labelText length] > 0) {
        _label.text = labelText;
    } else {
        CGFloat minY = 20.0;
        CGRect aFrame = _textView.frame;
        aFrame.origin.y = minY;
        [_label removeFromSuperview];
        _label = nil;
        _textView.frame = aFrame;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Add code to clean up any of your own resources that are no longer necessary.
}

#pragma mark - Actions

- (IBAction)saveAction:(id)sender
{
    [self.delegate noteViewController:self didUpdateNote:self.textView.text];
}

- (IBAction)cancelAction:(id)sender
{
    [self.delegate noteViewControllerDidCancel:self withNote:self.textView.text];
}

#pragma mark - BaseViewController

- (void)updateTitle
{
    // nothing
}

@end
