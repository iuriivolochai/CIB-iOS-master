//
//  DCSwipeTableView.h
//  PwC
//
//  Created by Roman on 2/26/13.
//  Copyright (c) 2013 Roman. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RKSwipeTableView;

typedef void (^RKSwipeTableViewCompletionHandler)(BOOL completion);

typedef enum {
    RKSwipeTablewViewSwipeDirectionLeft = 0,
    RKSwipeTablewViewSwipeDirectionRight
} RKSwipeTablewViewSwipeDirection;

@protocol RKSwipeTableViewDelegate <UITableViewDelegate>

@optional
- (void)tableView:(RKSwipeTableView *)tableView willEndSwipingCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
      inDirection:(RKSwipeTablewViewSwipeDirection)swipeDirection completionHandler:(RKSwipeTableViewCompletionHandler)completion;
- (void)tableView:(RKSwipeTableView *)tableView didEndSwipingCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
      inDirection:(RKSwipeTablewViewSwipeDirection)swipeDirection;
- (NSArray *)tableView:(RKSwipeTableView *)tableView allowedSwipingDirectionsForCellAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol RKSwipeTableViewDataSource <UITableViewDataSource>

@optional

- (UIColor *)tableView:(RKSwipeTableView *)tableView backgroundColorForCellAtIndexPath:(NSIndexPath *)indexPath
      swipingDirection:(RKSwipeTablewViewSwipeDirection)direction;
- (UIColor *)tableView:(RKSwipeTableView *)tableView contentColorForCellAtIndexPath:(NSIndexPath *)indexPath
      swipingDirection:(RKSwipeTablewViewSwipeDirection)direction;
- (UIImage *)tableView:(RKSwipeTableView *)tableView accessoryImageForCellAtIndexPath:(NSIndexPath *)indexPath
      swipingDirection:(RKSwipeTablewViewSwipeDirection)direction;
- (UIView *)tableView:(RKSwipeTableView *)tableView backgroundViewForCellAtIndexPath:(NSIndexPath *)indexPath
     swipingDirection:(RKSwipeTablewViewSwipeDirection)direction;
- (UIView *)tableView:(RKSwipeTableView *)tableView swipingViewForCellAtIndexPath:(NSIndexPath *)indexPath
     swipingDirection:(RKSwipeTablewViewSwipeDirection)direction;
- (CGFloat)tableView:(RKSwipeTableView *)tableView swipingTriggerWidthCellAtIndexPath:(NSIndexPath *)indexPath
    swipingDirection:(RKSwipeTablewViewSwipeDirection)direction;
- (CGFloat)tableView:(RKSwipeTableView *)tableView swipingDestinationPercentageInCellAtIndexPath:(NSIndexPath *)indexPath
    swipingDirection:(RKSwipeTablewViewSwipeDirection)direction;

@end

@interface RKSwipeTableView : UITableView

@property (weak, nonatomic) id <RKSwipeTableViewDelegate> delegate;
@property (weak, nonatomic) id <RKSwipeTableViewDataSource> dataSource;

- (void)endUpdatesWithCompletion:(RKSwipeTableViewCompletionHandler)completion;
- (void)setContentOffset:(CGPoint)offset animated:(BOOL)animated changingContentSize:(BOOL)contentSize
       completionHandler:(RKSwipeTableViewCompletionHandler)completion;

@end
