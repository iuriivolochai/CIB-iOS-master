//
//  CBCarnetCell.m
//  CIBBoomerang
//
//  Created by Roma on 5/10/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBCarnetCell.h"
#import "CBDateConvertionUtils.h"
#import "CBCarnetImageStatusUtils.h"
#import "CBCarnetView.h"

@interface CBCarnetCell ()

@property (weak, nonatomic) IBOutlet UILabel *backgroundLabel;

@property (weak, nonatomic) IBOutlet UIView *coloredBackgroundView;
@property (weak, nonatomic) IBOutlet CBCarnetView *coloredContentView;

@end

@implementation CBCarnetCell
@synthesize carnet = _carnet;

#pragma mark - Setters & Getters

- (void)setCarnet:(DMCarnet *)carnet
{
    _carnet = carnet;
    [self configureView];
}

- (DMCarnet *)carnet
{
    return _carnet;
}

- (UIView *)coloredBackgroundView
{
    return _coloredBackgroundView;
}

- (UIView *)coloredContentView
{
    return _coloredContentView;
}

#pragma mark - View Configuration

- (void)configureView
{
    _coloredContentView.carnet = self.carnet;
    [_coloredContentView refreshView];
    
    self.backgroundLabel.text = self.carnet.identifier;
    self.backgroundLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:26.f];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    CGRect frame = CGRectMake(0.f, 0.f, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    self.coloredBackgroundView.frame = frame;
    self.coloredContentView.frame = frame;
    self.coloredContentView.backgroundColor = [UIColor whiteColor];
}

@end
