//
//  CBReminderView.h
//  CIBBoomerang
//
//  Created by Roma on 8/1/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <UIKit/UIKit.h>


@class CBReminderView;

@protocol CBReminderViewDelegate <NSObject>

- (void)reminderView:(CBReminderView *)reminderView willHideWithDaysIntervalSelected:(NSUInteger)interval;

@end

@interface CBReminderView : UIView

@property (weak, nonatomic) IBOutlet id <CBReminderViewDelegate> delegate;

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated animationCompletionBlock:(void (^)(BOOL completed))completionHandler;

@end
