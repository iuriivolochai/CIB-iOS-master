//
//  CBHelpSectionHeaderView.m
//  CIBBoomerang
//
//  Created by Daria Kopaliani on 5/29/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBHelpIssueHeaderView.h"

#import <QuartzCore/QuartzCore.h>
#import "CBHelpIssue.h"


@interface CBHelpIssueHeaderView ()

@property (strong, nonatomic) IBOutlet UIButton     *backgroundButton;
@property (strong, nonatomic) IBOutlet UIImageView  *detailIndicatorView;
@property (strong, nonatomic) IBOutlet UIImageView  *dottedSeparatorView;
@property (strong, nonatomic) IBOutlet UILabel      *indexLabel;
@property (strong, nonatomic) IBOutlet UILabel      *titleLabel;

@end


@implementation CBHelpIssueHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"CBHelpIssueHeaderView" owner:self options:nil] lastObject];
        [self addSubview:view];
        _index = NSNotFound;
        self.selected = NO;
        
        self.indexLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:20.f];
        self.titleLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:12.f];
    }
    return self;
}

- (void)setIssue:(CBHelpIssue *)issue
{
    if (_issue != issue) {
        _issue = issue;
        self.titleLabel.text = [issue.title uppercaseString];
    }
}

- (void)setIndex:(NSInteger)index
{
    if (_index != index) {
        _index = index;
        self.indexLabel.text = [NSString stringWithFormat:@"%d", index + 1];
    }
}

- (void)setSelected:(BOOL)selected
{
    [self setSelected:selected animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (_selected != selected) {
        _selected = selected;
        self.dottedSeparatorView.hidden = !_selected;
        [UIView animateWithDuration:(animated) ? 0.3f : 0.f
                              delay:0.f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^
         {
             self.detailIndicatorView.transform = (self.selected) ? CGAffineTransformMakeRotation(M_PI_2)
             : CGAffineTransformIdentity;
         }
                         completion:nil];
    }
}

#pragma mark - Private

- (IBAction)backgroundButtonTapped
{
    [self.delegate helpIssueHeaderViewDidSelect:self];
}

@end