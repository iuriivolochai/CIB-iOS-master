//
//  CBCarnetDetailsViewController.h
//  CIBBoomerang
//
//  Created by Roma on 5/10/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBBaseViewController.h"

FOUNDATION_EXPORT NSString *const CarnetDetailsViewControllerStoryboardId;

@interface CBCarnetDetailsViewController : CBBaseViewController

/* carnet details to show */
@property (strong, nonatomic) DMCarnet *carnet;

@end
