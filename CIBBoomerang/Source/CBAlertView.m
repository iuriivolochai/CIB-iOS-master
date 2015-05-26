//
//  CBAlertView.m
//  CIBBoomerang
//
//  Created by Roman Kopaliani on 5/29/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBAlertView.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import "UIAlertView+BlockCallback.h"

typedef NS_ENUM(int16_t, CBAlertViewButtonType) {
    CBAlertViewButtonTypeCancel = 0,
    CBAlertViewButtonTypeNormal
};

#define KEY_COMPLETION_HANDLER @"KEY_COMPLETION_HANDLER"
#define KEY_BUTTON_INDEX @"KEY_BUTTON_INDEX"

#define kAnimateInDuration 0.4
#define kAnimateOutDuration 0.3
#define kButtonsHeight 42.f
#define kButtonsHorizontallMargin 20.f
#define kButtonsVerticallMargin 4.f
#define kButtonsWidth 110.f
#define kOverlayMaxAlpha 0.2
#define kTopMargin 15.f
#define kStatusBarHeight 20.f

#define IS_LANDSCAPE UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)

CGRect  const defaultFrame = {{0.f, 0.f}, {260.f,20.f}};
CGFloat const maxAlertHeight = 360.f;

@interface CBAlertView () <UITextViewDelegate>

@property (copy, nonatomic) CBAlertViewCompletionHandler completion;
/* window */
@property (strong, nonatomic) UIWindow *windowToShowIn;
@property (strong, nonatomic) UIView *windowOverlay;
/* text */
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *cancelButtonTitle;
@property (strong, nonatomic) NSString *acceptButtonTitle;
@property (strong, nonatomic) NSArray *otherButtonTitles;
/* origin */
@property (assign, nonatomic) CGFloat yOrigin;
@property (assign, nonatomic) CGFloat xOrigin;
@property (assign, nonatomic) CGFloat width;

@property (strong, nonatomic) UIScrollView *messageScrollView;
@property (strong, nonatomic) UILabel *messageLabel;

@end

@implementation CBAlertView

#pragma mark - Public

+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message
			 cancelButtonTitle:(NSString *)cancelTitle
			 otherButtonTitles:(NSArray *)otherButtonTitles
					completion:(CBAlertViewCompletionHandler)completion;
{
    if ([[UIDevice currentDevice] systemVersionGreaterOrEqual:7.0f]) {
        CBAlertViewCompletionHandler copiedCompletion = [completion copy];
        
        [CBSoundUtils playSound:CBSystemSoundTypeAlertShow];
        
        [UIAlertView showAlertWithTitle:title message:message cancelButtonTitle:cancelTitle otherButtonTitles:otherButtonTitles completion:^(UIAlertView *sender, NSInteger buttonIndex) {
            [CBSoundUtils playSound:CBSystemSoundTypeAlertPress];
            
            if (copiedCompletion) {
                copiedCompletion(nil, buttonIndex);
            }
        }];
    } else {
        CBAlertView *alertView = [[CBAlertView alloc] initWithTitle:title
                                                            message:message
                                                  cancelButtonTitle:cancelTitle
                                                   otherButtonTitle:otherButtonTitles];
        objc_setAssociatedObject(alertView, KEY_COMPLETION_HANDLER, completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
        [alertView showAlertAnimated:YES];
    }
}

+ (NSUInteger)cancelButtonIndex
{
    return 0;
}

#pragma mark - Private

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelTitle
							otherButtonTitle:(NSArray *)otherButtonTitles
{
	self = [super initWithFrame:defaultFrame];
	if (self) {
        self.title = title;
        self.message = message;
        self.cancelButtonTitle = cancelTitle;
        self.otherButtonTitles = otherButtonTitles;
        self.autoresizesSubviews = YES;
        [self congifureView];
		self.exclusiveTouch = YES;
	}
	return self;
}

#pragma mark - View Configuration

- (void)congifureView
{
    [self calculateWidth];
    [self configureSuperView];
    [self configureSubviews];
    [self layoutLabels];
    [self layoutButtons];
    
    CGRect frame = self.frame;
    frame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), self.yOrigin);
    self.frame = frame;
    [self setCenter:[self centerWithOrientation]];
}


- (void)calculateWidth
{
    if (self.otherButtonTitles.count > 1) {
        self.width = (self.otherButtonTitles.count + 1)*kButtonsWidth +(self.otherButtonTitles.count + 2)*kButtonsHorizontallMargin;
    }
    else {
        self.width = kButtonsWidth *2 + kButtonsHorizontallMargin *3;
    }
    CGRect frame = self.frame;
    frame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), self.width, CGRectGetHeight(frame));
    self.frame = frame;
}

- (void)configureSuperView
{
    if (!self.windowToShowIn) {
        self.windowToShowIn = [[[UIApplication sharedApplication] delegate] window];
        self.windowOverlay  = [[UIView alloc] initWithFrame:self.windowToShowIn.bounds];
        self.windowOverlay.backgroundColor = [UIColor blackColor];
        self.windowOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
}

- (void)configureSubviews
{
    self.backgroundColor = [UIColor clearColor];
    UIImage *stretchImage = [[UIImage imageNamed:@"bg-alert"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.f, 10.f, 10.f, 10.f)];
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:self.bounds];
    [bgView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
    [bgView setImage:stretchImage];
    [bgView setBackgroundColor:[UIColor clearColor]];
    [bgView setImage:stretchImage];
    [self addSubview:bgView];
    
    // message
    self.messageScrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    self.messageScrollView.showsHorizontalScrollIndicator = NO;
    self.messageScrollView.showsVerticalScrollIndicator = YES;
    self.messageScrollView.alwaysBounceHorizontal = NO;
    self.messageScrollView.alwaysBounceVertical = NO;
    self.messageScrollView.bounces = NO;
    self.messageScrollView.backgroundColor = [UIColor clearColor];
    self.messageScrollView.clipsToBounds = YES;
    [self addSubview:self.messageScrollView];
    
    self.messageLabel = [[UILabel alloc] initWithFrame:self.messageScrollView.bounds];
    self.messageLabel.backgroundColor = [UIColor clearColor];
    self.messageLabel.font = [CBFontUtils droidSansFontBold:NO ofSize:14.f];
    self.messageLabel.textColor = [UIColor whiteColor];
    self.messageLabel.numberOfLines = 0;
//    self.messageLabel.textAlignment = [[UIDevice currentDevice] systemVersionGreaterOrEqual:6.0] ?  NSTextAlignmentJustified : NSTextAlignmentCenter;
    self.messageLabel.textAlignment = NSTextAlignmentLeft;
    self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.messageScrollView addSubview:self.messageLabel];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return NO;
}

- (void)layoutLabels
{
    self.yOrigin = kTopMargin;
    CGRect frame = self.frame;
    
    if (self.title) {
        CGSize expectedTitleLabelSize = [self.title sizeWithFont:[CBFontUtils droidSansFontBold:YES ofSize:18.f]
                                      constrainedToSize:CGSizeMake(self.width - kButtonsHorizontallMargin * 2, CGFLOAT_MAX)
                                          lineBreakMode:NSLineBreakByWordWrapping];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kButtonsHorizontallMargin, self.yOrigin, self.width - 2*kButtonsHorizontallMargin, expectedTitleLabelSize.height)];
        [label setNumberOfLines:0];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[CBFontUtils droidSansFontBold:YES ofSize:18.f]];
        if ([label respondsToSelector:@selector(setMinimumScaleFactor:)]) {
            [label setMinimumFontSize:0.6];
        }
        else {
            [label setMinimumFontSize:14.f];
        }
        [label setTextColor:[UIColor whiteColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setLineBreakMode:NSLineBreakByWordWrapping];
        [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleRightMargin];
        [label setText:self.title];
        [self addSubview:label];
        
        _yOrigin = self.yOrigin + label.frame.size.height + kTopMargin;
    }
    
    if (self.message) {
//        CGSize expectedTitleLabelSize = [self.message sizeWithFont:[CBFontUtils droidSansFontBold:NO ofSize:14.f]
//                                               constrainedToSize:CGSizeMake(self.width - kButtonsHorizontallMargin * 2, CGFLOAT_MAX)
//                                                   lineBreakMode:NSLineBreakByWordWrapping];
        
        CGFloat messageWidth = self.width - kButtonsHorizontallMargin * 2;
        
        self.messageLabel.frame = CGRectMake(0, 0, messageWidth, 0);
        self.messageLabel.text = _message;
        [self.messageLabel sizeToFit];
        
        self.messageScrollView.frame = CGRectMake(kButtonsHorizontallMargin, self.yOrigin, messageWidth, self.messageLabel.frame.size.height);
        self.messageScrollView.contentSize = self.messageLabel.frame.size;
        
        _yOrigin = self.yOrigin + self.messageLabel.frame.size.height + kTopMargin;
    }
    
    if (_yOrigin < maxAlertHeight) {
        frame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), self.width, _yOrigin);
        
        self.messageScrollView.frame = CGRectMake(CGRectGetMinX(self.messageScrollView.frame),
                                                  CGRectGetMinY(self.messageScrollView.frame),
                                                  CGRectGetWidth(self.messageScrollView.frame),
                                                  self.messageScrollView.contentSize.height + kTopMargin);
        
        self.messageScrollView.scrollEnabled = NO;
        _yOrigin = CGRectGetMaxY(self.messageScrollView.frame);

    }
    else {
        frame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), self.width, maxAlertHeight);
 
        self.messageScrollView.frame = CGRectMake(CGRectGetMinX(self.messageScrollView.frame),
                                                  CGRectGetMinY(self.messageScrollView.frame),
                                                  CGRectGetWidth(self.messageScrollView.frame),
                                                  CGRectGetHeight(frame) - CGRectGetMinY(self.messageScrollView.frame));
        _yOrigin = maxAlertHeight + kTopMargin;
    }
    self.frame = frame;
}

- (void)layoutButtons
{
    if (self.otherButtonTitles.count > 1) {
        [self layoutButtonsVertically];
    }
    else {
        [self layoutButtonsHorizontally];
    }
}

#pragma mark - buttons layout

- (void)layoutButtonsVertically
{
    __block CGPoint point = CGPointMake(kButtonsHorizontallMargin, _yOrigin);
    /* cancel button */
    UIButton *button = [self buttonWithType:CBAlertViewButtonTypeCancel forVerticalAlignment:YES title:self.cancelButtonTitle origin:point index:0];
    [self addSubview:button];
    point = CGPointMake(kButtonsHorizontallMargin, point.y + CGRectGetHeight(button.bounds) + kButtonsVerticallMargin);
    self.yOrigin = point.y;
    self.xOrigin = CGRectGetMaxX(button.frame) + kButtonsHorizontallMargin;
    /* other buttons*/
    [self.otherButtonTitles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
        UIButton *button = [self buttonWithType:CBAlertViewButtonTypeNormal forVerticalAlignment:YES title:title origin:point index:idx + 1];
        [self addSubview:button];
        [button setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin];
        point = CGPointMake(kButtonsHorizontallMargin, point.y + CGRectGetHeight(button.bounds) + kButtonsVerticallMargin);
        self.yOrigin = point.y;
    }];
}

- (void)layoutButtonsHorizontally
{
    __block CGPoint point = CGPointMake(kButtonsHorizontallMargin, _yOrigin);
    /* cancel button */
    UIButton *button = [self buttonWithType:CBAlertViewButtonTypeCancel forVerticalAlignment:NO title:self.cancelButtonTitle origin:point index:0];
    [self addSubview:button];
    point = CGPointMake(point.x + CGRectGetWidth(button.bounds) + kButtonsHorizontallMargin, self.yOrigin);
    self.xOrigin = point.x;
    /* other buttons*/
    if (self.otherButtonTitles.count != 0) {
        [self.otherButtonTitles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
            UIButton *button = [self buttonWithType:CBAlertViewButtonTypeNormal forVerticalAlignment:NO title:title origin:point index:idx + 1];
            [self addSubview:button];
            [button setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin];
            point = CGPointMake(point.x + CGRectGetWidth(button.bounds) + kButtonsHorizontallMargin, self.yOrigin);
            self.xOrigin = point.x;
        }];
    }
    else {
        CGRect frame = button.frame;
        frame = CGRectMake(kButtonsHorizontallMargin, CGRectGetMinY(frame), CGRectGetWidth(self.bounds) - 2*kButtonsHorizontallMargin, CGRectGetHeight(frame));
        button.frame = frame;
    }
    self.yOrigin = self.yOrigin + CGRectGetHeight(button.bounds) + kTopMargin;
}

- (UIButton *)buttonWithType:(CBAlertViewButtonType)buttonType forVerticalAlignment:(BOOL)vertical title:(NSString *)title origin:(CGPoint)origin index:(int)index
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect buttonFrame = CGRectNull;
    if (vertical) {
        buttonFrame = CGRectMake(origin.x, origin.y, CGRectGetWidth(self.bounds) - 2 * kButtonsHorizontallMargin, kButtonsHeight);
    }
    else {
        buttonFrame = CGRectMake(origin.x, origin.y, kButtonsWidth, kButtonsHeight);
    }
    button.frame = buttonFrame;

    UIImage *bgImage = nil;
    if (buttonType == CBAlertViewButtonTypeCancel) {
        bgImage = [[UIImage imageNamed:@"btn-solicit-right"] resizableImageWithCapInsets:UIEdgeInsetsMake(5.f, 10.f, 5.f, 10.f)];
    }
    else{
        bgImage = [[UIImage imageNamed:@"btn-solicit-left"] resizableImageWithCapInsets:UIEdgeInsetsMake(5.f, 10.f, 5.f, 10.f)];
    }
    [button setBackgroundImage:bgImage forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.textColor = [UIColor whiteColor];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
    [button setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin];
    objc_setAssociatedObject(button, KEY_BUTTON_INDEX, [NSNumber numberWithInt:index], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [button addTarget:self action:@selector(alertViewButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)alertViewButtonTapped:(UIButton *)sender
{
    [CBSoundUtils playSound:CBSystemSoundTypeAlertPress];
    
    NSNumber *index = objc_getAssociatedObject(sender, KEY_BUTTON_INDEX);
    CBAlertViewCompletionHandler handler = objc_getAssociatedObject(self, KEY_COMPLETION_HANDLER);
    [self dismissAlertAnimated:YES];
    if (handler) {
        handler (self, [index integerValue]);
    }
}

- (CGPoint)centerWithOrientation
{
    if (IS_LANDSCAPE) {
        return CGPointMake(self.windowToShowIn.center.y, self.windowToShowIn.center.x + kStatusBarHeight / 2);
    }
    else {
        return CGPointMake(self.windowToShowIn.center.x, self.windowToShowIn.center.y + kStatusBarHeight / 2);
    }
}

#pragma mark - Animation

- (void)showAlertAnimated:(BOOL)animated
{
    [CBSoundUtils playSound:CBSystemSoundTypeAlertShow];
    
    [self showOverlayAnimated:animated];
    
    [self.windowToShowIn addSubview:self];
    
    if (animated) {
        self.alpha = 0;
        [UIView animateWithDuration:0.1 animations:^{self.alpha = 1.0;}];
        
        self.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
        
        CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        bounceAnimation.values = [NSArray arrayWithObjects:
                                  [NSNumber numberWithFloat:0.5],
                                  [NSNumber numberWithFloat:1.2],
                                  [NSNumber numberWithFloat:0.9],
                                  [NSNumber numberWithFloat:1.0], nil];
        bounceAnimation.duration = kAnimateInDuration;
        bounceAnimation.removedOnCompletion = NO;
        [self.layer addAnimation:bounceAnimation forKey:@"bounce"];
        
        self.layer.transform = CATransform3DIdentity;
    }
}

- (void)dismissAlertAnimated:(BOOL)animated
{
    [CBSoundUtils playSound:CBSystemSoundTypeAlertHide];
    
    [self dismissOverlayAnimated:animated];
    
    [UIView animateWithDuration:kAnimateOutDuration animations:^{self.alpha = 0.0;}];
    
    self.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
    
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    bounceAnimation.values = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:1.0],
                              [NSNumber numberWithFloat:1.1],
                              [NSNumber numberWithFloat:0.5],
                              [NSNumber numberWithFloat:0.0], nil];
    bounceAnimation.duration = kAnimateOutDuration;
    bounceAnimation.removedOnCompletion = NO;
    bounceAnimation.delegate = self;
    [self.layer addAnimation:bounceAnimation forKey:@"bounce"];
    
    self.layer.transform = CATransform3DIdentity;
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    if (flag)
        [self removeFromSuperview];
}

#pragma mark - Animate Overlay

- (void)showOverlayAnimated:(BOOL)animated
{
    [self.windowToShowIn addSubview:self.windowOverlay];
    
    if (animated) {
        self.windowOverlay.alpha = 0;
        [UIView animateWithDuration:0.1 animations:^{
            self.windowOverlay.alpha = kOverlayMaxAlpha;
        }];
    }
    else {
        self.windowOverlay.alpha = kOverlayMaxAlpha;
    }
    
}

- (void)dismissOverlayAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.1 animations:^{
            self.windowOverlay.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.windowOverlay removeFromSuperview];
        }];
    }
    else {
        [self.windowOverlay removeFromSuperview];
    }
}

@end
