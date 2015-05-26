//
//  CBCarnetStatisticView.m
//  CIBBoomerang
//
//  Created by Roma on 6/25/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBCarnetStatisticView.h"
#import "CBRoundUpUtils.h"

#import "DMCarnet+Auxilliary.h"

@interface CBCarnetStatisticView ()

@property (strong, nonatomic) IBOutlet UIView *contentView;

/* statistic */
@property (weak, nonatomic) IBOutlet UILabel *quantityTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;

@property (weak, nonatomic) IBOutlet UILabel *valueTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

@property (weak, nonatomic) IBOutlet UILabel *refNumberTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *refNumberLabel;

@end

@implementation CBCarnetStatisticView

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
        [[NSBundle mainBundle] loadNibNamed:@"CBCarnetStatisticViewi8"
                                      owner:self
                                    options:nil];

    }
    
    [self addSubview:self.contentView];
}


- (void)configureLabels
{
    self.quantityTextLabel.text = [NSLocalizedString(@"Quantity:", nil) uppercaseString];
    self.quantityLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:14];
    self.quantityTextLabel.font = [CBFontUtils droidSansFontBold:NO ofSize:10];
    
    self.valueTextLabel.text = [NSLocalizedString(@"Value:", nil) uppercaseString];
    self.valueLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:14];
    self.valueTextLabel.font = [CBFontUtils droidSansFontBold:NO ofSize:10];
    
    self.refNumberTextLabel.text = [NSLocalizedString(@"Reference No:", nil) uppercaseString];
    self.refNumberLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:14];
    self.refNumberTextLabel.font = [CBFontUtils droidSansFontBold:NO ofSize:10];
}

- (void)setCarnet:(DMCarnet *)carnet
{
    if (carnet != _carnet) {
        _carnet = carnet;
        [self refreshView];
    }
}

- (void)refreshView
{
    self.quantityLabel.text = [NSString stringWithFormat:@"%d %@", [self.carnet itemsCount], NSLocalizedString(@"items", nil)];
    [self.quantityLabel sizeToFit];
    
    self.valueLabel.text = [NSString stringWithFormat:@"$%@", [CBRoundUpUtils dottedNumberFromNumber:[self.carnet totalItemsValue]]];
    [self.valueLabel sizeToFit];
    
    NSString *text = ([self.carnet.accountNumber length]) ? self.carnet.accountNumber : @"No Info";
    self.refNumberLabel.text = text;
}

@end
