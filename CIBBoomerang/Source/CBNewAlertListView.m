//
//  CBNewAlertListView.m
//  CIBBoomerang
//
//  Created by Roma on 8/26/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBNewAlertListView.h"
#import "CBAlertPageView.h"

#import "DARecycledTileView.h"

@interface CBNewAlertListView () <CBAlertPageViewDelegate, DARecycledScrollViewDataSource>

@property (strong, nonatomic) IBOutlet DARecycledScrollView *recycledView;

@end

@implementation CBNewAlertListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
        [self addSubview:view];
        [view setFrame: self.bounds];
        _recycledView.dataSource    = self;
        _recycledView.scrollEnabled = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        UIView *view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
        [self addSubview:view];
        _recycledView.dataSource    = self;
        _recycledView.scrollEnabled = NO;
        
}
    return self;
}

- (void)reloadData
{
    [_recycledView reloadData];
}

- (NSInteger)selectedErrorPriority
{
    CBAlertPageView *activePage = (CBAlertPageView *)_recycledView.visbleTileView;
    return [activePage.alert alertPriority];
}

#pragma mark - DARecycledScrollViewDataSource

- (NSInteger)numberOfTilesInScrollView:(DARecycledScrollView *)scrollView
{
    return [_dataSource numberOfPagesInListView:self];
}

- (void)recycledScrollView:(DARecycledScrollView *)scrollView configureTileView:(DARecycledTileView *)tileView forIndex:(NSUInteger)index
{
    [_dataSource listView:self configurePage:(CBAlertPageView *)tileView forIndex:index];
}

- (DARecycledTileView *)tileViewForRecycledScrollView:(DARecycledScrollView *)scrollView
{
    CBAlertPageView *tileView = (CBAlertPageView *)[scrollView dequeueRecycledTileView];
    if (!tileView) {
//        tileView = [[CBAlertPageView alloc] initWithFrame:CGRectMake(0., 0., 100., CGRectGetHeight(scrollView.bounds))];
        tileView = [[CBAlertPageView alloc] initWithFrame:CGRectMake(0., 0., CGRectGetWidth(scrollView.bounds), CGRectGetHeight(scrollView.bounds))];
        tileView.delegate = self;
    }
    return tileView;
}

- (CGFloat)widthForTileAtIndex:(NSInteger)index scrollView:(DARecycledScrollView *)scrollView
{
    return CGRectGetWidth(scrollView.bounds);
}

- (void)alertPageView:(CBAlertPageView *)aPageView didDetectButtonTapped:(CBAlertButtonType)aButtonType forAlertWithType:(NSUInteger)anAlertType
{
    if ([_delegate respondsToSelector:@selector(listView:didDetectButtonTapped:forAlertWithType:)])
        [_delegate listView:self didDetectButtonTapped:aButtonType forAlertWithType:anAlertType];

    if (aPageView.alertIndex + 1 == [_dataSource numberOfPagesInListView:self]) {
        [_delegate listViewDidShowLastPage:self];
    }
    else
        [_recycledView scrollToTileAtIndex:aPageView.alertIndex + 1 animated:YES];
}

@end
