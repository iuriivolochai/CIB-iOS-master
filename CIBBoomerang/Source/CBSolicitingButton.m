//
//  CBSolicitingButton.m
//  CIBBoomerang
//
//  Created by Roma on 5/29/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBSolicitingButton.h"

@interface CBSolicitingButton ()
/*content view*/
@property (strong, nonatomic) IBOutlet UIView *contentView;
/* image views */
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet UIImageView *separatorImageView;
@property (weak, nonatomic) IBOutlet UIImageView *starImageView;
/* labels */
@property (weak, nonatomic) IBOutlet UILabel *requiredLabel;
/* bool */
@property (assign, nonatomic) BOOL checked;
@end

@implementation CBSolicitingButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configureView];
    }
    return self;
}

#pragma mark - View Configuration

- (void)configureView
{
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                  owner:self
                                options:nil];
    self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.contentView.bounds), CGRectGetHeight(self.contentView.bounds));
    [self addSubview:self.contentView];
    self.contentView.userInteractionEnabled = NO;
    
    self.checked = NO;
    
    self.buttonTitleLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:19.f];
    self.requiredLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:11.f];
}

- (BOOL)isChecked
{
    return _checked;
}

- (void)setChecked:(BOOL)checked
{
    _checked = checked;
    self.arrowImageView.image = (checked) ? [UIImage imageNamed:@"icon-solicit-checkmark"] : [UIImage imageNamed:@"icon-soliciting-arrow-left"];
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    self.overlayView.hidden = enabled;
}

- (void)rotateAccessoryDown:(BOOL)down {
    [UIView animateWithDuration:0.4
                     animations:^{
                         self.arrowImageView.transform = CGAffineTransformMakeRotation(down ? M_PI / 2 : 0);
                     }];
}

@end
