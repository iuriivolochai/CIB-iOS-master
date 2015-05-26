//
//  CBItemDetailsView.m
//  CIBBoomerang
//
//  Created by Roma on 5/16/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBItemDetailsView.h"
#import "DMItem+Auxilliary.h"

@interface CBItemDetailsView ()

@property (strong, readwrite, nonatomic) DMItem *item;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *itemDescription;
@property (weak, nonatomic) IBOutlet UILabel *itemOrigin;
@property (weak, nonatomic) IBOutlet UILabel *itemQuantity;
@property (weak, nonatomic) IBOutlet UILabel *itemWeight;
@property (weak, nonatomic) IBOutlet UILabel *itemValue;

@end

@implementation CBItemDetailsView

- (id)initWithItem:(DMItem *)item frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _item = item;
        [self configureView];
    }
    return self;
}

#pragma mark - View configuration

- (void)configureView
{
    [self loadFromNib];
    [self configureViewWithItem];
}

- (void)loadFromNib
{
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                  owner:self
                                options:nil];
    [self addSubview:self.contentView];
}

- (void)configureViewWithItem
{
    self.itemDescription.text = self.item.specification;

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    //        paragraphStyle.lineHeightMultiple = 0.8;
    //        paragraphStyle.lineSpacing = -1.f;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.paragraphSpacing = 0.0f;
    paragraphStyle.paragraphSpacingBefore = 0.0f;
    NSDictionary *titleDict = @{NSFontAttributeName :[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.f], NSParagraphStyleAttributeName : paragraphStyle};
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:self.item.specification
                                                                                       attributes:titleDict];
    self.itemDescription.attributedText = attributedText;
    self.itemDescription.numberOfLines = 0;
    [self.itemDescription sizeToFit];
    
//    CGSize constrainedToSize = CGSizeMake(CGRectGetWidth(self.itemDescription.frame), CGRectGetMaxY(self.imageView.frame) - CGRectGetMaxY(self.timeLabel.frame));
//    _titleLabel.frame = CGRectMake(CGRectGetMinX(_titleLabel.frame),  CGRectGetMaxY(self.timeLabel.frame), constrainedToSize.width, constrainedToSize.height);
    
    self.itemOrigin.text = @"US";
    self.itemQuantity.text = [NSString stringWithFormat:@"%d", self.item.quantity];
    self.itemValue.text = [NSString stringWithFormat:@"%.f", self.item.value];
    self.itemWeight.text = [NSString stringWithFormat:@"%.f", self.item.weight];
}

@end
