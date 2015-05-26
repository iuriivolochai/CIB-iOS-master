//
//  CBDetailsView.h
//  CIBBoomerang
//
//  Created by Roma on 5/16/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CBDetailsView;
@protocol CBDetailsViewDelegate <NSObject>

- (void)detailsView:(CBDetailsView *)view showHideAnimated:(BOOL)animated;

@end

@interface CBDetailsView : UIView

@property (strong, nonatomic) NSArray *items;
@property (assign, nonatomic) int currentIndex;
@property (weak, nonatomic) id <CBDetailsViewDelegate> delegate;

@end
