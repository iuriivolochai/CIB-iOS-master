//
//  CBCountriesRouteView.m
//  CIBBoomerang
//
//  Created by Artem Stepanenko on 5/8/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBCountriesRouteView.h"

#import <QuartzCore/QuartzCore.h>
#import "CBCountryView.h"
#import "CBAlertsListView.h"
#import "CBNewAlertListView.h"
#import "DMLocationAlert.h"
#import "DMWaypoint+Auxilliary.h"

static CGFloat kScrollSizeHeigth    = 84.f;
static CGFloat kCountryViewMarge    = 4.f;
static CGFloat kCountryViewHeight   = 37.f;
static CGFloat kCountryViewOffset   = 10.f;
static CGFloat kCountryViewTop      = 25.f;
static CGFloat kCountryViewWidth    = 37.f;

@interface CBCountriesRouteView () <CBCountryViewDelegate, CBNewAlertListViewDataSource, CBNewAlertListViewDelegate>


@property (nonatomic, strong) UIImageView *separator;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) CBNewAlertListView *  routeAlertView;
@property (nonatomic, strong) CBCountryView         *selectedCoutryView;
@property (nonatomic, strong) NSMutableArray        *alertsArray;
@property (nonatomic, strong) NSMutableArray        *countryViews;
@property (nonatomic, strong) NSMutableArray        *waypoints;

- (void)clearContent;
- (void)drawHorizontalLineWithY:(CGFloat)y fromX:(CGFloat)fromX toX:(CGFloat)toX inView:(UIView *)view;
- (void)addDidPress:(id)sender;
- (BOOL)shouldShowAlertView;
- (void)updateAlertViewForCountryView:(CBCountryView *)countryView;

@end

@implementation CBCountriesRouteView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];    
    if (self) {
        self.countryViews = [NSMutableArray array];
        CGRect scrollFrame = self.bounds;
        scrollFrame.size.height = kScrollSizeHeigth;
        self.scrollView = [[UIScrollView alloc] initWithFrame:scrollFrame];
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.alwaysBounceHorizontal = YES;
        self.scrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.scrollView];
        
        _alertsArray = [NSMutableArray arrayWithCapacity:6];
    }
    
    return self;
}

- (void) layoutSubviews
{
    if([[UIDevice currentDevice] systemVersionGreaterOrEqual: 8.0])
    {
        CGRect scrollFrame = self.bounds;
        scrollFrame.size.height = kScrollSizeHeigth;
        [self.scrollView setFrame: scrollFrame];
    }
    else
    {
        [super layoutSubviews];
    }
}

- (void)reloadData
{
    if (!self.dataSource) {
        return;
    }
    
    [self clearContent];
    if (_routeAlertView) {
        [self.routeAlertView removeFromSuperview];
        self.routeAlertView = nil;
    }
    
    CGFloat top = kCountryViewTop + kCountryViewMarge;
    CGFloat right = kCountryViewWidth + kCountryViewOffset;
    
    [self reloadDataSource];
    int countriesCount = self.waypoints.count;
    
    NSArray *passedWaypoints = [self waypointsFromWaypoints:self.waypoints withStatus:DMWaypointStatusPassed];
    
    for (NSInteger i = 0; i < [passedWaypoints count]; ++i) {
        DMWaypoint *waypoint = passedWaypoints[i];

        if (i > 0) {
            [self drawHorizontalLineWithY:top + kCountryViewHeight/2
                                    fromX:(right - kCountryViewWidth - kCountryViewOffset)
                                      toX:(right - kCountryViewWidth)
                                   inView:self.scrollView];
        }
        
        CGRect frame = CGRectMake(right - kCountryViewWidth, top, kCountryViewWidth, kCountryViewHeight);
        CBCountryView *countryView = [[CBCountryView alloc] initWithFrame:frame
                                                                 waypoint:waypoint
                                                                   active:waypoint == [waypoint.carnet activeWaypoint] 
                                                               totalCount:countriesCount];

        countryView.delegate = self;
        [self.scrollView addSubview:countryView];
        right += kCountryViewWidth + kCountryViewOffset;
        [self.countryViews addObject:countryView];
    }
    
    //dotted
    UIImage *image = [UIImage imageNamed:@"bg-route-view-dots"];
    UIImageView *dotsViewLeft = [[UIImageView alloc] initWithImage:image];
    dotsViewLeft.frame = CGRectMake(right - kCountryViewWidth - kCountryViewOffset/2,
                                    top + kCountryViewHeight/2 - 1.f,
                                    image.size.width,
                                    image.size.height);
    
    [self.scrollView addSubview:dotsViewLeft];
    
    right = right + image.size.width;
    
    // add button
    self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.addButton.exclusiveTouch = YES;
    UIImage *plusImage = [UIImage imageNamed:@"btn-route-add"];
    right = right - kCountryViewWidth + plusImage.size.width;
    [self.addButton setBackgroundImage:plusImage forState:UIControlStateNormal];
    [self.addButton addTarget:self action:@selector(addDidPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.addButton setFrame:CGRectMake(right - plusImage.size.width, top - 2.f, plusImage.size.width, plusImage.size.height)];
    [self.scrollView addSubview:self.addButton];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.addButton.frame) - 14.f, self.addButton.frame.size.width, 16.f)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:@"ADD"];
    [label setFont:[CBFontUtils droidSansFontBold:YES ofSize:10]];
    [label setTextColor:[UIColor blackColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    label.center = CGPointMake(self.addButton.center.x, label.center.y);
    [self.scrollView addSubview:label];
    
    right += kCountryViewOffset + kCountryViewWidth;

    NSArray *queuedWaypoints = [self waypointsFromWaypoints:self.waypoints withStatus:DMWaypointStatusQueued];
    
    if ([queuedWaypoints lastObject]) {
        UIImageView *dotsViewRights = [[UIImageView alloc] initWithImage:image];
        dotsViewRights.frame = CGRectMake(right - kCountryViewWidth - kCountryViewOffset/2,
                                          top + kCountryViewHeight/2 - 1.f,
                                          image.size.width,
                                          image.size.height);
        [self.scrollView addSubview:dotsViewRights];
        
        right = right + image.size.width;
        
        for (NSInteger i = 0; i < [queuedWaypoints count]; ++i) {
            DMWaypoint *waypoint = queuedWaypoints[i];
            if (i > 0) {
                [self drawHorizontalLineWithY:top + kCountryViewHeight/2
                                        fromX:(right - kCountryViewWidth - kCountryViewOffset)
                                          toX:(right - kCountryViewWidth)
                                       inView:self.scrollView];
            }
            
            CBCountryView *countryView = [[CBCountryView alloc] initWithFrame:CGRectMake(right - kCountryViewWidth,
                                                                                         top,
                                                                                         kCountryViewWidth,
                                                                                         kCountryViewHeight)
                                                                     waypoint:waypoint
                                                                       active:NO 
                                                                   totalCount:countriesCount];
            
            countryView.delegate = self;
            [self.scrollView addSubview:countryView];
            right += kCountryViewWidth + kCountryViewOffset;
            [self.countryViews addObject:countryView];
        }
    }

    self.scrollView.contentSize = CGSizeMake(right - kCountryViewWidth, self.scrollView.bounds.size.height);

    if (self.separator) {
		[self.separator removeFromSuperview];
	}
    
    if ([self shouldShowAlertView]) {
        CGRect alertViewFrame = self.routeAlertView.frame;
        alertViewFrame.origin.y = CGRectGetMaxY(self.scrollView.frame) - 4.f;
        self.routeAlertView.frame = alertViewFrame;
        self.routeAlertView.delegate = self;
        [self insertSubview:self.routeAlertView belowSubview:self.scrollView];
        CGRect frame = self.frame;
        frame.size.height = CGRectGetHeight(self.scrollView.frame) + CGRectGetHeight(self.routeAlertView.frame);
        self.frame = frame;
        for (NSInteger i = self.countryViews.count - 1; i >= 0; i--) {
            CBCountryView *countryView = self.countryViews[i];
            if ([countryView.waypoint containsAlerts]) {
                [self updateAlertViewForCountryView:countryView];
                countryView.selected = YES;
                self.selectedCoutryView = countryView;
				[countryView reloadForPriority:[self.routeAlertView selectedErrorPriority]];
                break;
            }
        }
    } else {
        CGRect frame = self.frame;
        frame.size.height = CGRectGetHeight(self.scrollView.frame);
        self.frame = frame;
        CGRect separatorFrame = CGRectMake(0.f, CGRectGetMaxY(self.bounds) - 1,
                                           (self.scrollView.contentSize.width > 320.f) ? self.scrollView.contentSize.width : 320.f, 1.f);
        self.separator = [[UIImageView alloc] initWithFrame:separatorFrame];
        self.separator.image = [UIImage imageNamed:@"bg-soliciting-separator"];
        [self addSubview:self.separator];
    }
}

#pragma mark - Private

- (void)reloadDataSource
{
    NSInteger countriesCount = [self.dataSource numberOfItemsInCountriesRouteView:self];
    if (self.waypoints) {
        [self.waypoints removeAllObjects];
    }
    else {
        self.waypoints = [[NSMutableArray alloc] initWithCapacity:countriesCount];
    }
    
    for (int i = 0; i < countriesCount; ++i) {
        DMWaypoint *waypoint = [self.dataSource countriesRouteView:self countryIdentifierAtIndex:i];
        [self.waypoints addObject:waypoint];
    }
}

- (void)clearContent
{
    [self.countryViews removeAllObjects];
    while ([self.scrollView.subviews lastObject]) {
        UIView *subview = [self.scrollView.subviews lastObject];
        [subview removeFromSuperview];
    }
}

- (void)drawHorizontalLineWithY:(CGFloat)y fromX:(CGFloat)fromX toX:(CGFloat)toX inView:(UIView *)view
{
    static CGFloat thikness = 2;
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(fromX, y - thikness / 2, toX - fromX, thikness)];
    lineView.backgroundColor = [UIColor colorWithRed:100.f/255.f green:100.f/255.f blue:100.f/255.f alpha:1.0f];
    [view addSubview:lineView];
}

- (void)addDidPress:(id)sender
{
    [self.delegate countriesRouteViewDidPressAddNew:self];
}

- (BOOL)shouldShowAlertView
{
    [self reloadDataSource];
    for (DMWaypoint *waypoint in self.waypoints) {
        if ([waypoint containsAlerts]) {
            return YES;
        }
    }
    return NO;
}

- (void)updateAlertViewForCountryView:(CBCountryView *)countryView
{
    self.selectedCoutryView = countryView;
    if (self.alertsArray.count)
        [self.alertsArray removeAllObjects];
    
    [self.alertsArray addObjectsFromArray:[countryView.waypoint getAlertsArray]];
    [self.routeAlertView reloadData];
}

#pragma mark - Lazy getters

- (CBNewAlertListView *)routeAlertView
{
    if (!_routeAlertView) {
        _routeAlertView = [[CBNewAlertListView alloc] initWithFrame:CGRectMake(0., 0., CGRectGetWidth(self.frame), 135)];
        [_routeAlertView setBackgroundColor:[UIColor whiteColor]];
//        [_routeAlertView setBackgroundColor:[UIColor greenColor]];
        _routeAlertView.dataSource = self;
    }
    return _routeAlertView;
}

- (NSArray *)alertsToShowForListView:(CBAlertsListView *)alertsView
{
//    __block NSArray *retArray;
//    [self.selectedCoutryView.waypoint obtainLocationAlerts:^(NSArray *alerts, NSArray *popovers) {
//        retArray = alerts;
//    }];
//    NSArray *retArray = [self.selectedCoutryView.waypoint get]
//    return retArray;
    NSArray *retArray = [self.selectedCoutryView.waypoint getAlertsArray];
    return retArray;
}

#pragma mark - CBCountryView delegate

- (void)countryViewDidDetectTap:(CBCountryView *)countryView
{
    if ([countryView.waypoint containsAlerts]) {
        self.selectedCoutryView = countryView;
        [self updateAlertViewForCountryView:countryView];
        for (CBCountryView *aCountryView in self.countryViews) {
            aCountryView.selected = (aCountryView == countryView);
        }
    }
}

- (void)countryViewDidDetectLongPress:(CBCountryView *)countryView
{
    [self.delegate countriesRouteView:self didDetectLongPressInWaypoint:countryView.waypoint];
}

#pragma mark - CBRouteAlertsView delegate

- (void)routeAlertsViewDidFinishScrolling:(CBAlertsListView *)alertsView
{
    CBCountryView *selectedCountryView = nil;
    for (CBCountryView *countryView in self.countryViews) {
        if (countryView.selected) {
            selectedCountryView = countryView;
            break;
        }
    }
    if (selectedCountryView) {
        [selectedCountryView reloadForPriority:[self.routeAlertView selectedErrorPriority]];
    }
}

#pragma mark - CBNewAlertsViewDataSource && Delegate

- (void)listViewDidShowLastPage:(CBNewAlertListView *)aLisstView
{
    [self reloadData];
    [_delegate countriesRouteViewDidShowLastPage:self];
}

- (void)listView:(CBNewAlertListView *)aListView didDetectButtonTapped:(CBAlertButtonType)aButtonType forAlertWithType:(NSUInteger)anAlertType
{
    [_delegate countriesRouteView:self didDetectButtonWithTypeTapped:aButtonType forAlertWithType:anAlertType forWaypoint:self.selectedCoutryView.waypoint];
}

- (void)listView:(CBNewAlertListView *)aListView configurePage:(CBAlertPageView *)tileView forIndex:(NSUInteger)index
{
    [tileView setAlert:_alertsArray[index]];
    tileView.alertIndex = index;
}

- (NSInteger)numberOfPagesInListView:(CBNewAlertListView *)aListView
{
    return [self.alertsArray count];
}

#pragma mark - Private

- (NSArray *)waypointsFromWaypoints:(NSArray *)waypoints withStatus:(DMWaypointStatus)status
{
    NSMutableArray *requiredWaypoints = [NSMutableArray array];
    
    for (DMWaypoint *waypoint in waypoints) {
        if (waypoint.status == status) {
            [requiredWaypoints addObject:waypoint];
        }
    }
    
    return [NSArray arrayWithArray:requiredWaypoints];
}

@end