//
//  CBSolicitingButton.h
//  CIBBoomerang
//
//  Created by Roma on 5/29/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CBSolicitingButton;

@protocol CBSolicitingButtonDelegate <NSObject>

- (void)solicitingButton:(CBSolicitingButton *)button setSelected:(BOOL)selected;

@end

@interface CBSolicitingButton : UIButton

@property (weak, nonatomic) id <CBSolicitingButtonDelegate> delegate;

/* temporary */
@property (assign, nonatomic) BOOL btnSelected;
@property (weak, nonatomic) IBOutlet UILabel *buttonTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *accessoryView;
@property (weak, nonatomic) IBOutlet UIView *inputView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;

- (BOOL)isChecked;
- (void)rotateAccessoryDown:(BOOL)down;
- (void)setChecked:(BOOL)checked;

@end
