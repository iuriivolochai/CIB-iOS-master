//
//  CBSplitBar.m
//  CIBBoomerang
//
//  Created by Roma on 8/1/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBSplitBar.h"

@interface CBSplitBar ()

@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *splitTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *splitAcceptButton;
@property (weak, nonatomic) IBOutlet UIButton *splitCancelButton;

- (IBAction)acceptSplitButtomTapped:(UIButton *)button;
- (IBAction)cancelSplitButtomTapped:(UIButton *)button;

@end

@implementation CBSplitBar

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

#pragma mark - View configuration

- (void)configureView
{
    [self loadFromNib];
    [self configureLabels];
}

- (void)configureLabels
{
    self.splitAcceptButton.titleLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:15.f];
    self.splitCancelButton.titleLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:15.f];
    self.splitTextLabel.font = [CBFontUtils droidSansFontBold:NO ofSize:11.f];
}


- (void)loadFromNib
{
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                  owner:self
                                options:nil];
    [self addSubview:self.contentView];
}

#pragma mark - IBActions

- (IBAction)acceptSplitButtomTapped:(UIButton *)button
{
    [self.delegate acceptButtonTappedInSplitBarView:self];
}

- (IBAction)cancelSplitButtomTapped:(UIButton *)button
{
    [self.delegate cancelButtonTappedInSplitBarView:self];
}

@end
