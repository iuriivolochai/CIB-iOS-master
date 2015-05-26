//
//  CBSolicitingTravelViewController.m
//  CIBBoomerang
//
//  Created by Roma on 5/27/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBSolicitingTravelViewController.h"
#import "CBAppearance.h"
#import "CBDateConvertionUtils.h"
#import "CBSolicitingButton.h"
#import "DMCarnet.h"
#import "DMCountry.h"
#import "CBCountryPickerView.h"
#import "DMWaypoint.h"
#import "DMWaypoint+Auxilliary.h"
#import "NSDate+CLRTicks.h"

NSString *const CBSolicitingTravelViewControllerStoryboardId = @"Soliciting Travel Controller";

@interface CBSolicitingTravelViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

/* logo and labels */
@property (weak, nonatomic) IBOutlet UIImageView *logoView;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;

/* buttons */
@property (weak, nonatomic) IBOutlet CBSolicitingButton *countryButton;
@property (weak, nonatomic) IBOutlet CBSolicitingButton *dateButton;
@property (weak, nonatomic) IBOutlet CBSolicitingButton *purposeButton;

@property (strong, nonatomic) CBSolicitingButton *activeButton;

/* bottom bar */
@property (weak, nonatomic) IBOutlet UIView *proceedView;
@property (weak, nonatomic) IBOutlet UIView *continueView;

@property (weak, nonatomic) IBOutlet UILabel *proceedLabel;
@property (weak, nonatomic) IBOutlet UILabel *continueTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;

@property (strong, nonatomic) IBOutlet UIView *bottomPanelView;
@property (strong, nonatomic) UIBarButtonItem *doneButton;
@property (strong, nonatomic) NSMutableArray *countriesArray;

/* auxilliary properties */
@property (strong, nonatomic) DMCountry *country;
@property (strong, nonatomic) NSDate *date;
//@property (assign, nonatomic) BOOL transit;
@property (assign, nonatomic) DMWaypointKind currentKind;

/* visit & transit */
@property (assign, nonatomic) CGRect oldFrame;
@property (weak, nonatomic) IBOutlet UIButton *visitButton;
@property (weak, nonatomic) IBOutlet UIButton *transitButton;

- (IBAction)transitPressed:(id)sender;
- (IBAction)visitPressed:(id)sender;
- (IBAction)dateValueChanged:(id)sender;

- (void)updateContinueButton;

- (void)donePressed:(id)sender;

- (void)showDone;
- (void)hideDone;

- (void)showInputViewForButton:(CBSolicitingButton *)editingButton;
- (void)hideInputViewForButton:(CBSolicitingButton *)editingButton hideDone:(BOOL)hideDone animated:(BOOL)animated;
- (void)hideInputViewForButton:(CBSolicitingButton *)editingButton animated:(BOOL)animated;

@end

@implementation CBSolicitingTravelViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.country        = nil;
    self.currentKind    = DMWaypointKindNone;
    
    [self hideInputViewForButton:self.countryButton animated:NO];
    [self hideInputViewForButton:self.dateButton animated:NO];
    [self hideInputViewForButton:self.purposeButton animated:NO];
    
    [self updateContinueButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setCarnet:(DMCarnet *)carnet
{
    _carnet = carnet;
    self.countriesArray = [[NSMutableArray alloc] initWithArray:[DMCountry countries]];
    
    DMCountry *lastCountry  = ((DMWaypoint *)[_carnet.waypoints lastObject]).country;
    BOOL isUSA              = [lastCountry isUSA];
    
    [self.countriesArray removeObject:lastCountry];
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [self.countriesArray sortUsingDescriptors:@[sorter]];
    
    if (!isUSA) {
        __block DMCountry *usa;
        [self.countriesArray enumerateObjectsWithOptions:(NSEnumerationReverse | NSEnumerationConcurrent)
                                              usingBlock:^(DMCountry *obj, NSUInteger idx, BOOL *stop) {
                                                  if ([obj isUSA]) {
                                                      usa   = obj;
                                                      *stop = YES;
                                                  }
                                              }];
        [self.countriesArray removeObject:usa];
        [self.countriesArray insertObject:usa atIndex:0];
    }
}

- (void)setCountry:(DMCountry *)country
{
    if (_country != country) {
        _country = country;
        self.purposeButton.buttonTitleLabel.text = NSLocalizedString(@"Purpose", nil);
        [self.purposeButton setChecked:NO];
    }
    self.purposeButton.enabled = (country == nil) ? NO : YES;
}

#pragma mark - Configure View

- (void)configureView
{
    [CBAppearance customizeViewController:self
                                withTitle:@"Soliciting Travel"
                     leftBarBarButtonType:CBAppearanceButtonTypeNone
                       rightBarButtonType:CBAppearanceButtonTypeNone];
    
    [self configureButtons];
	
    // cancel button
    UIBarButtonItem *cancelButton;
    
    if ([[UIDevice currentDevice] systemVersionGreaterOrEqual:7.0f]) {
        cancelButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_close.png"]
                                                        style:UIBarButtonItemStylePlain
                                                       target:self
                                                       action:@selector(cancelButtonTapped:)];
    } else {
        cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil)
                                                        style:UIBarButtonItemStyleBordered
                                                       target:self
                                                       action:@selector(cancelButtonTapped:)];
    }
    
	self.navigationItem.leftBarButtonItem = cancelButton;
    
    // done button
    if ([[UIDevice currentDevice] systemVersionGreaterOrEqual:7.0f]) {
        self.doneButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_done.png"] style:UIBarButtonItemStylePlain target:self action:@selector(donePressed:)];
    } else {
        self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed:)];
    }
    
    self.instructionLabel.font          = [CBFontUtils droidSansFontBold:YES ofSize:13.f];
    self.visitButton.titleLabel.font    = [CBFontUtils droidSansFontBold:YES ofSize:15.f];
    self.transitButton.titleLabel.font  = [CBFontUtils droidSansFontBold:YES ofSize:15.f];
    
    
    if ([[UIDevice currentDevice] systemVersionGreaterOrEqual:7.0f]) {
        self.proceedLabel.font = [CBFontUtils droidSansFontBold:NO ofSize:14.f];
        self.continueTextLabel.font         = [CBFontUtils droidSansFontBold:NO ofSize:14.f];
        self.continueButton.titleLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:17.f];
    } else {
        self.proceedLabel.font = [CBFontUtils droidSansFontBold:NO ofSize:13.f];
        self.continueTextLabel.font         = [CBFontUtils droidSansFontBold:NO ofSize:13.f];
        self.continueButton.titleLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:13.f];
        
        [self.continueButton setBackgroundImage:[[UIImage imageNamed:@"Bar-Button-Done"]
                                                 resizableImageWithCapInsets:UIEdgeInsetsMake(0., 7., 0, 7.)]
                                       forState:UIControlStateNormal];
        
        [self.continueButton setBackgroundImage:[[UIImage imageNamed:@"Bar-Button-Disable"]
                                                 resizableImageWithCapInsets:UIEdgeInsetsMake(0., 7., 0, 7.)]
                                       forState:UIControlStateDisabled];
    }
}

- (void)configureButtons
{
    /* date button */
    self.dateButton.accessoryView.image                 = [UIImage imageNamed:@"icon-soliciting-date"];
    self.dateButton.buttonTitleLabel.text               = NSLocalizedString(@"DATE OF DEPARTURE", nil);
    self.dateButton.buttonTitleLabel.minimumFontSize    = 10.f;
    self.dateButton.buttonTitleLabel.lineBreakMode      = NSLineBreakByWordWrapping;
    
    /* country button */
    self.countryButton.accessoryView.image              = [UIImage imageNamed:@"icon-soliciting-country"];
    self.countryButton.buttonTitleLabel.text            = NSLocalizedString(@"CHOOSE COUNTRY", nil);
    self.countryButton.buttonTitleLabel.minimumFontSize = 10.f;
    self.countryButton.buttonTitleLabel.lineBreakMode   = NSLineBreakByWordWrapping;
    
    /* purpose button */
    self.purposeButton.accessoryView.image              = [UIImage imageNamed:@"icon-soliciting-purpose"];
    self.purposeButton.buttonTitleLabel.text            = NSLocalizedString(@"SELECT PURPOSE", nil);
    self.purposeButton.buttonTitleLabel.minimumFontSize = 10.f;
    self.purposeButton.buttonTitleLabel.lineBreakMode   = NSLineBreakByWordWrapping;
    
    /* transit button */
    [self.transitButton setBackgroundImage:[[UIImage imageNamed:@"btn-solicit-right"]
                                            resizableImageWithCapInsets:UIEdgeInsetsMake(5.f, 10.f, 5.f, 10.f)]
                                  forState:UIControlStateNormal];
    /* visit button */
    [self.visitButton setBackgroundImage:[[UIImage imageNamed:@"btn-solicit-left"]
                                          resizableImageWithCapInsets:UIEdgeInsetsMake(5.f, 10.f, 5.f, 10.f)]
                                forState:UIControlStateNormal];
}

#pragma mark - IBActions

- (IBAction)dateButtonTapped:(CBSolicitingButton *)button
{
    if (!self.date) {
        self.date = [NSDate date];
    }
    self.dateButton.buttonTitleLabel.text = [NSString stringWithFormat:@"%@", [CBDateConvertionUtils solicitinViewDisplayDate:self.date]];
    
    //[((UIDatePicker *)button.inputView) setMinimumDate:[NSDate date]];
    DMWaypoint *lastWaypoint  = (DMWaypoint *)[_carnet.waypoints lastObject];
    NSDate *waypointDate = [NSDate dateWithTimeIntervalSinceReferenceDate:lastWaypoint.dateArrival];
    NSDate *today = [NSDate date];
    NSDate *date = [waypointDate compare:today] == NSOrderedDescending ? waypointDate : today;
    [((UIDatePicker *)button.inputView) setMinimumDate:date];
    
    if ([button isEqual:self.activeButton]) {
        [self hideInputViewForButton:button hideDone:YES animated:YES];
        return;
    }
    
    [self showInputViewForButton:button];
}

- (IBAction)countryButtonTapped:(CBSolicitingButton *)button
{
    if ([button isEqual:self.activeButton]) {
        [self hideInputViewForButton:button hideDone:YES animated:YES];
        return;
    }
 
    if (self.country) {
        [((UIPickerView *)button.inputView) selectRow:[self.countriesArray indexOfObject:self.country] inComponent:0 animated:NO];
    }
    else {
        DMCountry *country = self.countriesArray[0];
        self.country = country;
        self.countryButton.buttonTitleLabel.text = country.name;
    }
    
    [self showInputViewForButton:button];
}

- (IBAction)purposeButtonTapped:(CBSolicitingButton *)button
{
    [self updateTransitView];
    if ([button isEqual:self.activeButton]) {
        return;
    }
    
    [self showInputViewForButton:button];
}

- (IBAction)continueButtonTapped:(id)sender
{    
    [DMManager addWaypointForCarnet:self.carnet
                    withCountryIdentifier:self.country.identifier
                      departureDate:[self.date midnightUTC]
                               kind:self.currentKind
                             status:DMWaypointStatusQueued];
    [DMManager logServerAction:DMLoggedActionTypeTravelPlanAdd
                  withComments:[NSString stringWithFormat:@"Added waypoint with country ISO - %@", self.country.identifier]
                     forCarnet:self.carnet];
    [DMManager updateServerForCarnet:self.carnet];
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)cancelButtonTapped:(UIBarButtonItem *)item
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateTransitView
{
    if (self.visitButton.hidden != !self.country.supportsCarnet) {
        self.visitButton.hidden = !self.country.supportsCarnet;
        CGRect frame = self.transitButton.frame;
        self.oldFrame = (self.visitButton.hidden) ? frame : self.oldFrame;
        frame = (self.country.supportsCarnet) ? self.oldFrame :
            CGRectMake(CGRectGetMinX(self.visitButton.frame), CGRectGetMinY(frame), CGRectGetMaxX(frame) - CGRectGetMinX(self.visitButton.frame), CGRectGetHeight(frame));
        self.transitButton.frame = frame;
    }
}

#pragma mark - UIPickerViewDelegate

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 44.f;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    CBCountryPickerView *rowView = [[CBCountryPickerView alloc] initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(pickerView.bounds), 44.f)];
    rowView.country = self.countriesArray[row];
    return rowView;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    DMCountry *country = self.countriesArray[row];
    self.country = country;
    
    self.countryButton.buttonTitleLabel.text = country.name;

    [self updateContinueButton];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.countriesArray count];
}


#pragma mark - IBActions

- (IBAction)transitPressed:(id)sender
{
    self.currentKind = DMWaypointKindTransit;
    
    self.purposeButton.buttonTitleLabel.text = @"Transit";
    [self hideInputViewForButton:self.purposeButton animated:YES];
    
    [self updateContinueButton];
}

- (IBAction)visitPressed:(id)sender
{
    self.currentKind = DMWaypointKindVisit;
    
    self.purposeButton.buttonTitleLabel.text = @"Visit";
    [self hideInputViewForButton:self.purposeButton animated:YES];
    
    [self updateContinueButton];
}

- (IBAction)dateValueChanged:(id)sender
{
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    self.date = datePicker.date;
    self.dateButton.buttonTitleLabel.text = [NSString stringWithFormat:@"%@", [CBDateConvertionUtils solicitinViewDisplayDate:self.date]];
    
    [self updateContinueButton];
}

#pragma mark - Private

- (void)donePressed:(id)sender
{
    self.purposeButton.enabled = ![self.country isUSA];
    
    if ([self.country isUSA]) {
        self.currentKind = DMWaypointKindVisit;
    }
    
    [self hideInputViewForButton:self.activeButton animated:YES];
}

- (void)showDone
{
    [self.navigationItem setRightBarButtonItem:self.doneButton animated:YES];
}

- (void)hideDone
{
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
}

- (void)showInputViewForButton:(CBSolicitingButton *)editingButton
{
    if (self.activeButton) {
        [self hideInputViewForButton:self.activeButton hideDone:NO animated:YES];
    } else {
        if (editingButton != self.purposeButton) [self showDone];
    }
    
    self.activeButton = editingButton;
    [editingButton rotateAccessoryDown:YES];
    [editingButton setChecked:NO];
    
    UIView *inputView = editingButton.inputView;
    inputView.backgroundColor = [UIColor whiteColor];
    
    CGFloat totalDuration = 0.4;
    CGFloat inputTop = self.view.frame.size.height - self.bottomPanelView.frame.size.height - inputView.frame.size.height;
    CGFloat totalHeight = inputView.frame.origin.y - inputTop;
    CGFloat firstHeight = totalHeight - (editingButton.frame.origin.y + editingButton.frame.size.height - inputTop);
    
    CGFloat firstDuration = (CGFloat) firstHeight / totalHeight * totalDuration;
    
    [UIView animateWithDuration:firstDuration
                     animations:^{
                         inputView.frame = CGRectMake(0,
                                                      editingButton.frame.origin.y + editingButton.frame.size.height,
                                                      inputView.frame.size.width,
                                                      inputView.frame.size.height);
                     } completion:^(BOOL finished) {
                         if (finished) {
                             
                             [UIView animateWithDuration:(totalDuration - firstDuration) animations:^{
                                 
                                 editingButton.frame = CGRectMake(editingButton.frame.origin.x, inputTop - editingButton.frame.size.height, editingButton.frame.size.width, editingButton.frame.size.height);
                                 
                                 inputView.frame = CGRectMake(0,
                                                              inputTop,
                                                              inputView.frame.size.width,
                                                              inputView.frame.size.height);
                             }];
                         }
                     }];
}

- (void)hideInputViewForButton:(CBSolicitingButton *)editingButton hideDone:(BOOL)hideDone animated:(BOOL)animated
{
    if (hideDone) {
        [self hideDone];
    }
    
    self.activeButton = nil;
    [editingButton rotateAccessoryDown:NO];
    
    UIView *inputView = editingButton.inputView;
    
    CGRect targetRect = CGRectMake(0,
                                   self.view.frame.size.height - 44,
                                   inputView.frame.size.width,
                                   inputView.frame.size.height);
    
    CGFloat cellTop = 0;
    
    if ([editingButton isEqual:self.countryButton]) {
        cellTop = self.dateButton.frame.origin.y + self.dateButton.frame.size.height;
    } else if ([editingButton isEqual:self.dateButton]) {
        cellTop = self.countryButton.frame.origin.y - self.dateButton.frame.size.height;
    } else if ([editingButton isEqual:self.purposeButton]) {
        cellTop = self.countryButton.frame.origin.y + self.dateButton.frame.size.height;
    }
    
    if (animated) {
        CGFloat totalDuration = 0.5;
        
        CGFloat totalHeight = targetRect.origin.y - inputView.frame.origin.y;
        CGFloat firstHeight = cellTop - editingButton.frame.origin.y;
        
        CGFloat firstDuration = (CGFloat) firstHeight / totalHeight * totalDuration;
        
        [UIView animateWithDuration:firstDuration
                         animations:^{
                             editingButton.frame = CGRectMake(editingButton.frame.origin.x,
                                                              cellTop,
                                                              editingButton.frame.size.width,
                                                              editingButton.frame.size.height);
                             
                             inputView.frame = CGRectMake(inputView.frame.origin.x,
                                                          cellTop + editingButton.frame.size.height,
                                                          inputView.frame.size.width,
                                                          inputView.frame.size.height);
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 [UIView animateWithDuration:(totalDuration - firstDuration)
                                                  animations:^{
                                                      inputView.frame = targetRect;
                                                  }completion:^(BOOL finished) {
                                                      [editingButton setChecked:YES];
                                                      [self updateContinueButton];
                                                  }];
                             }
                         }];
    } else {
        editingButton.frame = CGRectMake(editingButton.frame.origin.x,
                                         cellTop,
                                         editingButton.frame.size.width,
                                         editingButton.frame.size.height);
        inputView.frame = targetRect;
    }
}

- (void)hideInputViewForButton:(CBSolicitingButton *)editingButton animated:(BOOL)animated
{
    [self hideInputViewForButton:editingButton hideDone:YES animated:animated];
}

- (void)updateContinueButton
{
    BOOL shouldShowContinueView = ((self.countryButton.isChecked && self.dateButton.isChecked && self.purposeButton.isChecked)
                                   || ([self.country isUSA] && self.countryButton.isChecked && self.dateButton.isChecked));
    
    BOOL continueViewIsVisible = (self.continueView.frame.origin.y == 0.0f);
    
    if (shouldShowContinueView != continueViewIsVisible) {
        CGRect frame = self.bottomPanelView.bounds;
        CGFloat proceedViewOrigin = (continueViewIsVisible) ? CGRectGetMinY(frame) : - CGRectGetHeight(frame);
        CGFloat continueViewOrigin = (continueViewIsVisible) ? CGRectGetHeight(frame) : CGRectGetMinY(frame);
        self.bottomPanelView.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.2
                         animations:^{
                             self.continueView.frame = CGRectMake(0.0f, continueViewOrigin, CGRectGetWidth(frame), CGRectGetHeight(frame));
                             self.continueView.alpha = (continueViewIsVisible) ? 0.0f : 1.f;
                             self.proceedView.frame = CGRectMake(0.0f, proceedViewOrigin, CGRectGetWidth(frame), CGRectGetHeight(frame));
                             self.proceedView.alpha = (continueViewIsVisible) ? 1.0f : 0.f;
                         } completion:^(BOOL finished) {
                                 self.bottomPanelView.userInteractionEnabled = YES;
                         }];
    }
}

@end
