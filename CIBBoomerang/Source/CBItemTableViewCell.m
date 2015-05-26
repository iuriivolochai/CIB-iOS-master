//
//  CBItemTableViewCell.m
//  CIBBoomerang
//
//  Created by Artem Stepanenko on 5/10/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBItemTableViewCell.h"
#import "DMManager.h"
#import "CBRoundUpUtils.h"

NSString * const ItemTableViewCellReuseIdentifier = @"ItemCellIdentifier";

CGFloat const kItemSpecificationWidth = 260.f;
CGFloat const kItemSpecificationMarge = 8.f;

@interface CBItemTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *dottedSeparator;
@property (weak, nonatomic) IBOutlet UIImageView *separator;

@end

@implementation CBItemTableViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.separator.frame = CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1);
}

- (void)configureView
{
    self.indexLabel.text = [NSString stringWithFormat:@"%d", self.index];
    self.indexLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:24.f];
    self.indexLabel.hidden = (self.item.value == 0);
    
    self.specLabel.text = self.item.specification;
    self.specLabel.font = [CBFontUtils droidSansFontBold:NO ofSize:12.f];
    
    self.valueLabel.text = [NSString stringWithFormat:@"$%@",[CBRoundUpUtils roundedUpFormFloat:self.item.value]];
    self.valueLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:12.f];
    
    
    CGSize maximumLabelSize = CGSizeMake(kItemSpecificationWidth, 9999);
    
    CGSize expectedTitleLabelSize = [self.item.specification sizeWithFont:[CBFontUtils droidSansFontBold:NO ofSize:12.f]
                                                        constrainedToSize:maximumLabelSize
                                                            lineBreakMode:NSLineBreakByWordWrapping];
    self.itemDescription.text = self.item.specification;
    
    CGRect descrFrame = self.itemDescription.frame;
    descrFrame = CGRectMake(CGRectGetMinX(descrFrame), CGRectGetMinY(descrFrame), expectedTitleLabelSize.width, expectedTitleLabelSize.height);
    self.itemDescription.frame = descrFrame;
    self.itemDescription.font = [CBFontUtils droidSansFontBold:NO ofSize:12.f];
    
    self.itemOrigin.text = @"US";
    self.itemOrigin.font = [CBFontUtils droidSansFontBold:NO ofSize:12.f];
    
    self.itemQuantity.text = [NSString stringWithFormat:@"%d", self.item.quantity];
    self.itemQuantity.font = [CBFontUtils droidSansFontBold:NO ofSize:12.f];
    
    self.itemValue.text = [NSString stringWithFormat:@"$%@",[CBRoundUpUtils roundedUpFormFloat:self.item.value]];
    self.itemValue.font = [CBFontUtils droidSansFontBold:NO ofSize:12.f];
    
    self.itemWeight.text = [NSString stringWithFormat:@"%.f lb", self.item.weight];
    self.itemWeight.font = [CBFontUtils droidSansFontBold:NO ofSize:12.f];
    
    self.splitLabel.text = (self.item.splitted) ? [NSString stringWithFormat:@"This item was split from the Carnet in %@.", self.item.waypoint.country.name]
                                                : [NSString stringWithFormat:@"This item is with you."];
    self.splitLabel.font = [CBFontUtils droidSansFontBold:NO ofSize:14.f];
    
    self.splitImageView.image = (self.item.splitted) ? [UIImage imageNamed:@"icon-split-warning"] : [UIImage imageNamed:@"icon-split-normal"];
    self.splitImageView.center = CGPointMake(self.splitImageView.center.x, self.splitLabel.center.y);
    
    self.itemDescriptionLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:12.f];

    self.itemOriginLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:12.f];
    CGRect itemOriginLabelFrame = self.itemOriginLabel.frame;
    itemOriginLabelFrame = CGRectMake(CGRectGetMinX(itemOriginLabelFrame), CGRectGetMaxY(descrFrame) + kItemSpecificationMarge,
                                      CGRectGetWidth(itemOriginLabelFrame), CGRectGetHeight(itemOriginLabelFrame));
    self.itemOriginLabel.frame = itemOriginLabelFrame;
    self.itemOrigin.frame = CGRectMake(CGRectGetMinX(itemOriginLabelFrame), CGRectGetMaxY(itemOriginLabelFrame) - kItemSpecificationMarge,
                                         CGRectGetWidth(itemOriginLabelFrame), CGRectGetHeight(itemOriginLabelFrame));

    self.itemQuantityLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:12.f];
    CGRect itemQuantityLabelFrame = self.itemQuantityLabel.frame;
    itemQuantityLabelFrame = CGRectMake(CGRectGetMinX(itemQuantityLabelFrame), CGRectGetMaxY(descrFrame)+ kItemSpecificationMarge,
                                        CGRectGetWidth(itemQuantityLabelFrame), CGRectGetHeight(itemQuantityLabelFrame));
    self.itemQuantityLabel.frame = itemQuantityLabelFrame;
    self.itemQuantity.frame = CGRectMake(CGRectGetMinX(itemQuantityLabelFrame), CGRectGetMaxY(itemQuantityLabelFrame) - kItemSpecificationMarge,
                                         CGRectGetWidth(itemQuantityLabelFrame), CGRectGetHeight(itemQuantityLabelFrame));

    self.itemValueLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:12.f];
    CGRect itemValueLabelFrame = self.itemValueLabel.frame;
    itemValueLabelFrame = CGRectMake(CGRectGetMinX(itemValueLabelFrame), CGRectGetMaxY(descrFrame)+ kItemSpecificationMarge,
                                     CGRectGetWidth(itemValueLabelFrame), CGRectGetHeight(itemValueLabelFrame));
    self.itemValueLabel.frame = itemValueLabelFrame;
    self.itemValue.frame =  CGRectMake(CGRectGetMinX(itemValueLabelFrame), CGRectGetMaxY(itemValueLabelFrame) - kItemSpecificationMarge,
                                       CGRectGetWidth(itemValueLabelFrame), CGRectGetHeight(itemValueLabelFrame));


    self.itemWeightLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:12.f];
    CGRect itemWeightLabelFrame = self.itemWeightLabel.frame;
    itemWeightLabelFrame = CGRectMake(CGRectGetMinX(itemWeightLabelFrame), CGRectGetMaxY(descrFrame)+ kItemSpecificationMarge,
                                      CGRectGetWidth(itemWeightLabelFrame), CGRectGetHeight(itemWeightLabelFrame));
    self.itemWeightLabel.frame = itemWeightLabelFrame;
    self.itemWeight.frame = CGRectMake(CGRectGetMinX(itemWeightLabelFrame), CGRectGetMaxY(itemWeightLabelFrame) - kItemSpecificationMarge,
                                       CGRectGetWidth(itemWeightLabelFrame), CGRectGetHeight(itemWeightLabelFrame));
    
    self.actionLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:14.f];
    
    [self setDetailsVisible:self.detailsVisible];
}

- (void)setSplitted:(BOOL)splitted
{
    self.indexLabel.textColor = (splitted) ? [UIColor lightGrayColor] : [UIColor colorWithRed:91.f/255.f green:91.f/255.f blue:91.f/255.f alpha:1.f];
    self.specLabel.textColor = (splitted) ? [UIColor lightGrayColor] : [UIColor colorWithRed:91.f/255.f green:91.f/255.f blue:91.f/255.f alpha:1.f];
    self.valueLabel.textColor = (splitted) ? [UIColor lightGrayColor] : [UIColor colorWithRed:91.f/255.f green:91.f/255.f blue:91.f/255.f alpha:1.f];
}

- (void)setDetailsVisible:(BOOL)detailsVisible completion:(CBSimpleCompletionBlock)completion
{
    [self setDetailsVisible:detailsVisible animated:YES completion:completion];
}

- (void)setDetailsVisible:(BOOL)detailsVisible
{
    [self setDetailsVisible:detailsVisible animated:NO completion:nil];
}

- (void)setDetailsVisible:(BOOL)detailsVisible animated:(BOOL)animated completion:(CBSimpleCompletionBlock)completion
{
    _detailsVisible = detailsVisible;
    
    self.dottedSeparator.hidden = !_detailsVisible;
    
    CGRect frame;
    CGRect separatorFrame;
    
    if (self.detailsVisible) {
        frame = self.clippedView.frame;
        separatorFrame = CGRectMake(0.f, CGRectGetMaxY(self.itemValue.frame) + 5.f, frame.size.width, 1);
    } else {
        frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds), CGRectGetHeight(self.coloredContentView.bounds) + 1);
        separatorFrame = CGRectMake(0.f, self.coloredContentView.frame.size.height - 1, self.coloredContentView.frame.size.width, 1);
    }
    
    [UIView animateWithDuration:(animated ? 0.3f : 0.0f)
                     animations:^{
                         self.clippingView.frame = frame;
                         self.arrowImageView.transform = (_detailsVisible) ? CGAffineTransformMakeRotation(M_PI_2) : CGAffineTransformIdentity;
                         self.separator.frame = separatorFrame;
                     } completion:^(BOOL finished) {
                         if (completion) {
                             completion(YES);
                         }
                     }];
}

@end
