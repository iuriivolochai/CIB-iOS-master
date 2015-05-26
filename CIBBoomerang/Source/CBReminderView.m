//
//  CBReminderView.m
//  CIBBoomerang
//
//  Created by Roma on 8/1/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBReminderView.h"

#define     MULTIPLIER_DAY      1
#define     MULTIPLIER_WEEK     7
#define     MULTIPLIER_MONTH    30

@interface CBReminderView () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIPickerView *reminderPicker;
@property (weak, nonatomic) IBOutlet UIView *animatedView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UIToolbar *pickerToolbar;

@property (strong, nonatomic) NSArray *firstComponent;
@property (strong, nonatomic) NSArray *secondComponent;

@end

@implementation CBReminderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configureView];
    }
    return self;
}

#pragma mark - View configuration

- (void)configureView
{
    [self loadFromNib];
    [self configureButtonsAndLabels];
}

- (void)loadFromNib
{
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                  owner:self
                                options:nil];
    [self addSubview:self.contentView];
}

- (void)configureButtonsAndLabels
{
    UIBarButtonItem *doneBtn;
    
    if ([[UIDevice currentDevice] systemVersionGreaterOrEqual:7.0f]) {
        doneBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_done.png"] style:UIBarButtonItemStylePlain target:self action:@selector(pickerDoneButtonTapped:)];
    } else {
        doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                 target:self
                                                                                 action:@selector(pickerDoneButtonTapped:)];
        [doneBtn setTitle:NSLocalizedString(@"Done", nil)];
    }
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:nil
                                                                               action:nil];
    CGRect toolbarFrame = self.pickerToolbar.frame;
    UILabel *toolbarLbl = [[UILabel alloc] initWithFrame:CGRectMake(5.f, 0.f, 200.f, CGRectGetHeight(toolbarFrame))];
    toolbarLbl.text = NSLocalizedString(@"Ask me again in...", nil);
    
    if ([[UIDevice currentDevice] systemVersionGreaterOrEqual:7.0f]) {
        toolbarLbl.font = [CBFontUtils droidSansFontBold:NO ofSize:17.f];
    } else {
        toolbarLbl.font = [CBFontUtils droidSansFontBold:YES ofSize:14.f];
    }
    
    toolbarLbl.minimumFontSize = 8;
    toolbarLbl.numberOfLines = 1;
    
    if ([[UIDevice currentDevice] systemVersionGreaterOrEqual:7.0f]) {
        toolbarLbl.textColor = [UIColor colorWithRed:0.57f green:0.57f blue:0.57f alpha:1];
    } else {
        toolbarLbl.textColor = [UIColor whiteColor];
    }
    
    toolbarLbl.textAlignment = NSTextAlignmentLeft;
    toolbarLbl.backgroundColor = [UIColor clearColor];
    UIBarButtonItem *lblButton = [[UIBarButtonItem alloc] initWithCustomView:toolbarLbl];
    
    [self.pickerToolbar setItems:@[lblButton, flexSpace, doneBtn]];
    
    
    self.firstComponent = @[@2,@3,@4,@5,@6,@7,@8,@9,@10];
    self.secondComponent = @[NSLocalizedString(@"Days", nil), NSLocalizedString(@"Weeks",nil), NSLocalizedString(@"Months",nil)];
    
    self.reminderPicker.delegate = self;
    self.reminderPicker.dataSource = self;
    
    [self setHidden:YES animated:NO animationCompletionBlock:nil];
}

#pragma mark - Public

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated animationCompletionBlock:(void (^)(BOOL completed))completionHandler
{
    CGRect frame = CGRectZero;
    
    if (!hidden)
        self.hidden = NO;
    
    if (hidden)
        frame = CGRectMake(0.f,
                           CGRectGetHeight(self.bounds),
                           CGRectGetWidth(self.animatedView.bounds),
                           CGRectGetHeight(self.animatedView.bounds));
    else
        frame = CGRectMake(0.f,
                           CGRectGetHeight(self.superview.bounds) - CGRectGetHeight(self.animatedView.bounds),
                           CGRectGetWidth(self.animatedView.bounds),
                           CGRectGetHeight(self.animatedView.bounds));

    
    CGFloat overlayAlpha = (hidden) ? 0.0f : 0.4f;
        
    [UIView animateWithDuration:(animated) ? 0.4f : 0.0f
                     animations:^{
                         self.animatedView.frame = frame;
                         self.overlayView.alpha = overlayAlpha;
                     } completion:^(BOOL finished) {
                         self.hidden = hidden;
                         if (completionHandler)
                             completionHandler (YES);
                     }];
}

#pragma mark - Private

- (void)pickerDoneButtonTapped:(UIBarButtonItem *)sender
{
    //trlala
    int firstComponent = [[self.firstComponent objectAtIndex:[self.reminderPicker selectedRowInComponent:0]] integerValue];
    int secondIndex = [self.reminderPicker selectedRowInComponent:1];
    
    int muliplier = MULTIPLIER_DAY;
    switch (secondIndex) {
        case 1: {
            muliplier = MULTIPLIER_WEEK;
        }
            break;
        case 2: {
            muliplier = MULTIPLIER_MONTH;
        }
            break;
        default:
            break;
    }
    
    NSUInteger daysCount = firstComponent * muliplier;
    
    [self.delegate reminderView:self willHideWithDaysIntervalSelected:daysCount];
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        return [self.firstComponent [row] stringValue];
    }
    return self.secondComponent [row];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return self.firstComponent.count;
    }
    return self.secondComponent.count;
}


@end
