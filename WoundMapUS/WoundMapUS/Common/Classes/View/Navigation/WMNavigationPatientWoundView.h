//
//  WMNavigationPatientWoundView.h
//  WoundPUMP
//
//  Created by Todd Guion on 8/17/13.
//  Copyright (c) 2013 etreasure consulting LLC. All rights reserved.
//

@interface WMNavigationPatientWoundView : UIView

@property (nonatomic) BOOL drawTopLine;
@property (nonatomic) BOOL swipeEnabled;
@property (nonatomic) CGFloat deltaY;

@property (weak, nonatomic) IBOutlet UILabel *breadcrumbLabel;

- (void)updateContentForPatient;

@end
