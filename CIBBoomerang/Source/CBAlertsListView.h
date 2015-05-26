//
//  CBRouteAlertView.h
//  CIBBoomerang
//
//  Created by Roman Kopaliani on 6/12/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DARecycledScrollView.h"

@class CBAlertsListView, CBAlertPageView;

@protocol CBAlertsListViewDataSource <NSObject>

- (NSUInteger)numbersOfAlertForListView:(CBAlertsListView *)anAlertsView;
- (CBAlertPageView *)alertPageViewForIndex:(NSUInteger)anIndex;

@end


@protocol CBAlertsListViewDelegate <NSObject>

@optional
- (void)routeAlertsViewDidFinishScrolling:(CBAlertsListView *)alertsView;
- (void)routeAlertsView:(CBAlertsListView *)view
  willDissmissLastAlert:(BOOL)last
           withObjectId:(NSManagedObjectID *)objectID
                   type:(NSUInteger)alertType
       withButtonTapped:(CBAlertButtonType)buttonType;

@end


@interface CBAlertsListView : UIView

@property (weak, nonatomic) id <CBAlertsListViewDelegate>   delegate;
@property (weak, nonatomic) id <CBAlertsListViewDataSource> datasource;

- (NSInteger)selectedErrorPriority;
- (void)reloadData;

@end
