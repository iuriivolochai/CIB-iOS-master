//
//  CBCarnetView.m
//  CIBBoomerang
//
//  Created by Roma on 6/25/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBCarnetView.h"
#import "CBDateConvertionUtils.h"
#import "CBCarnetImageStatusUtils.h"

#import "DMCarnet+Auxilliary.h"

@interface CBCarnetView ()

@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UILabel *expiresLabel;
@property (weak, nonatomic) IBOutlet UILabel *expiringDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *expiringDateYearLabel;
@property (weak, nonatomic) IBOutlet UILabel *carnetTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *carnetNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *carnetStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusImageOverlayLabel;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageOverlayView;

@end

@implementation CBCarnetView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configureView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureView];
    }
    return self;
}

- (void)configureView
{
    [self loadFromNib];
    [self configureLabels];
}

- (void)loadFromNib
{
    if(![[UIDevice currentDevice] systemVersionGreaterOrEqual: 8.0])
    {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                  owner:self
                                options:nil];
    }
    else
    {
        [[NSBundle mainBundle] loadNibNamed: @"CBCarnetViewi8"
                                      owner:self
                                    options:nil];
    }
    
    [self addSubview:self.contentView];
}

- (void)configureLabels
{
    self.carnetTextLabel.text = [NSLocalizedString(@"Carnet Number", nil) uppercaseString];
    self.carnetTextLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:10.f];
    
    self.expiresLabel.text = [NSLocalizedString(@"Expires:", nil) uppercaseString];
    self.expiresLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:10.f];
    
    self.expiringDateLabel.font         = [CBFontUtils droidSansFontBold:YES ofSize:13.f];
    self.expiringDateYearLabel.font     = [CBFontUtils droidSansFontBold:NO ofSize:11.f];
    
    self.carnetNumberLabel.font         = [CBFontUtils droidSansFontBold:NO ofSize:26.f];
    self.statusImageOverlayLabel.font   = [CBFontUtils droidSansFontBold:YES ofSize:14.f];
}

#pragma mark - Public

- (void)refreshView
{
    NSDictionary *dic = [CBCarnetImageStatusUtils statusDictionatyForCarnet:self.carnet];
	
	self.statusImageOverlayView.hidden = self.statusImageOverlayLabel.hidden = YES;
    
    __block UIImage *statusImage;
	[dic enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
		if ([key isEqualToString:keyCBCarnetStatusBackgroundImage]) {
			statusImage = [UIImage imageNamed:obj];
		}
        else
		if ([key isEqualToString:keyCBCarnetStatusTextLabel]) {
			self.carnetStatusLabel.text = [obj uppercaseString];
		}
        else
		if ([key isEqualToString:keyCBCarnetStatusTextColor]) {
			self.carnetStatusLabel.textColor = obj;
            self.carnetStatusLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:12.f];
		}
        else
		if ([key isEqualToString:keyCBCarnetStatusImage]) {
			self.statusImageOverlayView.image = [UIImage imageNamed:obj];
		}
        else
		if ([key isEqualToString:keyCBCarnetStatusText]) {
			self.statusImageOverlayLabel.text = obj;
            self.statusImageOverlayView.hidden = self.statusImageOverlayLabel.hidden = NO;

		}
	}];
    
    // update header
    self.carnetNumberLabel.text     = self.carnet.identifier;
    self.expiringDateLabel.text     = [[CBDateConvertionUtils expiringDayAndMonthFromTimeInterval:self.carnet.dateExpired] uppercaseString];
    self.expiringDateYearLabel.text = [[CBDateConvertionUtils expiringYearTimeInterval:self.carnet.dateExpired] uppercaseString];
    self.statusImageView.image      = statusImage;
    
    CGRect statusFrame = self.statusImageView.frame;
    statusFrame = CGRectMake(CGRectGetMinX(statusFrame) + (CGRectGetWidth(statusFrame) - statusImage.size.width) / 2,
                             CGRectGetMinY(statusFrame) + (CGRectGetHeight(statusFrame) - statusImage.size.height) / 2,
                             statusImage.size.width,
                             statusImage.size.height);
    self.statusImageView.frame = statusFrame;
    
    if ([self.carnet isCarnetExpirationSituationOccured]) {
        [self.expiringDateLabel setTextColor: [UIColor colorWithRed:235.f/255.f  green:33.f/255.f blue:35.f/255.f alpha:1.f]];
    }
    else
        if ([self.carnet isCarnetExpirationSitutationWillOccure])
            [self.expiringDateLabel setTextColor:[UIColor colorWithRed:212.f/255.f  green:162./255.f blue:36./255.f alpha:1.f]];
        else
            [self.expiringDateLabel setTextColor:[UIColor colorWithRed:105.f/255.f green:105.f/255.f blue:105.f/255.f alpha:1.f]];
}

@end
