//
//  CoreDataHelper.m
//  Grocery Cloud
//
//  Created by Tim Roadley on 18/09/13.
//  Copyright (c) 2013 Tim Roadley. All rights reserved.
//

#import "CoreDataHelper.h"
#import "CoreDataImporter.h"
#import "Faulter.h"
#import "WCAppDelegate.h"

@interface CoreDataHelper ()
@property (readonly, nonatomic) WCAppDelegate *appDelegate;
- (void)alertUserNetworkReachabilityChanged:(SMNetworkStatus)status;
@end

@implementation CoreDataHelper
#define debug 1

- (WCAppDelegate *)appDelegate
{
    return (WCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - FILES

NSString *storeFilename = @"WoundMap.sqlite";
NSString *sourceStoreFilename = @"DefaultData.sqlite";

#pragma mark - Alerts

- (void)alertUserNetworkReachabilityChanged:(SMNetworkStatus)status
{
    if (nil == self.appDelegate.user) {
        return;
    }
    // else
    NSString *title = @"Network reachability changed";
    NSString *message = nil;
    switch (status) {
        case SMNetworkStatusUnknown: {
            message = @"Network reachability in unknown";
            break;
        }
        case SMNetworkStatusNotReachable: {
            message = @"The network is no longer reachable. You will not receive updates from team members, nor team members have access to patient data you enter until the network becomes reachable again.";
            break;
        }
        case SMNetworkStatusReachable: {
            message = @"The network is now reachable. You will receive updates from team members, and team members will have access to patient data you entered while the network was unavailable.";
            break;
        }
        default:
            break;
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - PATHS

- (NSString *)applicationDocumentsDirectory {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class,NSStringFromSelector(_cmd));
    }
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES) lastObject];
}

- (NSURL *)applicationStoresDirectory {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSURL *storesDirectory = [[NSURL fileURLWithPath:[self applicationDocumentsDirectory]] URLByAppendingPathComponent:@"Stores"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[storesDirectory path]]) {
        NSError *error = nil;
        if ([fileManager createDirectoryAtURL:storesDirectory
                  withIntermediateDirectories:YES
                                   attributes:nil
                                        error:&error]) {
            if (debug==1) {
                NSLog(@"Successfully created Stores directory");}
        }
        else {NSLog(@"FAILED to create Stores directory: %@", error);}
    }
    return storesDirectory;
}

- (NSURL *)storeURL {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [[self applicationStoresDirectory] URLByAppendingPathComponent:storeFilename];
}

- (NSURL *)sourceStoreURL {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    return [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                   pathForResource:[sourceStoreFilename stringByDeletingPathExtension]
                                   ofType:[sourceStoreFilename pathExtension]]];
}

#pragma mark - SETUP

- (id)init
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    self = [super init];
    if (!self) {return nil;}
    
    _model = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    // Use StackMob Cache Store in case network is unavailable
    SM_CACHE_ENABLED = YES;
    // Verbose logging
    SM_CORE_DATA_DEBUG = NO;
    // synch when network comes online
    _synchWithStackMobOnNetworkAvailable = YES;
    
    // APIVersion 0 = Dev, 1 = Prod
    _stackMobClient  = [[SMClient alloc] initWithAPIVersion:@"0" publicKey:@"69230b76-7939-4342-8d8f-4fb739e2aef4"];
    _stackMobStore = [_stackMobClient coreDataStoreWithManagedObjectModel:_model];
    // fetch cloud then cache - each view controller should update the policy as needed
    _stackMobStore.fetchPolicy = SMFetchPolicyTryNetworkElseCache;
    
    __weak SMCoreDataStore *cds = _stackMobStore;
    __weak __typeof(self) weakSelf = self;
    [_stackMobClient.session.networkMonitor setNetworkStatusChangeBlockWithFetchPolicyReturn:^SMFetchPolicy(SMNetworkStatus status) {
        [weakSelf alertUserNetworkReachabilityChanged:status];
        if (status == SMNetworkStatusReachable) {
            if (weakSelf.synchWithStackMobOnNetworkAvailable) {
                [cds syncWithServer];
                return SMFetchPolicyTryNetworkElseCache;
            }
            // else
            return SMFetchPolicyCacheOnly;
        }
        // else
        return SMFetchPolicyCacheOnly;
    }];
    
    _context = [_stackMobStore contextForCurrentThread];
    
    _importContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_importContext performBlockAndWait:^{
        [_importContext setParentContext:_context];
        [_importContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        [_importContext setContextShouldObtainPermanentIDsBeforeSaving:YES];
        [_importContext setUndoManager:nil]; // the default on iOS
    }];
    
    _sourceContext =
    [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_sourceContext performBlockAndWait:^{
        [_sourceContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        [_sourceContext setParentContext:_context];
        [_sourceContext setContextShouldObtainPermanentIDsBeforeSaving:YES];
        [_sourceContext setUndoManager:nil]; // the default on iOS
    }];
    return self;
}

- (void)loadStore
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (_store) {return;} // Don’t load store if it’s already loaded
    
    BOOL useMigrationManager = NO;
    if (useMigrationManager &&
        [self isMigrationNecessaryForStore:[self storeURL]]) {
        [self performBackgroundManagedMigrationForStore:[self storeURL]];
    } else {
        NSDictionary *options =
        @{
          NSMigratePersistentStoresAutomaticallyOption:@YES
          ,NSInferMappingModelAutomaticallyOption:@YES
          //,NSSQLitePragmasOption: @{@"journal_mode": @"DELETE"} // Uncomment to disable WAL journal mode
          };
        NSError *error = nil;
        _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                            configuration:nil
                                                      URL:[self storeURL]
                                                  options:options
                                                    error:&error];
        if (!_store) {
            NSLog(@"Failed to add store. Error: %@", error);abort();
        } else {
            NSLog(@"Successfully added store: %@", _store);
        }
    }
    
}
- (void)loadSourceStore
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (_sourceStore) {return;} // Don’t load source store if it's already loaded
    
    NSDictionary *options =
    @{
      NSReadOnlyPersistentStoreOption:@YES
      };
    NSError *error = nil;
    _sourceStore =
    [_sourceCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                     configuration:nil
                                               URL:[self sourceStoreURL]
                                           options:options
                                             error:&error];
    if (!_sourceStore) {
        NSLog(@"Failed to add source store. Error: %@",
              error);abort();
    } else {
        NSLog(@"Successfully added source store: %@", _sourceStore);
    }
}
- (void)setupCoreData {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    //[self setDefaultDataStoreAsInitialStore];
    //[self loadStore];
    //[self importGroceryDudeTestData];
    //[self checkIfDefaultDataNeedsImporting];
}

#pragma mark - SAVING

- (void)saveContext
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSManagedObjectContext *stackMobContext =
    [_stackMobStore contextForCurrentThread];
    if (!stackMobContext) {
        NSLog(@"StackMob context is nil, so FAILED to save");
        return;
    }
    
    NSError *error;
    [stackMobContext saveAndWait:&error];
    if (!error) {
        NSLog(@"SAVED changes to StackMob store (in the foreground)");
    } else {
        NSLog(@"FAILED to save changes to StackMob store (in the foreground): %@", error);
    }
}

- (void)backgroundSaveContext
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSManagedObjectContext *stackMobContext = [_stackMobStore contextForCurrentThread];
    if (!stackMobContext) {
        NSLog(@"StackMob context is nil, so FAILED to save");
        return;
    }
    
    [stackMobContext saveOnSuccess:^{
        NSLog(@"SAVED changes to StackMob store (in the background)");
    } onFailure:^(NSError *error) {
        NSLog(@"FAILED to save changes to StackMob store (in the background): %@", error);
    }];
}

#pragma mark - MIGRATION MANAGER

- (BOOL)isMigrationNecessaryForStore:(NSURL*)storeUrl
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self storeURL].path]) {
        if (debug==1) {NSLog(@"SKIPPED MIGRATION: Source database missing.");}
        return NO;
    }
    NSError *error = nil;
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:storeUrl error:&error];
    NSManagedObjectModel *destinationModel = _coordinator.managedObjectModel;
    if ([destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata]) {
        if (debug==1) {
            NSLog(@"SKIPPED MIGRATION: Source is already compatible");}
        return NO;
    }
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"migrationProgress"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            float progress = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
            self.migrationVC.progressView.progress = progress;
            int percentage = progress * 100;
            NSString *string =
            [NSString stringWithFormat:@"Migration Progress: %i%%", percentage];
            NSLog(@"%@",string);
            self.migrationVC.label.text = string;
        });
    }
}

- (BOOL)replaceStore:(NSURL*)old withStore:(NSURL*)new
{
    BOOL success = NO;
    NSError *Error = nil;
    if ([[NSFileManager defaultManager] removeItemAtURL:old error:&Error]) {
        Error = nil;
        if ([[NSFileManager defaultManager]
             moveItemAtURL:new toURL:old error:&Error]) {
            success = YES;
        } else {
            if (debug==1) {
                NSLog(@"FAILED to re-home new store %@", Error);
            }
        }
    } else {
        if (debug==1) {
            NSLog(@"FAILED to remove old store %@: Error:%@", old, Error);
        }
    }
    return success;
}

- (BOOL)migrateStore:(NSURL*)sourceStore
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    BOOL success = NO;
    NSError *error = nil;
    // STEP 1 - Gather the Source, Destination and Mapping Model
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator
                                    metadataForPersistentStoreOfType:NSSQLiteStoreType
                                    URL:sourceStore
                                    error:&error];
    
    NSManagedObjectModel *sourceModel =
    [NSManagedObjectModel mergedModelFromBundles:nil
                                forStoreMetadata:sourceMetadata];
    
    NSManagedObjectModel *destinModel = _model;
    
    NSMappingModel *mappingModel =
    [NSMappingModel mappingModelFromBundles:nil
                             forSourceModel:sourceModel
                           destinationModel:destinModel];
    
    // STEP 2 - Perform migration, assuming the mapping model isn't null
    if (mappingModel) {
        NSError *error = nil;
        NSMigrationManager *migrationManager =
        [[NSMigrationManager alloc] initWithSourceModel:sourceModel
                                       destinationModel:destinModel];
        [migrationManager addObserver:self
                           forKeyPath:@"migrationProgress"
                              options:NSKeyValueObservingOptionNew
                              context:NULL];
        
        NSURL *destinStore =
        [[self applicationStoresDirectory]
         URLByAppendingPathComponent:@"Temp.sqlite"];
        
        success =
        [migrationManager migrateStoreFromURL:sourceStore
                                         type:NSSQLiteStoreType options:nil
                             withMappingModel:mappingModel
                             toDestinationURL:destinStore
                              destinationType:NSSQLiteStoreType
                           destinationOptions:nil
                                        error:&error];
        if (success) {
            // STEP 3 - Replace the old store with the new migrated store
            if ([self replaceStore:sourceStore withStore:destinStore]) {
                if (debug==1) {
                    NSLog(@"SUCCESSFULLY MIGRATED %@ to the Current Model",
                          sourceStore.path);}
                [migrationManager removeObserver:self
                                      forKeyPath:@"migrationProgress"];
            }
        }
        else {
            if (debug==1) {NSLog(@"FAILED MIGRATION: %@",error);}
        }
    }
    else {
        if (debug==1) {NSLog(@"FAILED MIGRATION: Mapping Model is null");}
    }
    return YES; // indicates migration has finished, regardless of outcome
}

- (void)performBackgroundManagedMigrationForStore:(NSURL*)storeURL
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    // Show migration progress view preventing the user from using the app
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.migrationVC =
    [sb instantiateViewControllerWithIdentifier:@"migration"];
    UIApplication *sa = [UIApplication sharedApplication];
    UINavigationController *nc =
    (UINavigationController*)sa.keyWindow.rootViewController;
    [nc presentViewController:self.migrationVC animated:NO completion:nil];
    
    // Perform migration in the background, so it doesn't freeze the UI.
    // This way progress can be shown to the user
    dispatch_async(
                   dispatch_get_global_queue(
                                             DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                       BOOL done = [self migrateStore:storeURL];
                       if(done) {
                           // When migration finishes, add the newly migrated store
                           dispatch_async(dispatch_get_main_queue(), ^{
                               NSError *error = nil;
                               _store =
                               [_coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                          configuration:nil
                                                                    URL:[self storeURL]
                                                                options:nil
                                                                  error:&error];
                               if (!_store) {
                                   NSLog(@"Failed to add a migrated store. Error: %@",
                                         error);abort();}
                               else {
                                   NSLog(@"Successfully added a migrated store: %@",
                                         _store);}
                               [self.migrationVC dismissViewControllerAnimated:NO
                                                                    completion:nil];
                               self.migrationVC = nil;
                           });
                       }
                   });
}

#pragma mark - VALIDATION ERROR HANDLING

- (void)showValidationError:(NSError *)anError
{
    if (anError && [anError.domain isEqualToString:@"NSCocoaErrorDomain"]) {
        NSArray *errors = nil;  // holds all errors
        NSString *txt = @""; // the error message text of the alert
        
        // Populate array with error(s)
        if (anError.code == NSValidationMultipleErrorsError) {
            errors = [anError.userInfo objectForKey:NSDetailedErrorsKey];
        } else {
            errors = [NSArray arrayWithObject:anError];
        }
        // Display the error(s)
        if (errors && errors.count > 0) {
            // Build error message text based on errors
            for (NSError * error in errors) {
                NSString *entity =
                [[[error.userInfo objectForKey:@"NSValidationErrorObject"]entity]name];
                
                NSString *property =
                [error.userInfo objectForKey:@"NSValidationErrorKey"];
                
                switch (error.code) {
                    case NSValidationRelationshipDeniedDeleteError:
                        txt = [txt stringByAppendingFormat:
                               @"%@ delete was denied because there are associated %@\n(Error Code %li)\n\n", entity, property, (long)error.code];
                        break;
                    case NSValidationRelationshipLacksMinimumCountError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' relationship count is too small (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationRelationshipExceedsMaximumCountError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' relationship count is too large (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationMissingMandatoryPropertyError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' property is missing (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationNumberTooSmallError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' number is too small (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationNumberTooLargeError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' number is too large (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationDateTooSoonError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' date is too soon (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationDateTooLateError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' date is too late (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationInvalidDateError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' date is invalid (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationStringTooLongError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' text is too long (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationStringTooShortError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' text is too short (Code %li).", property, (long)error.code];
                        break;
                    case NSValidationStringPatternMatchingError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' text doesn't match the specified pattern (Code %li).", property, (long)error.code];
                        break;
                    case NSManagedObjectValidationError:
                        txt = [txt stringByAppendingFormat:
                               @"generated validation error (Code %li)", (long)error.code];
                        break;
                        
                    default:
                        txt = [txt stringByAppendingFormat:
                               @"Unhandled error code %li in showValidationError method", (long)error.code];
                        break;
                }
            }
            // display error message txt message
            UIAlertView *alertView =
            [[UIAlertView alloc] initWithTitle:@"Validation Error"
             
                                       message:[NSString stringWithFormat:@"%@Please double-tap the home button and close this application by swiping the application screenshot upwards",txt]
                                      delegate:nil
                             cancelButtonTitle:nil
                             otherButtonTitles:nil];
            [alertView show];
        }
    }
}

#pragma mark – DATA IMPORT

- (BOOL)isDefaultDataAlreadyImportedForStoreWithURL:(NSURL*)url
                                             ofType:(NSString*)type
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSError *error;
    NSDictionary *dictionary =
    [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:type
                                                               URL:url
                                                             error:&error];
    if (error) {
        NSLog(@"Error reading persistent store metadata: %@",
              error.localizedDescription);
    }
    else {
        NSNumber *defaultDataAlreadyImported =
        [dictionary valueForKey:@"DefaultDataImported"];
        if (![defaultDataAlreadyImported boolValue]) {
            NSLog(@"Default Data has NOT already been imported");
            return NO;
        }
    }
    if (debug==1) {NSLog(@"Default Data HAS already been imported");}
    return YES;
}

- (void)checkIfDefaultDataNeedsImporting
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (![self isDefaultDataAlreadyImportedForStoreWithURL:[self storeURL]
                                                    ofType:NSSQLiteStoreType]) {
        self.importAlertView =
        [[UIAlertView alloc] initWithTitle:@"Import Default Data?"
                                   message:@"If you've never used Grocery Cloud before then some default data might help you understand how to use it. Tap 'Import' to import default data. Tap 'Cancel' to skip the import, especially if you've done this before on other devices."
                                  delegate:self
                         cancelButtonTitle:@"Cancel"
                         otherButtonTitles:@"Import", nil];
        [self.importAlertView show];
    }
}

- (void)importFromXML:(NSURL*)url
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    self.parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    self.parser.delegate = self;
    
    NSLog(@"**** START PARSE OF %@", url.path);
    [self.parser parse];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"SomethingChanged" object:nil];
    NSLog(@"***** END PARSE OF %@", url.path);
}

- (void)setDefaultDataAsImportedForStore:(NSPersistentStore*)aStore
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // get metadata dictionary
    NSMutableDictionary *dictionary =
    [NSMutableDictionary dictionaryWithDictionary:[[aStore metadata] copy]];
    
    if (debug==1) {
        NSLog(@"__Store Metadata BEFORE changes__ \n %@", dictionary);
    }
    
    // edit metadata dictionary
    [dictionary setObject:@YES forKey:@"DefaultDataImported"];
    
    // set metadata dictionary
    [self.coordinator setMetadata:dictionary forPersistentStore:aStore];
    
    if (debug==1) {NSLog(@"__Store Metadata AFTER changes__ \n %@", dictionary);}
}

- (void)setDefaultDataStoreAsInitialStore
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:self.storeURL.path]) {
        NSURL *defaultDataURL =
        [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                pathForResource:@"DefaultData" ofType:@"sqlite"]];
        NSError *error;
        if (![fileManager copyItemAtURL:defaultDataURL
                                  toURL:self.storeURL
                                  error:&error]) {
            NSLog(@"DefaultData.sqlite copy FAIL: %@",
                  error.localizedDescription);
        }
        else {
            NSLog(@"A copy of DefaultData.sqlite was set as the initial store for %@",
                  self.storeURL.path);
        }
    }
}

- (void)deepCopyFromPersistentStore:(NSURL*)url
{
    if (debug==1) {
        NSLog(@"Running %@ '%@' %@", self.class,
              NSStringFromSelector(_cmd),url.path);
    }
    // Periodically refresh the interface during the import
    _importTimer =
    [NSTimer scheduledTimerWithTimeInterval:2.0
                                     target:self
                                   selector:@selector(somethingChanged)
                                   userInfo:nil
                                    repeats:YES];
    
    [_sourceContext performBlock:^{
        
        NSLog(@"*** STARTED DEEP COPY FROM DEFAULT DATA PERSISTENT STORE ***");
        
        NSArray *entitiesToCopy = [NSArray arrayWithObjects:
                                   @"LocationAtHome",@"LocationAtShop",@"Unit",@"Item", nil];
        
        CoreDataImporter *importer = [[CoreDataImporter alloc]
                                      initWithUniqueAttributes:[self selectedUniqueAttributes]];
        
        [importer deepCopyEntities:entitiesToCopy
                       fromContext:_sourceContext
                         toContext:_importContext];
        
        [_context performBlock:^{
            // Stop periodically refreshing the interface
            [_importTimer invalidate];
            
            // Tell the interface to refresh once import completes
            [self somethingChanged];
        }];
        
        NSLog(@"*** FINISHED DEEP COPY FROM DEFAULT DATA PERSISTENT STORE ***");
    }];
}

#pragma mark – TEST DATA IMPORT (This code is Grocery Cloud data specific)

- (void)importGroceryDudeTestData
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSNumber *imported =
    [[NSUserDefaults standardUserDefaults] objectForKey:@"TestDataImport"];
    
    if (!imported.boolValue) {
        NSLog(@"Importing test data...");
        [_importContext performBlock:^{
            
            NSManagedObject *locationAtHome =
            [NSEntityDescription insertNewObjectForEntityForName:@"LocationAtHome"
                                          inManagedObjectContext:_importContext];
            NSManagedObject *locationAtShop =
            [NSEntityDescription insertNewObjectForEntityForName:@"LocationAtShop"
                                          inManagedObjectContext:_importContext];
            [locationAtHome setValue:@"Test Home Location" forKey:@"storedIn"];
            [locationAtShop setValue:@"Test Shop Location" forKey:@"aisle"];
            
            for (int a = 1; a < 101; a++) {
                
                @autoreleasepool {
                    
                    // Insert Item
                    NSManagedObject *item =
                    [NSEntityDescription insertNewObjectForEntityForName:@"Item"
                                                  inManagedObjectContext:_importContext];
                    [item setValue:[NSString stringWithFormat:@"Test Item %i",a]
                            forKey:@"name"];
                    [item setValue:locationAtHome
                            forKey:@"locationAtHome"];
                    [item setValue:locationAtShop
                            forKey:@"locationAtShop"];
                    
                    // Insert Photo
                    NSManagedObject *photo =
                    [NSEntityDescription insertNewObjectForEntityForName:@"Item_Photo"
                                                  inManagedObjectContext:_importContext];
                    [photo setValue:UIImagePNGRepresentation(
                                                             [UIImage imageNamed:@"GroceryHead.png"])
                             forKey:@"data"];
                    
                    // Relate Item and Photo
                    [item setValue:photo forKey:@"photo"];
                    
                    NSLog(@"Inserting %@", [item valueForKey:@"name"]);
                    [Faulter faultObjectWithID:photo.objectID
                                     inContext:_importContext];
                    [Faulter faultObjectWithID:item.objectID
                                     inContext:_importContext];
                }
            }
            [_importContext reset];
            
            // ensure import was a one off
            [[NSUserDefaults standardUserDefaults]
             setObject:[NSNumber numberWithBool:YES]
             forKey:@"TestDataImport"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
    }
    else {
        NSLog(@"Skipped test data import");
    }
}

#pragma mark - DELEGATE: UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (alertView == self.importAlertView) {
        if (buttonIndex == 1) { // The ‘Import’ button on the importAlertView
            
            NSLog(@"Default Data Import Approved by User");
            // XML Import
            [_importContext performBlock:^{
                [self importFromXML:[[NSBundle mainBundle]
                                     URLForResource:@"DefaultData"
                                     withExtension:@"xml"]];
            }];
            // Deep Copy Import From Persistent Store
            //[self loadSourceStore];
            //[self deepCopyFromPersistentStore:[self sourceStoreURL]];
            
        } else {
            NSLog(@"Default Data Import Cancelled by User");
        }
        // Set the data as imported regardless of the user's decision
        [self setDefaultDataAsImportedForStore:_store];
    }
}

#pragma mark - UNIQUE ATTRIBUTE SELECTION (This code is Grocery Cloud data specific and is used when instantiating CoreDataImporter)

- (NSDictionary*)selectedUniqueAttributes
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSMutableArray *entities   = [NSMutableArray new];
    NSMutableArray *attributes = [NSMutableArray new];
    
    // Select an attribute in each entity for uniqueness
    [entities addObject:@"Item"];[attributes addObject:@"name"];
    [entities addObject:@"Unit"];[attributes addObject:@"name"];
    [entities addObject:@"LocationAtHome"];[attributes addObject:@"storedIn"];
    [entities addObject:@"LocationAtShop"];[attributes addObject:@"aisle"];
    [entities addObject:@"Item_Photo"];[attributes addObject:@"data"];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:attributes
                                                           forKeys:entities];
    return dictionary;
}

#pragma mark - DELEGATE: NSXMLParser (This code is Grocery Cloud data specific)

- (void)parser:(NSXMLParser *)parser
parseErrorOccurred:(NSError *)parseError
{
    if (debug==1) {
        NSLog(@"Parser Error: %@", parseError.localizedDescription);
    }
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    
    [self.importContext performBlockAndWait:^{
        
        // STEP 1: Process only the 'item' element in the XML file
        if ([elementName isEqualToString:@"item"]) {
            
            // STEP 2: Prepare the Core Data Importer
            CoreDataImporter *importer =
            [[CoreDataImporter alloc] initWithUniqueAttributes:
             [self selectedUniqueAttributes]];
            
            // STEP 3a: Insert a unique 'Item' object
            NSManagedObject *item =
            [importer insertBasicObjectInTargetEntity:@"Item"
                                targetEntityAttribute:@"name"
                                   sourceXMLAttribute:@"name"
                                        attributeDict:attributeDict
                                              context:_importContext];
            
            // STEP 3b: Insert a unique 'Unit' object
            NSManagedObject *unit =
            [importer insertBasicObjectInTargetEntity:@"Unit"
                                targetEntityAttribute:@"name"
                                   sourceXMLAttribute:@"unit"
                                        attributeDict:attributeDict
                                              context:_importContext];
            
            // STEP 3c: Insert a unique 'LocationAtHome' object
            NSManagedObject *locationAtHome =
            [importer insertBasicObjectInTargetEntity:@"LocationAtHome"
                                targetEntityAttribute:@"storedIn"
                                   sourceXMLAttribute:@"locationathome"
                                        attributeDict:attributeDict
                                              context:_importContext];
            
            // STEP 3d: Insert a unique 'LocationAtShop' object
            NSManagedObject *locationAtShop =
            [importer insertBasicObjectInTargetEntity:@"LocationAtShop"
                                targetEntityAttribute:@"aisle"
                                   sourceXMLAttribute:@"locationatshop"
                                        attributeDict:attributeDict
                                              context:_importContext];
            
            // STEP 4: Manually add extra attribute values.
            [item setValue:@NO forKey:@"listed"];
            
            // STEP 5: Create relationships
            [item setValue:unit forKey:@"unit"];
            [item setValue:locationAtHome forKey:@"locationAtHome"];
            [item setValue:locationAtShop forKey:@"locationAtShop"];
            
            // STEP 6: Save new objects to the persistent store.
            [CoreDataImporter saveContext:_importContext];
            
            // STEP 7: Turn objects into faults to save memory
            [Faulter faultObjectWithID:item.objectID inContext:_importContext];
            [Faulter faultObjectWithID:unit.objectID inContext:_importContext];
            [Faulter faultObjectWithID:locationAtHome.objectID inContext:_importContext];
            [Faulter faultObjectWithID:locationAtShop.objectID inContext:_importContext];
        }
    }];
}

#pragma mark – UNDERLYING DATA CHANGE NOTIFICATION

- (void)somethingChanged
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // Send a notification that tells observing interfaces to refresh their data
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"SomethingChanged" object:nil];
}

@end
