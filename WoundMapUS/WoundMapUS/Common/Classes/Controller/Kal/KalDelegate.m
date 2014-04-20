//
//  KalDelegate.m
//  WoundCare
//
//  Created by Todd Guion on 8/12/11.
//  Copyright 2011 etreasure consulting LLC. All rights reserved.
//

#import "KalDelegate.h"
#import "WMWound.h"
#import "WMWoundPhoto.h"
#import "WCAppDelegate.h"

@interface KalDelegate()
@property (readonly, nonatomic) WMWound *wound;
// support for calendar dates
@property (strong, nonatomic) NSDate *fromDate;
@property (strong, nonatomic) NSDate *toDate;
@end

@implementation KalDelegate

- (id)initWithDelegate:(id<KalDelegateDelegate>)aDelegate
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.delegate = aDelegate;
    }
    return self;
}

- (NSManagedObjectContext *)managedObjectContext
{
    return self.delegate.managedObjectContext;
}

- (WMWound *)wound
{
    return self.delegate.wound;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"WoundPhotoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:13.0];
		cell.detailTextLabel.font = [UIFont systemFontOfSize:11.0];
    }
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *woundPhotoDictionary = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.imageView.image = [woundPhotoDictionary objectForKey:@"thumbnailMini"];
	cell.textLabel.text = [NSDateFormatter localizedStringFromDate:[woundPhotoDictionary objectForKey:@"createdAt"] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"(%@x%@)", [woundPhotoDictionary objectForKey:@"imageWidth"], [woundPhotoDictionary objectForKey:@"imageHeight"]];
    WMWoundPhoto *selectedWoundPhoto = [self.delegate selectedWoundPhoto:self];
    // compare
    BOOL selectedFlag = NO;
    NSManagedObjectID *objectID = [woundPhotoDictionary objectForKey:@"objectID"];
    if ([[selectedWoundPhoto objectID] isTemporaryID]) {
        // our dictionary fetch will get permanent objectIds
        selectedFlag = [selectedWoundPhoto isEqual:[self.managedObjectContext objectWithID:objectID]];
    } else {
        selectedFlag = [objectID isEqual:[selectedWoundPhoto objectID]];
    }
    cell.accessoryType = (selectedFlag ? UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone);
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSDictionary *woundPhotoDictionary = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSManagedObjectID *objectID = [woundPhotoDictionary objectForKey:@"objectID"];
	[self.delegate kalDelegate:self didSelectWoundPhotoObjectID:objectID];
	[tableView reloadData];
}

#pragma mark - NSFetchedResultsController

- (NSString *)fetchedResultsControllerEntityName
{
	return @"WMWoundPhoto";
}

- (NSPredicate *)fetchedResultsControllerPredicate
{
	if (nil == self.fromDate || nil == self.toDate) {
		return [NSPredicate predicateWithValue:NO];
	}
	// else
	return [NSPredicate predicateWithFormat:@"wound == %@ AND createdAt >= %@ AND createdAt <= %@", self.wound, self.fromDate, self.toDate];
}

- (NSArray *)fetchedResultsControllerSortDescriptors
{
	return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
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
    [WMWoundPhoto updateFetchRequestForDictionaryType:request thumbnailType:WoundPhotoThumbnailTypeMini];
}

#pragma mark - KalDataSource

// delegate call from KalViewController asking self to load data for dates
// respond to delegate when data is loaded
- (void)presentingDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate delegate:(id<KalDataSourceCallbacks>)aDelegate
{
    if (nil == self.tableView) {
        self.tableView = aDelegate.tableView;
    }
	self.fromDate = fromDate;
	self.toDate = toDate;
    //DLog(@"KalDelegate.presentingDatesFrom:to:delegate: called - %@, %@, %@", fromDate, toDate, delegate);
	self.fetchedResultsController = nil;
	[aDelegate loadedDataSource:self];
}

- (NSArray *)markedDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
    //DLog(@"KalDelegate.markedDatesFrom:to: called - %@, %@", fromDate, toDate);
	return [[self.fetchedResultsController fetchedObjects] valueForKey:@"createdAt"];
}

- (void)loadItemsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
	self.fromDate = fromDate;
	self.toDate = toDate;
	self.fetchedResultsController = nil;
    //DLog(@"KalDelegate.loadItemsFromDate:to: called - %@, %@", fromDate, toDate);
    [self.delegate kalDelegate:self didLoadWoundPhotosForTable:[self.fetchedResultsController fetchedObjects]];
}

- (void)removeAllItems
{
	//DLog(@"KalDelegate.removeAllItems called");
}

@end
