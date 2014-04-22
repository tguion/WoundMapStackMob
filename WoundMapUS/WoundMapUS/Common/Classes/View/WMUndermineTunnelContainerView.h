//
//  WMUndermineTunnelContainerView.h
//  WoundCarePhoto
//
//  Created by etreasure consulting LLC on 3/24/13.
//  Copyright (c) 2013 etreasure consulting inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    UndermineTunnelContainerViewState_Undermine,
    UndermineTunnelContainerViewState_Tunnel,
} UndermineTunnelContainerViewState;

@interface WMUndermineTunnelContainerView : UIView

@property (nonatomic) UndermineTunnelContainerViewState state;

@end
