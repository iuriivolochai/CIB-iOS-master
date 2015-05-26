//
//  CBCountryView.m
//  CIBBoomerang
//
//  Created by Daria Kopaliani on 6/12/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBCountryView.h"

#import "DMWaypoint+Auxilliary.h"


@interface CBCountryView () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) DMWaypoint *waypoint;
@property (assign, nonatomic) NSInteger totalCount;
@property (assign, nonatomic) NSInteger priority;

@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (nonatomic, strong) UILabel *identifierLabel;
@property (nonatomic, strong) UIImageView *statusImageView;

@property (assign, nonatomic) BOOL active;
@end


@implementation CBCountryView 

- (id)initWithFrame:(CGRect)theFrame waypoint:(DMWaypoint *)waypoint active:(BOOL)active totalCount:(int)totalCount
{
    self = [super initWithFrame:theFrame];
    if (self) {
        self.exclusiveTouch = YES;
        
        self.active = active;
        self.waypoint = waypoint;
        self.totalCount = totalCount;
        
        self.backgroundColor = [UIColor whiteColor];
		
		self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
		self.backgroundImageView.image = [self backgroundImageForWaypoint:waypoint
                                                               totalCount:totalCount];
        self.backgroundImageView.contentMode = UIViewContentModeTop;
		[self addSubview:self.backgroundImageView];

        self.identifierLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.identifierLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:18.f];
        self.identifierLabel.backgroundColor = [UIColor clearColor];
        self.identifierLabel.text = waypoint.country.identifier;
        self.identifierLabel.textColor = [self textColorForWaypoint:waypoint];
        self.identifierLabel.textAlignment = UITextAlignmentCenter;
        [self addSubview:self.identifierLabel];
        
        self.statusImageView = [[UIImageView alloc] init];
        UIImage *statusImage = [self topImageForWaypoint:waypoint];
        self.statusImageView.frame = CGRectMake((CGRectGetWidth(theFrame) - statusImage.size.width) / 2,
                                                0.0f - statusImage.size.height,
                                                statusImage.size.width,
                                                statusImage.size.height);
        self.statusImageView.image = statusImage;
        [self addSubview:self.statusImageView];
        
        self.clipsToBounds = NO;
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                                 initWithTarget:self action:@selector(handleTap)];
        [self addGestureRecognizer:tapRecognizer];
        
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc]
                                                             initWithTarget:self
															 action:@selector(handleLongPress:)];
        [self addGestureRecognizer:longPressRecognizer];

    }
    return self;
}

#pragma mark - Public

- (void)reloadForPriority:(int)priority
{
    self.priority = priority;
    [self reload];
}

- (void)reload
{
    self.backgroundImageView.image = [self backgroundImageForWaypoint:self.waypoint
                                                           totalCount:self.totalCount];    
}

- (void)setSelected:(BOOL)selected
{
    if (_selected != selected) {
        _selected = selected;
        [self reload];
    }
}

#pragma mark - Private

- (UIColor *)textColorForWaypoint:(DMWaypoint *)waypoint
{
    if ([waypoint containsAlerts]) {
        return [UIColor whiteColor];
    }
    
    if ([waypoint.country isUSA] || (waypoint.kind & DMWaypointKindVisit)) {
        return [UIColor colorWithRed:100.f/255.f green:100.f/255.f blue:100.f/255.f alpha:1.0f];
    }

    return [UIColor whiteColor];
}

- (UIImage *)topImageForWaypoint:(DMWaypoint *)waypoint
{
    if ([waypoint containsAlerts]) {
        return [UIImage imageNamed:@"bg-route-exclamation"];
    }
    
    /*if ([waypoint containsStartpointIssue]) {
        return [UIImage imageNamed:@"bg-route-exclamation-warning"];
    }*/
    
    if (waypoint.status == DMWaypointStatusPassed) {
        return ((self.active)  ? [UIImage imageNamed:@"bg-level2-chain-human"] : [UIImage imageNamed:@"bg-level2-chain-checkmark"]);
    }
    
    return nil;
}

- (UIImage *)backgroundImageForWaypoint:(DMWaypoint *)waypoint totalCount:(int)totalCount
{
    if ([waypoint containsAlerts]) {
        if (self.priority == 1) {
            return [UIImage imageNamed:(self.selected) ? @"btn-route-selector" : @"bg-route-view-error"];
        } else {
            return [UIImage imageNamed:(self.selected) ? @"btn-route-selector-yellow" : @"bg-route-view-error-yellow"];
        }
    }
    
    if ([waypoint containsOnlyPopovers]) {
        return [UIImage imageNamed:@"bg-route-view-error-yellow"];
    }
    
    switch (waypoint.status) {
        case DMWaypointStatusPassed:
            self.backgroundImageView.alpha = 1.f;
            break;
        case DMWaypointStatusQueued:
            self.backgroundImageView.alpha = 0.6;
            break;
    }

    if (waypoint.containsError)
        return [UIImage imageNamed:@"bg-route-view-error"];

    if ([waypoint.country isUSA])
        return [UIImage imageNamed:@"btn-route-initial"];

    if (waypoint.kind & DMWaypointKindTransit) {
        return [UIImage imageNamed:@"bg-bottom-bar-current"];
    } else if (waypoint.kind & DMWaypointKindVisit) {
        return [UIImage imageNamed:@"btn-route-normal"];
    } else {
        return nil;
    }
}

- (void)handleTap
{
    [self.delegate countryViewDidDetectTap:self];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateBegan && (self.waypoint.status == DMWaypointStatusQueued && self.waypoint.kind != DMWaypointKindEndpoint)) {
	    [self.delegate countryViewDidDetectLongPress:self];
	}
}

@end