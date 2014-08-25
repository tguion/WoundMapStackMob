//
//  IAPBaseViewController.m
//  WoundPUMP
//
//  Created by Todd Guion on 11/1/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "IAPBaseViewController.h"
#import "MBProgressHUD.h"
#import "IAPManager.h"
#import "IAPProduct.h"
#import "WMIAPProductTextTableViewCell.h"
#import "WMInstructionContentViewController.h"
#import "WMUtilities.h"


CGFloat const kIAPTextVerticalMargin = 4.0;

NSInteger const kPurchaseConfirmActionSheetTag = 1000;

@interface IAPBaseViewController () <UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UIView *actionContainerView;
@property (strong, nonatomic) IBOutlet UIView *descHTMLContainerView;
@property (strong, nonatomic) IBOutlet UITextView *descTextView;
@property (readonly, nonatomic) WMInstructionContentViewController *instructionContentViewController;

- (void)navigateToFeatureDetail;

@end

@implementation IAPBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"WoundMap Store";
    [self.tableView registerClass:[WMIAPProductTextTableViewCell class] forCellReuseIdentifier:@"IAPProductText"];
    self.tableView.tableFooterView = self.actionContainerView;
    self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0);
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSAttributedString *attributedString = self.iapProduct.descHTMLAttributedString;
    if (attributedString) {
        _descHTMLContainerView.frame = self.navigationController.view.bounds;
        _descTextView.attributedText = attributedString;
        [self.navigationController.view addSubview:_descHTMLContainerView];
        if (self.skProduct) {
            _descTextView.attributedText = [self.iapProduct descHTMLAttributedStringUpdatedWithSKProduct:self.skProduct];
        }
    }
}

- (void)setSelectedIapProduct:(IAPProduct *)selectedIapProduct
{
    _iapProduct = selectedIapProduct;
}

- (void)setSelectedSkProduct:(SKProduct *)selectedSkProduct
{
    _skProduct = selectedSkProduct;
}

#pragma mark - Core

- (void)setIapProduct:(IAPProduct *)iapProduct
{
    if (_iapProduct == iapProduct) {
        return;
    }
    // else
    [self willChangeValueForKey:@"iapProduct"];
    _iapProduct = iapProduct;
    [self didChangeValueForKey:@"iapProduct"];
    if (nil != iapProduct && !iapProduct.aggregatorFlag) {
        // call into SK to get the corresponding SKProduct
        [self skProductforProductId:self.iapProduct.identifier];
    }
}

- (UIFont *) textFont
{
    if (nil == _textFont) {
        _textFont = [UIFont systemFontOfSize:15.0];
    }
    return _textFont;
}

- (NSDictionary *)textAttributes
{
    if (nil == _textAttributes) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        _textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                            [self textFont], NSFontAttributeName,
                            [UIColor blackColor], NSForegroundColorAttributeName,
                            paragraphStyle, NSParagraphStyleAttributeName,
                            nil];
    }
    return _textAttributes;
}

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = nil;
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case kIAPProductFeaturesRow: {
                    reuseIdentifier = @"Cell";
                    break;
                }
                default: {
                    reuseIdentifier = @"IAPProductText";
                    break;
                }
            }
            break;
        }
    }
    return reuseIdentifier;
}

- (WMInstructionContentViewController *)instructionContentViewController
{
    return [[WMInstructionContentViewController alloc] initWithNibName:@"WMInstructionContentViewController" bundle:nil];
}

- (void)navigateToFeatureDetail
{
    WMInstructionContentViewController *instructionContentViewController = self.instructionContentViewController;
    NSString *htmlString = self.iapProduct.descHTMLValue;
    instructionContentViewController.htmlString = htmlString;
    instructionContentViewController.title = @"Feature Details";
    [self.navigationController pushViewController:instructionContentViewController animated:YES];
}

#pragma mark - Actions

- (IBAction)cancelAction:(id)sender
{
    [_descHTMLContainerView removeFromSuperview];
    _declineHandler();
    [self performSelector:@selector(clearAllReferences) withObject:nil afterDelay:0.0];
}

- (IBAction)purchaseAction:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Confirm purchase"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Purchase"
                                                    otherButtonTitles:nil];
    actionSheet.tag = kPurchaseConfirmActionSheetTag;
    [actionSheet showInView:self.view];
}

#pragma mark - BaseViewController

- (void)clearDataCache
{
    [super clearDataCache];
    _iapProduct = nil;
    _skProduct = nil;
    _textFont = nil;
    _textAttributes = nil;
    _acceptHandler = nil;
    _declineHandler = nil;
}

#pragma mark - UIActionSheetDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.cancelButtonIndex == buttonIndex) {
        [self cancelAction:nil];
        return;
    }
    // else
    if (actionSheet.tag == kPurchaseConfirmActionSheetTag) {
        [_descHTMLContainerView removeFromSuperview];
        if (actionSheet.destructiveButtonIndex == buttonIndex) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            // IAPManager will post notification with success or error for purchase
            [[IAPManager sharedInstance] buyProduct:self.skProduct];
            return;
        }
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44.0;
    CGRect textRect = CGRectZero;
    NSString *string = nil;
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case kIAPProductTitleRow: {
                    string = self.iapProduct.title;
                    break;
                }
                case kIAPProductDescriptionRow: {
                    string = self.iapProduct.desc;
                    break;
                }
                case kIAPProductPropositionRow: {
                    string = self.iapProduct.proposition;
                    break;
                }
            }
            break;
        }
    }
    if ([string length] > 0) {
        CGFloat viewWidth = CGRectGetWidth(tableView.bounds) - tableView.separatorInset.left;
        textRect = [string boundingRectWithSize:CGSizeMake(viewWidth, 5000.0)
                                                      options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                   attributes:self.textAttributes
                                                      context:nil];
        height = ceilf(textRect.size.height + 2.0 * kIAPTextVerticalMargin);
    }
    return fmaxf(44.0, height);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case kIAPProductFeaturesRow: {
                    [self navigateToFeatureDetail];
                    break;
                }
            }
            break;
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [self cellIdentifierForIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.separatorInset = self.tableView.separatorInset;
    NSString *string = nil;
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case kIAPProductTitleRow: {
                    string = self.iapProduct.title;
                    break;
                }
                case kIAPProductDescriptionRow: {
                    string = self.iapProduct.desc;
                    break;
                }
                case kIAPProductPropositionRow: {
                    string = self.iapProduct.proposition;
                    break;
                }
                case kIAPProductFeaturesRow: {
                    string = @"Features Details";
                    break;
                }
                case kIAPProductPriceRow: {
                    if (nil != self.skProduct) {
                        string = [NSString stringWithFormat:@"Price: %@", [NSNumberFormatter localizedStringFromNumber:self.skProduct.price numberStyle:NSNumberFormatterCurrencyStyle]];
                    }
                    break;
                }
            }
            break;
        }
    }
    if ([string length] > 0) {
        if ([cell isKindOfClass:[WMIAPProductTextTableViewCell class]]) {
            WMIAPProductTextTableViewCell *myCell = (WMIAPProductTextTableViewCell *)cell;
            myCell.textAttributes = self.textAttributes;
            myCell.text = string;
            myCell.verticalMargin = kIAPTextVerticalMargin;
        } else {
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.font = self.textFont;
            cell.textLabel.text = string;
        }
    }
}

#pragma mark - SKProduct Lookup

- (void)skProductforProductId:(NSString *)productId
{
    IAPManager *iapManager = [IAPManager sharedInstance];
    IAPProduct *iapProduct = self.iapProduct;
    NSManagedObjectContext *managedObjectContext = [iapProduct managedObjectContext];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak __typeof(&*self)weakSelf = self;
    [iapManager productWithProductId:productId
                      successHandler:^(NSArray *products) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              if ([products count] > 0) {
                                  weakSelf.skProduct = [products objectAtIndex:0];
                                  [iapProduct updateIAProductWithSkProduct:weakSelf.skProduct];
                                  if (_descHTMLContainerView.superview) {
                                      _descTextView.attributedText = [weakSelf.iapProduct descHTMLAttributedStringUpdatedWithSKProduct:weakSelf.skProduct];
                                  }
                                  [managedObjectContext MR_saveToPersistentStoreAndWait];
                              } else {
                                  NSString *message = [[NSString alloc] initWithFormat:@"%@ is unavailable.  Please try again later.", weakSelf.iapProduct.viewTitle];
                                  [weakSelf iapFailureAlert:message];
                              }
                              [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:NO];
                              [weakSelf reloadData];
                          });
                      } failureHandler:^(NSError *error) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:NO];
                              NSString* message = [[NSString alloc] initWithFormat:@"%@ Please try again later.", [error localizedDescription]];
                              [weakSelf iapFailureAlert:message];
                              [weakSelf reloadData];
                          });
                      }
     ];
}

- (void)reloadData
{
    [self.tableView reloadData];
}

#pragma mark - SKProduct notifications

- (void)registerForNotifications
{
    [super registerForNotifications];
    __weak __typeof(&*self)weakSelf = self;
    id observer =
    [[NSNotificationCenter defaultCenter]
         addObserverForName:kIAPManagerProductPurchasedNotification
         object:nil
         queue:[NSOperationQueue mainQueue]
         usingBlock:^(NSNotification *notification) {
             SKPaymentTransaction *transaction = notification.object;
            NSString * notifiedProductId = transaction.payment.productIdentifier;
            if ([notifiedProductId isEqualToString:weakSelf.skProduct.productIdentifier]) {
                [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:NO];
                id errorObj = [notification.userInfo objectForKey:kIAPPurchaseError];
                id cancelledTxnObj = [notification.userInfo objectForKey:kIAPTxnCancelled];
                if (nil == errorObj && nil == cancelledTxnObj) {
                    weakSelf.iapProduct.purchasedFlag = @YES;
                    [weakSelf.iapProduct.managedObjectContext MR_saveToPersistentStoreAndWait];
                    [weakSelf acceptHandler](transaction);
                } else if (errorObj || cancelledTxnObj) {
                    NSString* message = [[NSString alloc] initWithFormat:@"%@ Please try again later.", [errorObj localizedDescription]];
                    [weakSelf iapFailureAlert:message];
                }
            }
     }];
    [self.opaqueNotificationObservers addObject:observer];
}

#pragma mark Utilities
- (void) iapFailureAlert:(NSString*)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Feature Unavailable"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alertView show];
}


@end
