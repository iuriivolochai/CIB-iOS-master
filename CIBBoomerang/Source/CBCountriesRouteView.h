//
//  CBCountriesRouteView.h
//  CIBBoomerang
//
//  Created by Artem Stepanenko on 5/8/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

@class CBCountriesRouteView, DMWaypoint;

@protocol CBCountriesRouteViewDataSource <NSObject>

- (DMWaypoint *)countriesRouteView:(CBCountriesRouteView *)sender countryIdentifierAtIndex:(NSInteger)index;
- (NSInteger)numberOfItemsInCountriesRouteView:(CBCountriesRouteView *)sender;

@end

@protocol CBCountriesRouteViewDelegate <NSObject>

- (void)countriesRouteViewDidPressAddNew:(CBCountriesRouteView *)sender;
- (void)countriesRouteViewDidShowLastPage:(CBCountriesRouteView *)aRouteView;
- (void)countriesRouteView:(CBCountriesRouteView *)sender didDetectLongPressInWaypoint:(DMWaypoint *)waypoint;
- (void)countriesRouteView:(CBCountriesRouteView *)aRouteView didDetectButtonWithTypeTapped:(CBAlertButtonType)aButton
          forAlertWithType:(CBAlertType)aType
              forWaypoint:(DMWaypoint *)aWaypoint;

@end

@interface CBCountriesRouteView : UIView

@property (nonatomic, weak) IBOutlet id<CBCountriesRouteViewDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id<CBCountriesRouteViewDelegate> delegate;
@property (nonatomic, strong) UIScrollView *scrollView;

- (id)initWithCoder:(NSCoder *)aDecoder;

- (void)reloadData;

- (BOOL)shouldShowAlertView;

@end
