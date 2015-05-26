//
//  CBCarnetStatisticView.h
//  CIBBoomerang
//
//  Created by Roma on 6/25/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DMCarnet;

@interface CBCarnetStatisticView : UIView

@property (strong, nonatomic) DMCarnet *carnet;

- (void)refreshView;

@end
