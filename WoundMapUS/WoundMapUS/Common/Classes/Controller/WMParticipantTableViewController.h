//
//  WMParticipantTableViewController.h
//  WoundMapUS
//
//  Created by Todd Guion on 5/3/14.
//  Copyright (c) 2014-2016 2016 etreasure software. All rights reserved.
//

#import "WMBaseViewController.h"

@class WMParticipantTableViewController;
@class WMParticipant;

@protocol ParticipantTableViewControllerDelegate <NSObject>

@property (readonly, nonatomic) NSPredicate *participantPredicate;

- (void)participantTableViewControllerDidCancel:(WMParticipantTableViewController *)viewController;
- (void)participantTableViewController:(WMParticipantTableViewController *)viewController didSelectParticipant:(WMParticipant *)participant;

@end

@interface WMParticipantTableViewController : WMBaseViewController

@property (weak, nonatomic) id<ParticipantTableViewControllerDelegate> delegate;

@end
