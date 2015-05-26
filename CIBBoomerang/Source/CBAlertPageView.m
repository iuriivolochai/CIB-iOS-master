//
//  CBRouteAlertPageView.m
//  CIBBoomerang
//
//  Created by Roman Kopaliani on 6/12/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBAlertPageView.h"

#import "CBAlertsSettingsUtil.h"
#import "CBAlertPageButton.h"
#import "CBFontUtils.h"

#define ALERT_BUTTONS_MARGIN    5.f

@interface CBAlertPageView ()

@property (weak, nonatomic) IBOutlet UILabel *alertTextLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (strong, nonatomic) NSMutableArray *buttonsArray;
@end


@implementation CBAlertPageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                                      owner:self
                                                    options:nil] lastObject];
        [self addSubview:view];
        self.alertTextLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:15];
        _buttonsArray = [NSMutableArray arrayWithCapacity:2];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        UIView *view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                                      owner:self
                                                    options:nil] lastObject];
        [self addSubview:view];
        self.bounds = view.frame;
        self.alertTextLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:15];
        _buttonsArray = [NSMutableArray arrayWithCapacity:2];
    }
    return self;
}


#pragma mark - Public

- (void)setAlert:(id <CBAlertObjectProtocol>)alert
{
    if (_alert != alert && alert != nil) {
        _alert = alert;
        self.alertTextLabel.text        = [alert alertText];
		NSString *imageName             = ([alert alertPriority] == 1) ? @"bg-red-route-view" : @"bg-yellow-route-view";
        self.backgroundImageView.image  = [UIImage imageNamed:imageName];
        [self clearButtons];
        [self layoutButtons:[alert alertButtons]];
    }
}

#pragma mark - Private

- (void)clearButtons
{
    for (UIButton *btn in _buttonsArray) {
        [btn removeFromSuperview];
    }
    [_buttonsArray removeAllObjects];
}
- (void)layoutButtons:(NSArray *)buttons
{
    CGSize buttonsSize = [self buttonSizeForButtonsCount:buttons.count];
    CGFloat xMarge = (CGRectGetWidth(self.bounds) - buttonsSize.width * buttons.count)/(buttons.count);
    CGFloat xOrigin = xMarge / 2;
    
    for (NSNumber *action in buttons) {
        CGRect buttonFrame = CGRectMake(xOrigin, CGRectGetMaxY(self.alertTextLabel.frame) + ALERT_BUTTONS_MARGIN, buttonsSize.width, buttonsSize.height);
        CBAlertPageButton *button = [[CBAlertPageButton alloc] initWithFrame:buttonFrame];
        
        NSDictionary *dic = [CBAlertsSettingsUtil alertButtonsSettings:[action integerValue]
                                                         alertPriority:[self.alert alertPriority]];
        
        UIImage *img = [[UIImage imageNamed:dic[keyButtonImageName]] resizableImageWithCapInsets:UIEdgeInsetsMake(ALERT_BUTTONS_MARGIN, 2*ALERT_BUTTONS_MARGIN, ALERT_BUTTONS_MARGIN, 2*ALERT_BUTTONS_MARGIN)];
        [button setBackgroundImage:img forState:UIControlStateNormal];
        
        [button setTitle:dic[keyButtonText] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button.titleLabel setFont:[CBFontUtils droidSansFontBold:YES ofSize:18.f]];
        [button.titleLabel setMinimumFontSize:10.f];
        
        button.type = [action integerValue];
        [button addTarget:self
                   action:@selector(buttonTapped:)
         forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:button];
        [_buttonsArray addObject:button];
        
        xOrigin = xOrigin + buttonsSize.width + xMarge;
    }
}

- (CGSize)buttonSizeForButtonsCount:(NSInteger)aCount
{
    CGSize retSize = CGSizeZero;
    if (aCount == 2)
        retSize = CGSizeMake(130.f, 40.f);
    else
        retSize = CGSizeMake(152.f, 40.f);
    return retSize;
}

- (void)buttonTapped:(CBAlertPageButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(alertPageView:didDetectButtonTapped:forAlertWithType:)])
        [self.delegate alertPageView:self
               didDetectButtonTapped:sender.type
                    forAlertWithType:[self.alert alertType]];
}

@end