//
//  CBHelpCellView.m
//  CIBBoomerang
//
//  Created by Artem Stepanenko on 5/29/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBHelpCellView.h"

@interface CBHelpCellView ()

@property (nonatomic, weak) IBOutlet UIImageView *circleImageView;
@property (nonatomic, weak) IBOutlet UILabel *indexLabel;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *arrowImageView;

@end

@implementation CBHelpCellView

- (NSInteger)index {
    return self.tag;
}

- (NSString *)title {
    return self.titleLabel.text;
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.text = [self.title uppercaseString];
}

@end
