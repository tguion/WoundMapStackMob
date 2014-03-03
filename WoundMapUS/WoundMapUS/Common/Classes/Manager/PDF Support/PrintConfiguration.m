//
//  PrintConfiguration.m
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 2/25/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//

#import "PrintConfiguration.h"
#import "WMWound.h"
#import "WMWoundPhoto.h"

@implementation PrintConfiguration

@synthesize printTemplate, selectedWoundPhotosMap=_selectedWoundPhotosMap, managedObjectContext=_managedObjectContext;
@synthesize sortedWounds=_sortedWounds, password=_password;
@synthesize printRiskAssessment, printSkinAssessment, printCarePlan;

- (NSArray *)sortedWounds
{
    if (nil == _sortedWounds) {
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[self.selectedWoundPhotosMap count]];
        for (NSManagedObjectID *objectID in self.selectedWoundPhotosMap) {
            [array addObject:[self.managedObjectContext objectWithID:objectID]];
        }
        _sortedWounds = [array sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]]];
    }
    return _sortedWounds;
}

- (NSArray *)sortedWoundPhotosForWound:(WMWound *)wound
{
    NSArray *woundPhotos = [[self.selectedWoundPhotosMap objectForKey:[wound objectID]] allObjects];
    return [woundPhotos sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:YES]]];
}

@end
