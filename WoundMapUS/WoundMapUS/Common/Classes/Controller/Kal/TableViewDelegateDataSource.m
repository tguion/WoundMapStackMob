//
//  TableViewDelegateDataSource.m
//  WoundCare
//
//  Created by Todd Guion on 8/12/11.
//  Copyright 2011 etreasure consulting LLC. All rights reserved.
//

#import "TableViewDelegateDataSource.h"
#import "WMUtilities.h"
#import "WCAppDelegate.h"

@implementation TableViewDelegateDataSource

@dynamic appDelegate;
@synthesize managedObjectContext=_managedObjectContext;
@synthesize tableView;
@synthesize fetchedResultsController = __fetchedResultsController;
@dynamic fetchedResultsControllerEntityName, fetchedResultsControllerSortDescriptors;
@dynamic fetchedResultsControllerSectionNameKeyPath, fetchedResultsControllerCacheName;

- (WCAppDelegate *)appDelegate
{
	return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - Core

- (void)fetchedResultsControllerDidFetch
{
    // subclass should override
}

#pragma mark - UITableViewDataSource

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - NSFetchedResultsControllerDelegate

- (NSString *)fetchedResultsControllerEntityName
{
	return nil;
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
	return nil;
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
	return nil;
}

- (NSString *)fetchedResultsControllerSectionNameKeyPath
{
	return nil;
}

- (NSString *)fetchedResultsControllerCacheName
{
	return nil;
}

- (void)updateFetchRequest:(NSFetchRequest *)request
{
    
}

- (NSFetchedResultsController *)fetchedResultsController
{
	if (nil != __fetchedResultsController) {
		return __fetchedResultsController;
	}
	// else
	if (0 == [self.fetchedResultsControllerEntityName length]) {
		return nil;
	}
	// else
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:self.fetchedResultsControllerEntityName inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entityDescription];
	// set predicate
	fetchRequest.predicate = self.fetchedResultsControllerPredicate;
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    // Edit the sort key as appropriate.
    [fetchRequest setSortDescriptors:self.fetchedResultsControllerSortDescriptors];
    // update the request to fetch dictionary
    [self updateFetchRequest:fetchRequest];
    // Edit the section name key path and cache name if appropriate - nil for section name key path means "no sections".
    __fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																	 managedObjectContext:self.managedObjectContext 
																	   sectionNameKeyPath:self.fetchedResultsControllerSectionNameKeyPath 
																				cacheName:self.fetchedResultsControllerCacheName];
    if (fetchRequest.requestType == NSManagedObjectResultType) {
        __fetchedResultsController.delegate = self;
    }
	
	NSError *error = nil;
	@try {
		if (![__fetchedResultsController performFetch:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			DLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
	}
	@catch (NSException *exception) {
		DLog(@"Exception: %@", exception);
	}
	@finally {
		// nothing
	}
	[self fetchedResultsControllerDidFetch];
	return __fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)viewController
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex 
	 forChangeType:(NSFetchedResultsChangeType)type
{
	UITableView *aTableView = self.tableView;
	switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [aTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [aTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)viewController didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
	UITableView *aTableView = self.tableView;
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [aTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [aTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[aTableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [aTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [aTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	UITableView *aTableView = self.tableView;
    // DEBUG remove try/catch/finally
	@try {
		[aTableView endUpdates];
	}
	@catch (NSException * e) {
		DLog(@"**** TableViewDelegateDataSource.controllerDidChangeContent: ****");
		DLog(@"TableViewDelegateDataSource.controllerDidChangeContent: exception: %@", e);
		DLog(@"Debugging this method - remove when fixed");
	}
	@finally {
		// nothing
	}
}

@end
