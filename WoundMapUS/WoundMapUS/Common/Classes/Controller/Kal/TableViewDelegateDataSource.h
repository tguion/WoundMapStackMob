//
//  TableViewDelegateDataSource.h
//  WoundCare
//
//  Created by Todd Guion on 8/12/11.
//  Copyright 2011 etreasure consulting LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WoundCareAppDelegate;

@interface TableViewDelegateDataSource : NSObject <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (readonly, nonatomic) WoundCareAppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (readonly, nonatomic) NSString *fetchedResultsControllerEntityName;
@property (readonly, nonatomic) NSPredicate *fetchedResultsControllerPredicate;
@property (readonly, nonatomic) NSArray *fetchedResultsControllerSortDescriptors;
@property (readonly, nonatomic) NSString *fetchedResultsControllerSectionNameKeyPath;
@property (readonly, nonatomic) NSString *fetchedResultsControllerCacheName;
- (void)updateFetchRequest:(NSFetchRequest *)request;

- (void)fetchedResultsControllerDidFetch;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
