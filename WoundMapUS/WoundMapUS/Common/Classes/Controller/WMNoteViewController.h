//
//  WMNoteViewController.h
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 2/22/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//

@class WMNoteViewController;

@protocol NoteViewControllerDelegate <NSObject>

@property (readonly, nonatomic) NSString *note;
@property (readonly, nonatomic) NSString *label;

- (void)noteViewController:(WMNoteViewController *)viewController didUpdateNote:(NSString *)note;
- (void)noteViewControllerDidCancel:(WMNoteViewController *)viewController withNote:(NSString *)note;

@end

@interface WMNoteViewController : UIViewController

@property (weak, nonatomic) id<NoteViewControllerDelegate> delegate;

@end
