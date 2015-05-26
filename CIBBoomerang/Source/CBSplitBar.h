//
//  CBSplitBar.h
//  CIBBoomerang
//
//  Created by Roma on 8/1/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CBSplitBar;

@protocol CBSplitBarDelegate <NSObject>

- (void)acceptButtonTappedInSplitBarView:(CBSplitBar *)splitBar;
- (void)cancelButtonTappedInSplitBarView:(CBSplitBar *)splitBar;

@end

@interface CBSplitBar : UIView

@property (weak, nonatomic) id <CBSplitBarDelegate> delegate;

@end
