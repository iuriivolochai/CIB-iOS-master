//
//  CBCarnetCell.h
//  CIBBoomerang
//
//  Created by Roma on 5/10/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMCarnet+Auxilliary.h"

@interface CBCarnetCell : UITableViewCell

@property (strong, nonatomic) DMCarnet *carnet;

- (UIView *)coloredBackgroundView;
- (UIView *)coloredContentView;

@end
