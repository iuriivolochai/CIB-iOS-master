//
//  CBRouteAlertPageView.h
//  CIBBoomerang
//
//  Created by Roman Kopaliani on 6/12/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBAlertObjectProtocol.h"
#import "DARecycledTileView.h"

@class CBAlertPageView;

@protocol CBAlertPageViewDelegate <NSObject>

- (void)alertPageView:(CBAlertPageView *)aPageView didDetectButtonTapped:(CBAlertButtonType)aButtonType forAlertWithType:(NSUInteger)anAlertType;

@end

@interface CBAlertPageView : DARecycledTileView

@property (strong, nonatomic)   id <CBAlertObjectProtocol>  alert;
@property (weak, nonatomic)     id <CBAlertPageViewDelegate> delegate;

@property (assign, nonatomic)   NSUInteger alertIndex;

@end
