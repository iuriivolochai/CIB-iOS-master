//
//  CBItemDetailsView.h
//  CIBBoomerang
//
//  Created by Roma on 5/16/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DMItem;
@interface CBItemDetailsView : UIView

@property (strong, readonly, nonatomic) DMItem *item;

- (id)initWithItem:(DMItem *)item frame:(CGRect)frame;

@end
