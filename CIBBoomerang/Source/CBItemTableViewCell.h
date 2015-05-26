//
//  CBItemTableViewCell.h
//  CIBBoomerang
//
//  Created by Artem Stepanenko on 5/10/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString * const ItemTableViewCellReuseIdentifier;
FOUNDATION_EXPORT CGFloat const kItemSpecificationWidth;

@class DMItem;

@interface CBItemTableViewCell : UITableViewCell

/* clipping view */
@property (strong, nonatomic) IBOutlet UIView *clippingView;
@property (weak, nonatomic) IBOutlet UIView *clippedView;

/* swiping view */
@property (nonatomic, weak) IBOutlet UIView *coloredBgView;
@property (nonatomic, weak) IBOutlet UIView *coloredContentView;
@property (nonatomic, weak) IBOutlet UILabel *actionLabel;

/* content view */
@property (nonatomic, weak) IBOutlet UILabel *indexLabel;
@property (nonatomic, weak) IBOutlet UIImageView *arrowImageView;
@property (nonatomic, weak) IBOutlet UILabel *specLabel;
@property (nonatomic, weak) IBOutlet UILabel *valueLabel;

/* description view */
@property (weak, nonatomic) IBOutlet UILabel *itemDescription;
@property (weak, nonatomic) IBOutlet UILabel *itemOrigin;
@property (weak, nonatomic) IBOutlet UILabel *itemQuantity;
@property (weak, nonatomic) IBOutlet UILabel *itemWeight;
@property (weak, nonatomic) IBOutlet UILabel *itemValue;
@property (weak, nonatomic) IBOutlet UILabel *itemDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemOriginLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemQuantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemWeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemValueLabel;

/* bottom view */
@property (strong, nonatomic) IBOutlet UIImageView *splitImageView;
@property (strong, nonatomic) IBOutlet UILabel *splitLabel;
@property (strong, nonatomic) IBOutlet UIView *splitView;
/* item */
@property (nonatomic, strong) DMItem *item;

/* auxiliiary */
@property (nonatomic, assign) NSInteger index;
@property (assign, nonatomic) BOOL detailsVisible;

- (void)configureView;
- (void)setSplitted:(BOOL)splitted;
- (void)setDetailsVisible:(BOOL)detailsVisible  completion:(CBSimpleCompletionBlock)completion;

@end
