//
//  CBNewAlertListView.h
//  CIBBoomerang
//
//  Created by Roma on 8/26/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "DARecycledScrollView.h"
#import "CBAlertPageView.h"

@class CBNewAlertListView;
@protocol CBNewAlertListViewDelegate <NSObject>

- (void)listView:(CBNewAlertListView *)aListView didDetectButtonTapped:(CBAlertButtonType)aButtonType forAlertWithType:(NSUInteger)anAlertType;
- (void)listViewDidShowLastPage:(CBNewAlertListView *)aLisstView;

@end

@protocol CBNewAlertListViewDataSource <NSObject>

- (NSInteger)numberOfPagesInListView:(CBNewAlertListView *)aListView;
- (void)listView:(CBNewAlertListView *)aListView configurePage:(CBAlertPageView *)tileView forIndex:(NSUInteger)index;

@end

@interface CBNewAlertListView : UIView

@property (weak, nonatomic) id <CBNewAlertListViewDelegate>     delegate;
@property (weak, nonatomic) id <CBNewAlertListViewDataSource>   dataSource;

- (void)reloadData;
- (NSInteger)selectedErrorPriority;

@end
