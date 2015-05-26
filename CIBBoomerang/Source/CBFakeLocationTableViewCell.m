//
//  CBFakeLocationTableViewCell.m
//  CIBBoomerang
//
//  Created by Artem Stepanenko on 10/15/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBFakeLocationTableViewCell.h"

@interface CBFakeLocationTableViewCell ()

@property (nonatomic, strong) IBOutlet UILabel *label;
@property (nonatomic, strong) IBOutlet UIImageView *checkImageView;

@end

@implementation CBFakeLocationTableViewCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.label.font = [CBFontUtils droidSansFontBold:NO ofSize:13.f];
    }
    
    return self;
}

- (NSString *)title
{
    return self.label.text;
}

- (void)setTitle:(NSString *)title
{
    self.label.text = title;
}

- (void)showCheck
{
    self.checkImageView.hidden = NO;
}

- (void)hideCheck
{
    self.checkImageView.hidden = YES;
}

@end
