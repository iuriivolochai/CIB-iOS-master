//
//  DCSwipeTableView.m
//  PwC
//
//  Created by Roman on 2/26/13.
//  Copyright (c) 2013 Roman. All rights reserved.
//

#import "RKSwipeTableView.h"

@interface RKSwipeTableView () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIPanGestureRecognizer *recognizer;
@property (strong, nonatomic) NSIndexPath *activeIndexPath;

@property (strong, nonatomic) UIColor *defaultColor;
@property (strong, nonatomic) UIColor *swipingColor;
@property (strong, nonatomic) UIImageView *accessoryImage;
@property (strong, nonatomic) UIView *coloredBackgroundView;
@property (strong, nonatomic) UIView *swipingView;

@property (assign, nonatomic) CGFloat maxTransition;
@property (assign, nonatomic) BOOL animating;

/* handlers */
@property (copy, nonatomic) RKSwipeTableViewCompletionHandler completionHandler;
@property (copy, nonatomic) RKSwipeTableViewCompletionHandler contentSizeCompletion;

/* offset auxilliary */
@property (assign, nonatomic) BOOL endingUpdates;
@property (assign, nonatomic) BOOL settingContentSize;
@property (assign, nonatomic) CGPoint targetOffset;

@end

@implementation RKSwipeTableView

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addRecognizer];
        [self addContentOffsetObserver];
        _maxTransition = 44;
        [self setShowsVerticalScrollIndicator:NO];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addRecognizer];
        [self addContentOffsetObserver];
        _maxTransition = 44;
        [self setShowsVerticalScrollIndicator:NO];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self addRecognizer];
        [self addContentOffsetObserver];
        _maxTransition = 44;
        [self setShowsVerticalScrollIndicator:NO];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:keySwipeTableViewContentOffset];
}

#pragma mark - Public

- (void)endUpdatesWithCompletion:(RKSwipeTableViewCompletionHandler)completion
{
    [self endUpdates];
    
    self.settingContentSize  = YES;
    self.contentSizeCompletion = completion;
}

- (void)setContentOffset:(CGPoint)offset animated:(BOOL)animated changingContentSize:(BOOL)changeContentSize
       completionHandler:(RKSwipeTableViewCompletionHandler)completion
{
    _endingUpdates = YES;
    self.completionHandler = completion;
    self.targetOffset = offset;
        CGSize contentSize = self.contentSize;
    if (changeContentSize)  {
            contentSize.height = contentSize.height + self.frame.size.height - 42.f;
    }
    else {
            contentSize.height = contentSize.height + 1.f;
    }
        self.contentSize = contentSize;

    [self setContentOffset:offset animated:animated];
}

- (void)setContentSize:(CGSize)contentSize
{
    [super setContentSize:contentSize];
    
    if (self.settingContentSize) {
        self.settingContentSize = NO;
        self.contentSizeCompletion (YES);
    }
}

#pragma mark - Configuration

- (void)addRecognizer
{
    _recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                          action:@selector(handlePanGesture:)];
    _recognizer.delegate = self;
    _recognizer.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:_recognizer];
}

static NSString *const keySwipeTableViewContentOffset = @"contentOffset";
static NSString *const keySwipeTableViewNew = @"new";

- (void)addContentOffsetObserver
{
    [self addObserver:self
           forKeyPath:keySwipeTableViewContentOffset
              options:NSKeyValueObservingOptionNew
              context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:keySwipeTableViewContentOffset]) {
        CGPoint offsetPoint = [change[keySwipeTableViewNew] CGPointValue];
        if (CGPointEqualToPoint(offsetPoint, self.targetOffset)) {
            self.endingUpdates = NO;
            self.targetOffset = CGPointZero;
            self.completionHandler (YES);
        }
    }
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    if ([key isEqualToString:keySwipeTableViewContentOffset]) {
        return NO;
    }
    
    return [super automaticallyNotifiesObserversForKey:key];
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    if (self.endingUpdates)[self willChangeValueForKey:keySwipeTableViewContentOffset];
        [super setContentOffset:contentOffset];
    if (self.endingUpdates)[self didChangeValueForKey:keySwipeTableViewContentOffset];
}

#pragma mark - Convience Methods

- (BOOL)tableView:(RKSwipeTableView *)tableView shouldBeginSwipeWithTranslation:(CGPoint)translation allowedDirections:(NSArray *)directions
{
    BOOL allow = fabsf(translation.x) > fabsf(translation.y);
    if (translation.x < 0 && [directions containsObject:@(RKSwipeTablewViewSwipeDirectionLeft)]) {
        return allow;
    }
    if (translation.x > 0 && [directions containsObject:@(RKSwipeTablewViewSwipeDirectionRight)]) {
        return allow;
    }
    return NO;
}

#pragma mark - UIGestureRecognizer Delegate

static CGFloat TableViewDeletingAnimationDuration = 0.5;
//static CGFloat StartingAlpha = 0.75;

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    /* table view has own gesture recognizer so should check */
    if (gestureRecognizer == _recognizer) {
        CGPoint point = [gestureRecognizer locationInView:self];
        NSIndexPath *path = [self indexPathForRowAtPoint:point];
        UIView *cell = [self cellForRowAtIndexPath:path];
        if (!cell) {
            return NO;
        }
        CGPoint translation = [gestureRecognizer translationInView:[cell superview]];
        NSArray *directions = [self.delegate tableView:self allowedSwipingDirectionsForCellAtIndexPath:path];
        return [self tableView:self shouldBeginSwipeWithTranslation:translation allowedDirections:directions];
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return !_animating;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
    static UITableViewCell *cell = nil;
    CGRect frame = CGRectZero;
    CGPoint translation = [recognizer translationInView:self];
    CGFloat maxScale;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [recognizer locationInView:self];
        _activeIndexPath = [self indexPathForRowAtPoint:point];
        cell = [self cellForRowAtIndexPath:_activeIndexPath];
        _accessoryImage.hidden = NO;
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
    
        if (!_animating) {
            self.userInteractionEnabled = NO;
            _recognizer.enabled = NO;
            CGFloat returnDuration = TableViewDeletingAnimationDuration * fabs(translation.x)/ _maxTransition;
            frame = _swipingView.frame;
            [UIView animateWithDuration:returnDuration
                             animations:^{
                                 _swipingView.frame = CGRectMake(0.0f, CGRectGetMinY(frame), CGRectGetWidth(frame), CGRectGetHeight(frame));
                             } completion:^(BOOL finished) {
                                 self.userInteractionEnabled = YES;
                                 recognizer.enabled = YES;
                                 _accessoryImage.hidden = YES;
                             }];
        }
    } else
        if (recognizer.state == UIGestureRecognizerStateChanged){
        RKSwipeTablewViewSwipeDirection direction = (translation.x > 0) ? RKSwipeTablewViewSwipeDirectionRight : RKSwipeTablewViewSwipeDirectionLeft;
        if ([self.dataSource respondsToSelector:@selector(tableView:swipingTriggerWidthCellAtIndexPath:swipingDirection:)]) {
            _maxTransition = [self.dataSource tableView:self swipingTriggerWidthCellAtIndexPath:_activeIndexPath
                                       swipingDirection:direction];
        }
        
        if ([self.dataSource respondsToSelector:@selector(tableView:accessoryImageForCellAtIndexPath:swipingDirection:)]) {
            UIImage *img = [self.dataSource tableView:self accessoryImageForCellAtIndexPath:_activeIndexPath
                                     swipingDirection:direction];
            if (_accessoryImage) {
                [_accessoryImage removeFromSuperview];
                _accessoryImage = nil;
            }
            _accessoryImage = [[UIImageView alloc] initWithImage:img];
        }
        
        if ([self.dataSource respondsToSelector:@selector(tableView:swipingViewForCellAtIndexPath:swipingDirection:)]) {
            _swipingView = [self.dataSource tableView:self swipingViewForCellAtIndexPath:_activeIndexPath
                                     swipingDirection:direction];
        } else {
            _swipingView = cell.contentView;
        }
        
        if ([self.dataSource respondsToSelector:@selector(tableView:backgroundViewForCellAtIndexPath:swipingDirection:)]) {
            self.coloredBackgroundView = [self.dataSource tableView:self backgroundViewForCellAtIndexPath:_activeIndexPath
                                        swipingDirection:direction];
        } else {
            self.coloredBackgroundView = cell.backgroundView;
        }
        
        if ([self.dataSource respondsToSelector:@selector(tableView:backgroundColorForCellAtIndexPath:swipingDirection:)]) {
            _swipingColor =  [self.dataSource tableView:self backgroundColorForCellAtIndexPath:_activeIndexPath
                                       swipingDirection:direction];
        } else {
            _swipingColor = [UIColor whiteColor];
        }
        
        if ([self.dataSource respondsToSelector:@selector(tableView:contentColorForCellAtIndexPath:swipingDirection:)]) {
            _defaultColor =  [self.dataSource tableView:self contentColorForCellAtIndexPath:_activeIndexPath
                                       swipingDirection:direction];
        } else {
            _defaultColor = [UIColor whiteColor];
        }
        
        [self.coloredBackgroundView addSubview:_accessoryImage];
        self.coloredBackgroundView.backgroundColor = _swipingColor;
        
        CGPoint accessoryCenter;
        if (direction == RKSwipeTablewViewSwipeDirectionLeft) {
            accessoryCenter = CGPointMake(CGRectGetWidth(self.coloredBackgroundView.frame) - CGRectGetWidth(_accessoryImage.frame), CGRectGetHeight(self.coloredBackgroundView.frame) /2);
        } else if (direction == RKSwipeTablewViewSwipeDirectionRight) {
            accessoryCenter = CGPointMake(CGRectGetWidth(_accessoryImage.frame), CGRectGetHeight(self.coloredBackgroundView.frame) /2);
        }

        _accessoryImage.center = accessoryCenter;
        _accessoryImage.alpha = 1.0f;
        maxScale = CGRectGetHeight(self.coloredBackgroundView.frame)/CGRectGetHeight(_accessoryImage.frame);

        CGFloat percentage = 1.f;
        if ([self.dataSource respondsToSelector:@selector(tableView:swipingDestinationPercentageInCellAtIndexPath:swipingDirection:)]) {
            percentage = [self.dataSource tableView:self swipingDestinationPercentageInCellAtIndexPath:_activeIndexPath swipingDirection:direction];
        }
        
        if (translation.x > _maxTransition) {
            
            /* direction right */
            _animating = YES;
            self.userInteractionEnabled = NO;
            recognizer.enabled = NO;
            frame = _swipingView.frame;
            CGFloat x = CGRectGetMaxX(frame) * percentage;
            frame = CGRectMake(x, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame));
            CGFloat accessoryMarge = _accessoryImage.frame.origin.x;

            [self performSwipingAnimationInCell:cell inDirection:RKSwipeTablewViewSwipeDirectionRight
                                       duration:0.4f
                               destinationFrame:frame
                    withAccessoryImageTransform:NO
                                  acessoryMarge:-accessoryMarge];

        } else if (fabs(translation.x) > fabs(_maxTransition)) {
            
            /* direction left */
            _animating = YES;
            self.userInteractionEnabled = NO;
            recognizer.enabled = NO; 
            
            frame = _swipingView.frame;
            CGFloat x =  -CGRectGetWidth(frame) * percentage;
            frame = CGRectMake(x, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame));
            CGFloat accessoryMarge = (CGRectGetWidth(frame) - _accessoryImage.frame.origin.x) / 2;

            [self performSwipingAnimationInCell:cell
                                    inDirection:RKSwipeTablewViewSwipeDirectionLeft
                                       duration:0.5f
                               destinationFrame:frame
                    withAccessoryImageTransform:NO
                                  acessoryMarge:accessoryMarge];
        } else {
            frame = _swipingView.frame;
            frame = CGRectMake(translation.x, frame.origin.y, frame.size.width, frame.size.height);
            _swipingView.frame = frame;
        }
    }
}

- (void)performSwipingAnimationInCell:(UITableViewCell *)cell
                          inDirection:(RKSwipeTablewViewSwipeDirection)direction
                             duration:(CGFloat)animationDuration
                     destinationFrame:(CGRect)destinationFrame
          withAccessoryImageTransform:(BOOL)accessoryImageTransform
                        acessoryMarge:(CGFloat)marge
{
    [UIView animateWithDuration:animationDuration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _swipingView.frame = destinationFrame;
                         self.coloredBackgroundView.backgroundColor = _swipingColor;
                         _swipingView.backgroundColor = _swipingColor;
                         _accessoryImage.alpha = 1.0f;
                         if (accessoryImageTransform) {
                             CGAffineTransform scale = CGAffineTransformMakeScale(2.0, 2.0);
                             CGAffineTransform translation = CGAffineTransformMakeTranslation(CGRectGetMinX(destinationFrame) + marge * 3, 0.0f);
                             CGAffineTransform rotate = CGAffineTransformRotate(translation, 360.0f);
                             _accessoryImage.transform = CGAffineTransformConcat(scale, rotate);
                             _accessoryImage.transform = translation;
                         }
                     } completion:^(BOOL finished) {
                         if ([self.delegate respondsToSelector:@selector(tableView:willEndSwipingCell:atIndexPath:inDirection:completionHandler:)]) {
                             [self.delegate tableView:self willEndSwipingCell:cell atIndexPath:_activeIndexPath inDirection:direction
                                    completionHandler:^(BOOL deleteRow) {
                                        //                                        if (!deleteRow) {
                                        [UIView animateWithDuration:(deleteRow) ? 0.0f : animationDuration
                                                         animations:^{
                                                             if (!deleteRow) {
                                                                 _swipingView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(destinationFrame), CGRectGetHeight(destinationFrame));
                                                                 _swipingView.backgroundColor = [UIColor whiteColor];
                                                             }
                                                         } completion:^(BOOL finished) {
                                                             _animating = NO;
                                                             self.userInteractionEnabled = YES;
                                                             _recognizer.enabled = YES;
															 if ([self.delegate respondsToSelector:@selector(tableView:didEndSwipingCell:atIndexPath:inDirection:)]) {
																 [self.delegate tableView:self didEndSwipingCell:cell atIndexPath:_activeIndexPath inDirection:direction];
															 }
                                                             _accessoryImage.hidden = YES;
                                                         }];
                                        
                                    }];
                         }
                     }];
}

@end
