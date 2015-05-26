//
//  CBCountryView.h
//  CIBBoomerang
//
//  Created by Daria Kopaliani on 6/12/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <UIKit/UIKit.h>


@class CBCountryView, DMWaypoint;

@protocol CBCountryViewDelegate <NSObject>

- (void)countryViewDidDetectTap:(CBCountryView *)countryView;
- (void)countryViewDidDetectLongPress:(CBCountryView *)countryView;

@end


@interface CBCountryView : UIView

@property (readonly, strong, nonatomic) DMWaypoint *waypoint;
@property (assign, nonatomic) BOOL selected;
@property (weak, nonatomic) id<CBCountryViewDelegate> delegate;

- (id)initWithFrame:(CGRect)theFrame waypoint:(DMWaypoint *)waypoint active:(BOOL)active totalCount:(int)totalCount;
- (void)reloadForPriority:(int)priority;

@end