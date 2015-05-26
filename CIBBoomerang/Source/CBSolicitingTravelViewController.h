//
//  CBSolicitingTravelViewController.h
//  CIBBoomerang
//
//  Created by Roma on 5/27/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBBaseViewController.h"

@class DMCarnet;

FOUNDATION_EXPORT NSString *const CBSolicitingTravelViewControllerStoryboardId;

@interface CBSolicitingTravelViewController : CBBaseViewController

@property (nonatomic, strong) DMCarnet *carnet;

@end
