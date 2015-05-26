//
//  CBCountryPickerView.m
//  CIBBoomerang
//
//  Created by Roma on 7/25/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBCountryPickerView.h"
#import "DMCountry+Auxilliary.h"
#import "CBFontUtils.h"

@interface CBCountryPickerView ()

@property (strong, nonatomic) IBOutlet UIView   *contentView;
@property (strong, nonatomic) IBOutlet UILabel  *countryNameLabel;

@end

@implementation CBCountryPickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                                      owner:self
                                                    options:nil] lastObject];
        [self addSubview:view];
    }
    return self;
}

- (void)setCountry:(DMCountry *)aCountry
{
    if (_country != aCountry) {
        _country = aCountry;
        self.countryNameLabel.text = _country.name;
        self.countryNameLabel.font = [CBFontUtils droidSansFontBold:(_country.supportsCarnet || [_country isUSA]) ofSize:14.f];
    }
}

@end
