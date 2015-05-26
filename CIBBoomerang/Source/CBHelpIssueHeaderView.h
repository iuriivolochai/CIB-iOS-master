//
//  CBHelpSectionHeaderView.h
//  CIBBoomerang
//
//  Created by Daria Kopaliani on 5/29/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <UIKit/UIKit.h>


@class CBHelpIssue, CBHelpIssueHeaderView;

@protocol CBHelpIssueHeaderViewDelegate <NSObject>

- (void)helpIssueHeaderViewDidSelect:(CBHelpIssueHeaderView *)view;

@end


@interface CBHelpIssueHeaderView : UIView

@property (assign, nonatomic) NSInteger index;
@property (assign, nonatomic) BOOL selected;
@property (strong, nonatomic) CBHelpIssue *issue;
@property (weak, nonatomic) id<CBHelpIssueHeaderViewDelegate> delegate;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

@end
