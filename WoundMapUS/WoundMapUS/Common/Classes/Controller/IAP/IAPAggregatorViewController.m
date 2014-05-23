//
//  IAPAggregatorViewController.m
//  WoundPUMP
//
//  Created by Todd Guion on 11/1/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

#import "IAPAggregatorViewController.h"
#import "IAPNonConsumableViewController.h"
#import "IAPProduct.h"
#import "WMIAPProductOptionTableViewCell.h"
#import "IAPManager.h"
#import "WMUtilities.h"

@interface IAPAggregatorViewController ()

@property (strong, nonatomic) NSArray *sortedOptions;
@property (strong, nonatomic) NSMutableDictionary *productHash;
@property (strong, nonatomic) NSMutableDictionary *skProductHash;
@property (strong, nonatomic) NSDictionary *titleAttributes;
@property (strong, nonatomic) NSDictionary *priceAttributes;

@end

@implementation IAPAggregatorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.preferredContentSize = CGSizeMake(320.0, 405.0);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.tableView registerClass:[WMIAPProductOptionTableViewCell class] forCellReuseIdentifier:@"IAPProductOption"];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (nil == self.skProduct) {
        NSMutableSet *productIdSet = [[NSMutableSet alloc] init];
        [[self.iapProduct options] enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            [productIdSet addObject:[obj identifier]];
        }];
        [self skProductforProductSet:productIdSet];

    }
}

- (void)skProductforProductSet:(NSSet *)productIdSet
{
    [self showProgressView];
    __weak __typeof(&*self)weakSelf = self;
    [[IAPManager sharedInstance] productsWithProductIdSet:productIdSet
                                           successHandler:^(NSArray *skProductList) {
                                               [weakSelf hideProgressView];
                                               if ([skProductList count] > 0) {
                                                   [skProductList enumerateObjectsUsingBlock:^(id skProduct, NSUInteger idx, BOOL *stop) {
                                                       IAPProduct *iapProduct = [weakSelf.productHash objectForKey:[skProduct productIdentifier]];
                                                       [iapProduct updateIAProductWithSkProduct:skProduct];
                                                       [[iapProduct managedObjectContext] MR_saveToPersistentStoreAndWait];
                                                       [weakSelf.skProductHash setObject:skProduct forKey:[skProduct productIdentifier]];
                                                   }];
                                                   [weakSelf reloadData];
                                               } else {
                                                   NSString *message = [[NSString alloc] initWithFormat:@"%@ is unavailable.  Please try again later.", weakSelf.iapProduct.viewTitle];
                                                   [weakSelf iapFailureAlert:message];
                                               }
                                           } failureHandler:^(NSError *error) {
                                               [weakSelf hideProgressView];
                                               NSString* message = [[NSString alloc] initWithFormat:@"%@ Please try again later.", [error localizedDescription]];
                                               [weakSelf iapFailureAlert:message];
                                           }
     ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableDictionary *)productHash
{
    if (nil == _productHash) {
        _productHash = [[NSMutableDictionary alloc] init];
        [[self.iapProduct options] enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            [_productHash setObject:obj forKey:[obj identifier]];
        }];
    }
    return _productHash;
}

- (NSMutableDictionary *)skProductHash
{
    if (nil == _skProductHash) {
        _skProductHash = [[NSMutableDictionary alloc] init];
    }
    return _skProductHash;
}

- (NSDictionary *)titleAttributes
{
    if (nil == _titleAttributes) {
        _titleAttributes = [WMIAPProductOptionTableViewCell titleAttributes];
    }
    return _titleAttributes;
}
- (NSDictionary *)priceAttributes
{
    if (nil == _priceAttributes) {
        _priceAttributes = [WMIAPProductOptionTableViewCell priceAttributes];
    }
    return _priceAttributes;
}

#pragma mark - Core

- (NSArray *)sortedOptions
{
    if (nil == _sortedOptions) {
        _sortedOptions = [[self.iapProduct.options allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortRank" ascending:YES]]];
    }
    return _sortedOptions;
}

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = nil;
    switch (indexPath.section) {
        case 0: {
            reuseIdentifier = [super cellIdentifierForIndexPath:indexPath];
            break;
        }
        case 1: {
            reuseIdentifier = @"IAPProductOption";
            break;
        }
    }
    return reuseIdentifier;
}

#pragma mark - BaseViewController

- (void)clearDataCache
{
    [super clearDataCache];
    _sortedOptions = nil;
    _productHash = nil;
    _skProductHash = nil;
    _titleAttributes = nil;
    _priceAttributes = nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44.0;
    switch (indexPath.section) {
        case 0: {
            height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
            break;
        }
        case 1: {
            IAPProduct *iapProduct = [self.sortedOptions objectAtIndex:indexPath.row];
            height = [WMIAPProductOptionTableViewCell productOptionTitleTextHeight:iapProduct
                                                                 priceAttributes:self.priceAttributes
                                                                  textAttributes:self.titleAttributes
                                                                       tableView:tableView];
            break;
        }
    }
    return fmaxf(44.0, height);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: {
            [super tableView:tableView didSelectRowAtIndexPath:indexPath];
            break;
        }
        case 1: {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            IAPProduct *iapProduct = [self.sortedOptions objectAtIndex:indexPath.row];
            
            IAPBaseViewController *viewController = [[IAPNonConsumableViewController alloc] initWithNibName:@"IAPNonConsumableViewController" bundle:nil];
            [viewController setSelectedIapProduct: iapProduct];
            SKProduct *skProduct = [self.skProductHash objectForKey:[iapProduct identifier]];
            [viewController setSelectedSkProduct:skProduct];
            
            __weak __typeof(&*self)weakSelf = self;
            viewController.acceptHandler = self.acceptHandler;
            
            viewController.declineHandler = ^{
                // make sure this is called on the main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf dismissViewControllerAnimated:YES completion:^{
                        // nothing
                    }];
                });
            };
            
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
            navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
            [self presentViewController:navigationController animated:YES completion:^{
                // nothing
            }];

            
            break;
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    switch (section) {
        case 0: {
            // skip the price table view cell
            count = 4;
            break;
        }
        case 1: {
            count = [self.iapProduct.options count];
            break;
        }
    }
    return count;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: {
            [super configureCell:cell atIndexPath:indexPath];
            break;
        }
        case 1: {
            IAPProduct *iapProduct = [self.sortedOptions objectAtIndex:indexPath.row];
            WMIAPProductOptionTableViewCell *myCell = (WMIAPProductOptionTableViewCell *)cell;
            myCell.iapProduct = iapProduct;
            myCell.textLabel.font = self.textFont;
            myCell.textLabel.numberOfLines = 0;
            break;
        }
    }
}

@end
