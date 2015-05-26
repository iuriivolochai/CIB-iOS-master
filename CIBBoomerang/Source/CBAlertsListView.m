//
//  CBRouteAlertView.m
//  CIBBoomerang
//
//  Created by Roman Kopaliani on 6/12/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBAlertsListView.h"

#import "CBAlertPageView.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface CBAlertsListView () <CBAlertPageViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) NSMutableArray *alertPageViews;
@property (strong, nonatomic) NSArray *alerts;

@property (strong, nonatomic) NSMutableSet *recycledPages;
@property (strong, nonatomic) NSMutableSet *visiblePages;

@end


@implementation CBAlertsListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"CBAlertsListView" owner:self options:nil] lastObject];
        [self addSubview:view];
        self.alertPageViews = [NSMutableArray array];
        
        [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
        self.scrollView.delegate = self;
        self.scrollView.scrollEnabled = NO;
        
        self.recycledPages  = [NSMutableSet setWithCapacity:2];
        self.visiblePages   = [NSMutableSet setWithCapacity:2];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"CBAlertsListView" owner:self options:nil] lastObject];
        [self addSubview:view];
        self.alertPageViews = [NSMutableArray array];
        
        [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
        self.scrollView.delegate = self;
        self.scrollView.scrollEnabled = NO;
        
        self.recycledPages  = [NSMutableSet setWithCapacity:2];
        self.visiblePages   = [NSMutableSet setWithCapacity:2];
    }
    return self;
}

- (void)dealloc
{
    DDLogVerbose(@"!!Dealloc CBAlertsListView");
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)reloadData
{
//    self.alerts = [self.datasource alertsToShowForListView:self];
//    self.pageControl.currentPage = 0;
//    self.scrollView.contentOffset = CGPointZero;
//    for (CBAlertPageView *alertView in self.alertPageViews) {
//        [alertView removeFromSuperview];
//    }
//    [self.alertPageViews removeAllObjects];
//    
//    CGFloat x = 0.;
//    for (id alert in self.alerts) {
//        CGRect frame = self.bounds;
//        frame.origin.x = x;
//        //			if (alert != [alerts lastObject])
//        x += CGRectGetWidth(self.bounds);
//        CBAlertPageView *alertView = [[CBAlertPageView alloc] initWithFrame:frame];
//        alertView.delegate = self;
//        [self.scrollView addSubview:alertView];
//        alertView.alert = alert;
//        [self.alertPageViews addObject:alertView];
//    }
//    
//    //		[self.scrollView setContentOffset: CGPointMake(0.0f, CGRectGetHeight(self.bounds)) animated:NO];
//    [self.scrollView setContentOffset: CGPointMake(0.0f, 0.0f) animated:NO];
//    self.scrollView.contentSize = CGSizeMake(x, CGRectGetHeight(self.bounds));
//    self.pageControl.numberOfPages = x / CGRectGetWidth(self.bounds);
    self.scrollView.contentOffset   = CGPointZero;
    self.scrollView.contentSize     = CGSizeZero;
    
    for (CBAlertPageView *pageView in self.visiblePages) {
        [pageView removeFromSuperview];
        [self.recycledPages addObject:pageView];
    }
    
    CGFloat width   = CGRectGetWidth(self.bounds);
    CGFloat height  = CGRectGetHeight(self.bounds);
    
    NSUInteger pagesCount       = [self.datasource numbersOfAlertForListView:self];
    self.scrollView.contentSize = CGSizeMake(width * pagesCount, height);
    
    [self layoutSubviews];
}

- (NSUInteger)alertIndex
{
    NSUInteger index = self.scrollView.contentOffset.x / CGRectGetWidth(self.scrollView.frame);
    return index;
}

- (NSInteger)selectedErrorPriority
{
    NSUInteger index = self.scrollView.contentOffset.x / CGRectGetWidth(self.scrollView.frame);
    id alert = self.alerts[index];
    return [(id <CBAlertObjectProtocol>)alert alertPriority];
}

- (CBAlertPageView *)dequeReusablePageView
{
    if (self.recycledPages.count)
        return [self.recycledPages anyObject];
    return nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSUInteger index = [self alertIndex];
    [self addPageViewForIndex:index];
    [self addPageViewForIndex:index + 1];
}

- (void)addPageViewForIndex:(NSUInteger)anAlertIndex
{
    NSUInteger pagesCount   = [self.datasource numbersOfAlertForListView:self];
    if (anAlertIndex >= pagesCount)
        return;
    if ([self isDisplayingPageForIndex:anAlertIndex]) {
        CBAlertPageView *pageView  = [self visiblePageForIndex:anAlertIndex];
        [self layoutPage:pageView atIndex:anAlertIndex];
    }
    else {
        CBAlertPageView *pageView = [self.datasource alertPageViewForIndex:anAlertIndex];
        [self layoutPage:pageView atIndex:anAlertIndex];
        [self.visiblePages addObject:pageView];
        [self.recycledPages addObject:pageView];
    }
}

- (void)layoutPage:(CBAlertPageView *)aPageView atIndex:(NSUInteger)anIndex
{
//    aPageView.alertIndex = anIndex;
    [self insertSubview:aPageView atIndex:0];
    CGFloat xOrigin     = anIndex * CGRectGetWidth(self.bounds);
    CGRect  pageFrame   = aPageView.frame;
    pageFrame.origin    = CGPointMake(xOrigin, CGRectGetMinY(pageFrame));
    aPageView.frame     = pageFrame;
}

- (CBAlertPageView *)visiblePageForIndex:(NSUInteger)anIndex
{
    for (CBAlertPageView *pageView in self.visiblePages) {
//        if (pageView.alertIndex == anIndex)
//            return pageView;
    }
    return nil;
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)anIndex
{
    for (CBAlertPageView *pageView in self.visiblePages) {
//        if (pageView.alertIndex == anIndex)
            return YES;
    }
    return NO;
}

#pragma mark - CBRouteAlertPageView delegate

- (void)alertPageView:(CBAlertPageView *)pageView withObjectID:(NSManagedObjectID *)objectID type:(int)alertType didTapButtonWithType:(CBAlertButtonType)buttonType
{
    NSUInteger index = [self.alertPageViews indexOfObject:pageView];
    if (index != self.alertPageViews.count - 1) {
        [self.scrollView setContentOffset:CGPointMake((index + 1) * CGRectGetWidth(self.scrollView.frame), 0.) animated:YES];
    }
    
    BOOL last = (index == self.alertPageViews.count - 1);
    [self.delegate routeAlertsView:self
             willDissmissLastAlert:last
                      withObjectId:objectID
                              type:alertType
                  withButtonTapped:buttonType];
}

- (void)alertPageView:(CBAlertPageView *)aPageView didDetectButtonTapped:(CBAlertButtonType)aButtonType forAlertWithType:(NSUInteger)anAlertType
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(routeAlertsViewDidFinishScrolling:)])
        [self.delegate routeAlertsViewDidFinishScrolling:self];
    
    if (scrollView.contentOffset.x + CGRectGetWidth(scrollView.frame) >= scrollView.contentSize.width)
        DDLogWarn(@"scrolled to maximum");
    else
        [self layoutSubviews];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
                       context:(void *)context
{
    self.pageControl.currentPage = roundf(self.scrollView.contentOffset.x / CGRectGetWidth(self.bounds));
    self.pageControl.hidden = (self.pageControl.numberOfPages <= 1);
}

@end