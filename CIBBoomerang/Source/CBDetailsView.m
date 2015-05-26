//
//  CBDetailsView.m
//  CIBBoomerang
//
//  Created by Roma on 5/16/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBDetailsView.h"
#import "DMItem+Auxilliary.h"
#import "CBItemDetailsView.h"

@interface CBDetailsView () <UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *itemScrollView;
@property (strong, nonatomic) IBOutlet UILabel *pageLabel;

@end


@implementation CBDetailsView

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

- (void)configureView
{
    self.itemScrollView.delegate = self;
    self.itemScrollView.pagingEnabled = YES;
    self.itemScrollView.clipsToBounds = YES;
    self.itemScrollView.backgroundColor = [UIColor whiteColor];
    self.itemScrollView.canCancelContentTouches = NO;
    self.itemScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.itemScrollView.showsVerticalScrollIndicator = NO;
}

- (void)setItems:(NSArray *)items
{
    _items = items;
    [self layoutScrollView];
}

- (void)layoutScrollView
{
    __block CGFloat xOrigin = 0.f;
    CGFloat itemWidht = 320.f;
    CGFloat itemHeight = 160.f;
    [self.items enumerateObjectsUsingBlock:^(DMItem *item, NSUInteger idx, BOOL *stop) {
        CBItemDetailsView *itemDetailsView = [[CBItemDetailsView alloc] initWithItem:item
                                                                               frame:CGRectMake(xOrigin, 0.0f, itemWidht, itemHeight)];
        [self.itemScrollView addSubview:itemDetailsView];
        xOrigin = xOrigin + itemWidht;
    }];
    self.itemScrollView.contentSize = CGSizeMake(self.items.count * itemWidht, itemHeight);
    
    self.pageLabel.text = [NSString stringWithFormat:@"Item %d / %d", self.currentIndex + 1, self.items.count];
    self.itemScrollView.contentOffset = CGPointMake(self.currentIndex * itemWidht, 0.0f);
}

- (IBAction)backButtonTapped:(UIButton *)sender
{
    [self.delegate detailsView:self showHideAnimated:YES];
}

#pragma mark - UISrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.currentIndex = lround(scrollView.contentOffset.x /
                                          (scrollView.contentSize.width / self.items.count));
    self.pageLabel.text = [NSString stringWithFormat:@"Item %d / %d", self.currentIndex + 1, self.items.count];
}

@end
