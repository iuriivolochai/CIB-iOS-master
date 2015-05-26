//
//  CBCarnetDetailsViewController.m
//  CIBBoomerang
//
//  Created by Roma on 5/10/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBCarnetDetailsViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#import "CBAlertsListView.h"
#import "CBAlertView.h"
#import "CBAlertsSettingsUtil.h"
#import "CBAppearance.h"
#import "CBCarnetView.h"
#import "CBCarnetStatisticView.h"
#import "CBCarnetImageStatusUtils.h"
#import "CBCountriesListAlert.h"
#import "CBCountriesRouteView.h"
#import "CBDateConvertionUtils.h"
#import "CBItemTableViewCell.h"
#import "CBRoundUpUtils.h"
#import "CBReminderView.h"
#import "CBScannerViewController.h"
#import "CBSolicitingTravelViewController.h"
#import "CBSplitBar.h"

#import "DMWaypoint.h"
#import "DMWaypoint+Auxilliary.h"
#import "DMCheckpointAlert.h"

#import "CBNewAlertListView.h"
#import "RKSwipeTableView.h"

#define ROUTE_VIEW_HEIGHT               100
#define ITEM_CELL_HEIGHT                42
#define ITEM_DESCRIPTION_HEIGHT         184
#define ITEM_DESCRIPTION_SPLIT_HEIGHT   50
#define SECTION_HEADER_HEIGHT           16.f

#define SEGUE_SHOW_SOLICITING_CONTROLLER @"Show Soliciting Screen"
#define SEGUE_SHOW_SCANNER_VIEW_CONTROLLER @"Show Scanner View Controller From Details Controller"


#pragma mark -
#pragma mark - NSIndexPath+Identifier

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface NSIndexPath (Identifier)

- (NSString *)cb_identifier;

@end

@implementation NSIndexPath (Identifier)

- (NSString *)cb_identifier
{
    return [NSString stringWithFormat:@"%d %d", self.section, self.row];
}

@end

#pragma mark -
#pragma mark -

typedef NS_ENUM(int16_t, CBCarnetDetailsViewControllerMode) {
    CBCarnetDetailsViewControllerMode_Normal = 0,
    CBCarnetDetailsViewControllerMode_Verify,
    CBCarnetDetailsViewControllerMode_SimpleAlert,
    CBCarnetDetailsViewControllerMode_LocationAlert,
    CBCarnetDetailsViewControllerMode_Popovers,
    CBCarnetDetailsViewControllerMode_Split
};

NSString *const CarnetDetailsViewControllerStoryboardId = @"Carnet Details View Controller";

@interface CBCarnetDetailsViewController () <   CBCountriesRouteViewDelegate,       CBCountriesRouteViewDataSource,
                                                CBReminderViewDelegate,             CBScannerViewControllerDelegate,
                                                RKSwipeTableViewDataSource,         RKSwipeTableViewDelegate,
                                                NSFetchedResultsControllerDelegate, CBNewAlertListViewDataSource,
                                                CBNewAlertListViewDelegate,         CBSplitBarDelegate  >


@property (weak, nonatomic) IBOutlet    UIView                  *tableViewHeader;
@property (weak, nonatomic) IBOutlet    RKSwipeTableView        *tableView;

@property (weak, nonatomic) IBOutlet    CBNewAlertListView      *simpleAlertsView;
@property (weak, nonatomic) IBOutlet    CBCountriesRouteView    *countriesRouteView;
@property (weak, nonatomic) IBOutlet    CBCarnetStatisticView   *statisticView;
@property (weak, nonatomic) IBOutlet    CBCarnetView            *carnetView;
@property (weak, nonatomic) IBOutlet    CBReminderView          *reminderPicker;
@property (weak, nonatomic) IBOutlet    CBSplitBar              *splitView;

@property (strong, nonatomic)           CBCountriesListAlert    *countriesAlert;

@property (strong, nonatomic) NSMutableSet *indexes;

/* alerts */
@property (strong, nonatomic) NSMutableArray *simpleAlertsArray;
@property (strong, nonatomic) NSMutableArray *simplePopoversArray;

@property (strong, nonatomic) NSMutableArray *locationAlertsArray;
@property (strong, nonatomic) NSMutableArray *locationPopoversArray;

/* instructions alert */
@property (strong, nonatomic) NSMutableArray *instructionsArray;

/* mode */
@property (assign, nonatomic) CBCarnetDetailsViewControllerMode mode;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) DMLocationAlert *currentAlert;
@property (strong, nonatomic) DMCheckpointAlert *chCurrentAlert;

// for iOS 7
@property (nonatomic, strong) UIBarButtonItem *backButton;

@end

@implementation CBCarnetDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	[self addNotificationObserver];
    [self configureView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshView];
}

#pragma mark - Override Methods

- (void)showScanViewController
{
    [self performSegueWithIdentifier:SEGUE_SHOW_SCANNER_VIEW_CONTROLLER sender:nil];
}

- (void)showReminderPicker
{
    [self.reminderPicker setHidden:NO animated:YES animationCompletionBlock:nil];
}

- (void)showTravelDetailsScreen
{
    [self performSegueWithIdentifier:SEGUE_SHOW_SOLICITING_CONTROLLER sender:self.carnet];
}

- (void)showPopoverAlerts
{
    NSArray *simplePopovers = [self.carnet getPopoversArray];
    NSInteger popoversCount = simplePopovers.count;
    
    if (!popoversCount)
        simplePopovers = self.locationPopoversArray;
    
    popoversCount = simplePopovers.count;
    if (!popoversCount)
        return;
    
    id anAlert = simplePopovers[0];
    [self showAlert:anAlert];
}

- (void)showAlert:(id <CBAlertObjectProtocol>)anAlert
{
        NSString *cancelButtonTitle =  [CBAlertsSettingsUtil alertButtonsSettings:[[anAlert alertButtons][0] integerValue] alertPriority:0] [keyButtonText];
        NSMutableArray *otherButtons;
        int count = [anAlert alertButtons].count;
        if (count > 1) {
            otherButtons = [[NSMutableArray alloc] initWithCapacity: count - 1];
            for (int i = 1; i < count; ++i) {
                NSString *buttonTitle =  [CBAlertsSettingsUtil alertButtonsSettings:[[anAlert alertButtons][i] integerValue] alertPriority:0] [keyButtonText];
                [otherButtons addObject:buttonTitle];
            }
        }

        [CBAlertView showAlertViewWithTitle:nil
                                    message:[anAlert alertText]
                          cancelButtonTitle:cancelButtonTitle
                          otherButtonTitles:otherButtons
                                 completion:^(CBAlertView *sender, NSUInteger buttonIndex)
         {
             BOOL simpleAlert       = [anAlert isKindOfClass:[DMSimpleAlert class]];
             CBAlertButtonType type = [[anAlert alertButtons][buttonIndex] integerValue];
             DMManagerAlertHandlingAction anAction;
             if (simpleAlert)
                 anAction  = [DMManager handlingActionForSimpleAlertWithType:[anAlert alertType]
                                                               buttonPressed:type
                                                                   forCarnet:self.carnet];
             else
                 anAction = [DMManager handleButtonWithTypeTapped:type
                                         forLocationAlertWithType:[anAlert alertType]
                                                       atWaypoint:self.carnet.activeWaypoint
                                                       fromCarnet:self.carnet];
             [self handleManagerAction:anAction];
             [self refreshView];
         }];
}

#pragma mark - Notifications

- (void)addNotificationObserver
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(notificationReceived:)
												 name:DMNotificationTypeLocationError
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(notificationReceived:)
												 name:DMNotificationTypeLocationServicesDisabled
											   object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willYouBeTravellingNotificationRecieved:)
                                                 name:DMNotificationTypeWillYouBeTravellingSoon
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(instructionsReceived:)
                                                 name:DMNotificationTypeAirportInsctructionsReceived
                                               object:nil];
}

- (void)notificationReceived:(NSNotification *)notification
{
	[CBAlertView showAlertViewWithTitle:notification.userInfo [keyDMNotificationHeader]
								message:notification.userInfo [keyDMNotificationText]
					  cancelButtonTitle:NSLocalizedString(@"Ok",  nil)
					  otherButtonTitles:nil
							 completion:nil];
}

- (void)willYouBeTravellingNotificationRecieved:(NSNotification *)notification
{
    [CBAlertView showAlertViewWithTitle:nil
                                message:NSLocalizedString(@"Will you be travelling soon?", nil)
                      cancelButtonTitle:NSLocalizedString(@"NO", nil)
                      otherButtonTitles:@[NSLocalizedString(@"YES", nil)]
                             completion:^(CBAlertView *sender, NSUInteger buttonIndex) {
                                 if (buttonIndex != [CBAlertView cancelButtonIndex]) {
//                                     [DMManager startTravelDayWorkflow];
                                     [self refreshView];
                                 }
                             }];
}

- (void)instructionsReceived:(NSNotification *)notification
{
    [self.instructionsArray addObjectsFromArray:notification.userInfo [keyDMNotificationInstructions]];
    [self recalculateMode];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View Configuration

- (void)configureView
{
    // set back button and title
    if ([[UIDevice currentDevice] systemVersionGreaterOrEqual:7.0f]) {
        self.title = NSLocalizedString(@"Settings", nil);
        
        self.backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.leftBarButtonItem = self.backButton;
    } else {
        [CBAppearance customizeViewController:self
                                    withTitle:NSLocalizedString(@"Settings", nil)
                         leftBarBarButtonType:CBAppearanceButtonTypeBack
                           rightBarButtonType:CBAppearanceButtonTypeNone];
    }
    
    // set help button
    UIBarButtonItem *helpBtn;
    
    if ([[UIDevice currentDevice] systemVersionGreaterOrEqual:7.0f]) {
        helpBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_help.png"]
                                                   style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(helpButtonTapped:)];
    } else {
        helpBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Help", nil)
                                                   style:UIBarButtonItemStyleDone
                                                  target:self
                                                  action:@selector(helpButtonTapped:)];
    }
    
    self.navigationItem.rightBarButtonItem = helpBtn;
    
    self.tableView.tableHeaderView = self.tableViewHeader;
    
    [CBAppearance customizeViewController:self
                                withTitle:NSLocalizedString(@"Carnet Details", nil)
                     leftBarBarButtonType:CBAppearanceButtonTypeNone
                       rightBarButtonType:CBAppearanceButtonTypeNone];
    
	/* splitting view */
	
	CGRect frame = self.splitView.frame;
	frame.origin.y = CGRectGetMaxY(self.view.frame);
	self.splitView.frame = frame;
    self.splitView.delegate = self;
    
    self.simpleAlertsView.delegate = self;
    self.simpleAlertsView.dataSource = self;
}

- (void)refreshView
{
    [self.carnet refreshCarnetStatus];
    
    self.carnetView.carnet = self.carnet;
    [self.carnetView refreshView];
    
    self.statisticView.carnet = self.carnet;
    [self.statisticView refreshView];
	
    if([[UIDevice currentDevice] systemVersionGreaterOrEqual: 8.0]) //change due size of iphone 6/6plus
    {
        [self.countriesRouteView setFrame: CGRectMake(0,
                                                  CGRectGetMinY(self.countriesRouteView.frame),
                                                  self.view.frame.size.width,
                                                      CGRectGetHeight(self.countriesRouteView.frame))];
    }
    
    [self.countriesRouteView reloadData];
    [self.tableView reloadData];
    [self recalculateMode];
    
}

- (void)recalculateMode
{
    if (self.simpleAlertsArray.count)
        [self.simpleAlertsArray removeAllObjects];
    
    [self.simpleAlertsArray addObjectsFromArray:[self.carnet getAlertsArray]];
    [self.simpleAlertsArray addObjectsFromArray:[self.carnet informationAlerts]];
    
    DDLogVerbose(@"%d alerts count", self.simpleAlertsArray.count);

    if (self.locationPopoversArray)
        [self.locationPopoversArray removeAllObjects];
    
    [self.locationPopoversArray addObjectsFromArray:[self.carnet.activeWaypoint popoversAlerts]];
    
    if ([self shouldShowVerifyAlert]) {
        self.mode = CBCarnetDetailsViewControllerMode_Verify;
    }
    else
        if ([self shouldShowSimpleAlert]) {
            self.mode = CBCarnetDetailsViewControllerMode_SimpleAlert;
        }
        else
            if ([self shouldShowLocationPopover]) {
                self.mode = CBCarnetDetailsViewControllerMode_Popovers;
            }
            else
                if ([self shouldShowLocationAlert]) {
                    self.mode = CBCarnetDetailsViewControllerMode_LocationAlert;
                }
                else
                    self.mode = CBCarnetDetailsViewControllerMode_Normal;
}

#pragma mark - Alerts View

- (void)setAlertView:(UIView *)alertView hidden:(BOOL)hidden animated:(BOOL)animated completion:(CBSimpleCompletionBlock)completionBlock
{
    CGRect frame = alertView.frame;
    CGFloat tableY = (CGRectGetMaxY(self.countriesRouteView.frame));
    
    CGRect tableViewFrame = (hidden) ? CGRectMake(0.f, tableY, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(self.view.frame) - tableY)
                                     : CGRectMake(0.f, CGRectGetMaxY(frame), CGRectGetWidth(self.tableView.frame),CGRectGetHeight(self.view.bounds) -  CGRectGetMaxY(frame));
    self.view.userInteractionEnabled = NO;
    alertView.hidden = hidden;
    [UIView animateWithDuration: (animated) ? 0.5f : 0.f
                     animations:^{
                         self.tableView.frame = tableViewFrame;
                     } completion:^(BOOL finished) {
                         self.view.userInteractionEnabled = YES;
                         if (completionBlock) completionBlock (hidden);
                     }];
}

- (BOOL)shouldShowVerifyAlert
{
    return (self.carnet.flagVerified == NO);
}

- (BOOL)shouldShowSimpleAlert
{
    return (self.simpleAlertsArray.count != 0);
}

- (BOOL)shouldShowLocationPopover
{
    return (self.locationPopoversArray.count != 0);
}

- (BOOL)shouldShowLocationAlert
{
    return [self.carnet containsLocationAlerts];
}

- (BOOL)shouldShowInstrucionsAlert
{
    return (self.instructionsArray.count);
}

#pragma mark Setters && Getters

- (void)setMode:(CBCarnetDetailsViewControllerMode)mode
{
    if (_mode == CBCarnetDetailsViewControllerMode_LocationAlert) {
        [self.countriesRouteView reloadData];
    }
        _mode = mode;
        switch (mode) {
            case CBCarnetDetailsViewControllerMode_Popovers: {
                if (!self.simpleAlertsView.hidden) {
                    __weak CBCarnetDetailsViewController *weakself = self;
                    [self setAlertView:self.simpleAlertsView hidden:YES animated:YES completion:^(BOOL completed) {
                        [weakself showPopoverAlerts];
                    }];
                }
                else {
                    [self showPopoverAlerts];
                }
            }
                break;
            case CBCarnetDetailsViewControllerMode_Normal: {
                if (!self.simpleAlertsView.hidden)
                    [self setAlertView:self.simpleAlertsView hidden:YES animated:NO completion:nil];
                
                [self.countriesRouteView reloadData];

                [self setAlertView:self.countriesRouteView hidden:NO animated:YES completion:nil];
                
                [self setHidesBackButton:NO animated:YES];
            }
                break;
            case CBCarnetDetailsViewControllerMode_Verify: {
				if (!self.countriesRouteView.hidden)
					[self setAlertView:self.countriesRouteView hidden:YES animated:NO completion:nil];

                [self.simpleAlertsView reloadData];
                
                if (self.simpleAlertsView.hidden)
                    [self setAlertView:self.simpleAlertsView hidden:NO animated:YES completion:nil];
                [self setHidesBackButton:YES animated:YES];
            }
                break;
            case CBCarnetDetailsViewControllerMode_Split: {
                [self setHidesBackButton:NO animated:YES];
            }
                break;
            case CBCarnetDetailsViewControllerMode_SimpleAlert: {
				if (!self.countriesRouteView.hidden)
					[self setAlertView:self.countriesRouteView hidden:YES animated:NO completion:nil];

                [self.simpleAlertsView reloadData];

                if (self.simpleAlertsView.hidden)
                    [self setAlertView:self.simpleAlertsView hidden:NO animated:YES completion:nil];

                [self setHidesBackButton:NO animated:YES];
            }
                break;
            case CBCarnetDetailsViewControllerMode_LocationAlert: {
                    __weak CBCarnetDetailsViewController *weakself = self;
                [self setAlertView:self.simpleAlertsView hidden:YES animated:NO completion:^(BOOL completed) {
                    [weakself setAlertView:weakself.countriesRouteView hidden:NO animated:YES completion:nil];
                }];
                [self setHidesBackButton:NO animated:YES];
            }
                break;
        }
}

//#pragma mark - Popovers Showing
//
//- (void)showPopoverAlert
//{
//    id alert = [self.locationPopoversArray objectAtIndex:0];
//    NSString *cancelButtonTitle =  [CBAlertsSettingsUtil alertButtonsSettings:[[alert alertButtons][0] integerValue] alertPriority:0] [keyButtonText];
//    NSMutableArray *otherButtons;
//    int count = [alert alertButtons].count;
//    if (count > 1) {
//        otherButtons = [[NSMutableArray alloc] initWithCapacity: count - 1];
//        for (int i = 1; i < count; ++i) {
//            NSString *buttonTitle =  [CBAlertsSettingsUtil alertButtonsSettings:[[alert alertButtons][i] integerValue] alertPriority:0] [keyButtonText];
//            [otherButtons addObject:buttonTitle];
//        }
//    }
//    
//    [CBAlertView showAlertViewWithTitle:nil
//                                message:[alert alertText]
//                      cancelButtonTitle:cancelButtonTitle
//                      otherButtonTitles:otherButtons
//                             completion:^(CBAlertView *sender, NSUInteger buttonIndex)
//                        {
//                                     [DMManager setCarnet:self.carnet active:(buttonIndex != [CBAlertView cancelButtonIndex])];
//                      }];
//}

#pragma mark - Actions

- (void)backButtonTapped:(UIButton *)backBtn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)helpButtonTapped:(UIBarButtonItem *)button
{
    [self.navigationController performSegueWithIdentifier:SEGUE_SHOW_HELP sender:self];
}

#pragma mark - Splitting View

- (void)setSplitingViewHidden:(BOOL)hidden animated:(BOOL)animated
{
	CGRect frame = self.splitView.frame;
	BOOL alreadyHidden = (CGRectGetMinY(frame) >= CGRectGetMaxY(self.view.bounds));
	if (hidden != alreadyHidden) {
		CGRect newTableFrame = self.tableView.frame;
		
		newTableFrame.size.height = (!hidden)	? (CGRectGetHeight(newTableFrame) - CGRectGetHeight(frame))
		: (CGRectGetHeight(self.view.bounds) - CGRectGetMinY(newTableFrame));
		
		frame = (!hidden)	? CGRectMake(0.0, CGRectGetHeight(self.view.bounds) - CGRectGetHeight(frame), CGRectGetWidth(frame), CGRectGetHeight(frame))
		: CGRectMake(0.0, CGRectGetHeight(self.view.bounds), CGRectGetWidth(frame), CGRectGetHeight(frame));
		
		[UIView animateWithDuration:(animated) ? 0.3 : 0.0
						 animations:^{
							 self.splitView.frame = frame;
							 self.tableView.frame = newTableFrame;
						 }];
	}
}

#pragma mark - SEGUES

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:SEGUE_SHOW_SOLICITING_CONTROLLER]) {
        /* he-he refactor this crap*/
        ((CBSolicitingTravelViewController *)((UINavigationController *)[segue destinationViewController]).visibleViewController).carnet = self.carnet;
    }
    else if ([segue.identifier isEqualToString:SEGUE_SHOW_SCANNER_VIEW_CONTROLLER]) {
        ((CBScannerViewController *)[segue destinationViewController]).delegate = self;
    }
}

#pragma mark - RKSwipeTableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    CBItemTableViewCell *cell = (CBItemTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (!cell.detailsVisible) {
        [self.indexes addObject:[indexPath cb_identifier]];
    }
    else {
        [self.indexes removeObject:[indexPath cb_identifier]];
    }
    
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [cell setDetailsVisible:!cell.detailsVisible completion:^(BOOL completed) {
        [tableView beginUpdates];
        [tableView endUpdates];
    }];
}

- (void)tableView:(RKSwipeTableView *)tableView willEndSwipingCell:(UITableViewCell *)cell
      atIndexPath:(NSIndexPath *)indexPath
      inDirection:(RKSwipeTablewViewSwipeDirection)swipeDirection
completionHandler:(RKSwipeTableViewCompletionHandler)completion
{
    completion (NO);
}

- (void)tableView:(RKSwipeTableView *)tableView didEndSwipingCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath inDirection:(RKSwipeTablewViewSwipeDirection)swipeDirection
{
    DMItem *item = ((CBItemTableViewCell *)cell).item;
    if ([item splitted]) {
        [(CBItemTableViewCell *)cell setSplitted:NO];
        [DMManager reconstituteCarnets:self.carnet
                                  item:item atWaypoint:self.carnet.activeWaypoint
                     completionHandler:^(BOOL completed)
        {
			[self setSplitingViewHidden:completed animated:YES];
		}];
    }
    else {
        [(CBItemTableViewCell *)cell setSplitted:YES];
        [DMManager splitCarnets:self.carnet item:item
                     atWaypoint:self.carnet.activeWaypoint
			  completionHandler:^(BOOL completed)
         {
			[self setSplitingViewHidden:completed animated:YES];
		}];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat retval;
    if ([self.indexes containsObject:[indexPath cb_identifier]]) {
        if (indexPath.section == 0)
            retval = (ITEM_DESCRIPTION_HEIGHT - ITEM_DESCRIPTION_SPLIT_HEIGHT +
                      [self descriptionHeightForSpecification:((DMItem *)[self.fetchedResultsController objectAtIndexPath:indexPath]).specification]);
        else
            retval = (ITEM_DESCRIPTION_HEIGHT + [self descriptionHeightForSpecification:((DMItem *)[self.fetchedResultsController objectAtIndexPath:indexPath]).specification]);
        return retval;
    }
    return ITEM_CELL_HEIGHT;
}

- (CGFloat)descriptionHeightForSpecification:(NSString *)specification
{
    CGSize maximumLabelSize = CGSizeMake(kItemSpecificationWidth, 9999);
    
    CGSize expectedTitleLabelSize = [specification sizeWithFont:[CBFontUtils droidSansFontBold:NO ofSize:12.f]
                                              constrainedToSize:maximumLabelSize
                                                  lineBreakMode:NSLineBreakByWordWrapping];
    return expectedTitleLabelSize.height;
}

- (NSArray *)tableView:(RKSwipeTableView *)tableView allowedSwipingDirectionsForCellAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL directionLocked = NO;
    CBItemTableViewCell *cell = (CBItemTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    directionLocked = !cell.detailsVisible && (self.mode == CBCarnetDetailsViewControllerMode_Normal
											   || self.mode == CBCarnetDetailsViewControllerMode_Split) && (self.carnet.items.count > 1);
    return (directionLocked) ? @[@(RKSwipeTablewViewSwipeDirectionRight)] : nil;
}

#pragma mark - RKSwipeTableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *retArray = [self.fetchedResultsController sections];
    return retArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? 0.f : SECTION_HEADER_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *retView;
    if (section != 0) {
        retView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, SECTION_HEADER_HEIGHT)];
        UIImageView *bg = [[UIImageView alloc] initWithFrame:retView.bounds];
        bg.image = [UIImage imageNamed:@"bg-details-table-section-header"];
        [retView addSubview:bg];
        
        UILabel *sectionLbl = [[UILabel alloc] initWithFrame:CGRectMake(18.f, 0.f, 300, SECTION_HEADER_HEIGHT)];
        sectionLbl.backgroundColor = [UIColor clearColor];
        sectionLbl.font = [UIFont boldSystemFontOfSize:8.f];
        sectionLbl.minimumFontSize = 5.f;
        sectionLbl.textAlignment = NSTextAlignmentLeft;
        sectionLbl.textColor = [UIColor colorWithRed:194.f/255.f green:210.f/255.f blue:221.f/255.f alpha:1.f];
        
        NSString *title;
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
		title = [NSString stringWithFormat:@"Left in %@", [sectionInfo name]];
        sectionLbl.text = [title uppercaseString];
        [retView addSubview:sectionLbl];
    }
    return retView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBItemTableViewCell * cell = (CBItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier:ItemTableViewCellReuseIdentifier];
    [self configureCell:cell forTableView:tableView atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    [self configureItemCell:(CBItemTableViewCell *)cell forTableView:tableView atIndexPath:indexPath];
}

- (void)configureItemCell:(CBItemTableViewCell *)cell forTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    DMItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.item = item;
    [cell setSplitted:item.splitted];
    cell.index = indexPath.row + 1;
    cell.detailsVisible = [self.indexes containsObject:[indexPath cb_identifier]];
    [cell configureView];
}

- (UIColor *)tableView:(RKSwipeTableView *)tableView backgroundColorForCellAtIndexPath:(NSIndexPath *)indexPath
      swipingDirection:(RKSwipeTablewViewSwipeDirection)direction
{
    CBItemTableViewCell *cell = (CBItemTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if (direction == RKSwipeTablewViewSwipeDirectionRight) {
        if ([cell.item splitted]) {
            cell.actionLabel.text = NSLocalizedString(@"Reconstitute", nil) ;
            return [UIColor colorWithRed:2.f/225.f green:157.f/255.f blue:92.f/255.f alpha:1.0f];
        }
        else {
            cell.actionLabel.text = NSLocalizedString(@"Split", nil) ;
            return [UIColor colorWithRed:210.f/255.f green:160.f/255.f blue:0.f/255.f alpha:1.0f];
        }
    }
    return nil;
}

- (UIColor *)tableView:(RKSwipeTableView *)tableView contentColorForCellAtIndexPath:(NSIndexPath *)indexPath
      swipingDirection:(RKSwipeTablewViewSwipeDirection)direction
{
    if (direction == RKSwipeTablewViewSwipeDirectionRight) return [UIColor  whiteColor];
    return nil;
}

- (UIImage *)tableView:(RKSwipeTableView *)tableView accessoryImageForCellAtIndexPath:(NSIndexPath *)indexPath
      swipingDirection:(RKSwipeTablewViewSwipeDirection)direction
{
    return nil;
}

- (UIView *)tableView:(RKSwipeTableView *)tableView backgroundViewForCellAtIndexPath:(NSIndexPath *)indexPath
     swipingDirection:(RKSwipeTablewViewSwipeDirection)direction
{
    CBItemTableViewCell *cell = (CBItemTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    return cell.coloredBgView;
}

- (UIView *)tableView:(RKSwipeTableView *)tableView swipingViewForCellAtIndexPath:(NSIndexPath *)indexPath
     swipingDirection:(RKSwipeTablewViewSwipeDirection)direction
{
    CBItemTableViewCell *cell = (CBItemTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    return cell.coloredContentView;
}

- (CGFloat)tableView:(RKSwipeTableView *)tableView swipingTriggerWidthCellAtIndexPath:(NSIndexPath *)indexPath
    swipingDirection:(RKSwipeTablewViewSwipeDirection)direction
{
    return 70.f;
}

- (CGFloat)tableView:(RKSwipeTableView *)tableView swipingDestinationPercentageInCellAtIndexPath:(NSIndexPath *)indexPath swipingDirection:(RKSwipeTablewViewSwipeDirection)direction
{
    return 0.7f;
}

#pragma mark - Fetched Results Controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([DMItem class])];
	
    NSPredicate *predicateCarnet = [NSComparisonPredicate predicateWithLeftExpression:[NSExpression expressionForKeyPath:@"carnet"]
                                                                          rightExpression:[NSExpression expressionForConstantValue:self.carnet]
                                                                                 modifier:NSDirectPredicateModifier
                                                                                     type:NSEqualToPredicateOperatorType
                                                                                  options:NSCaseInsensitivePredicateOption];
    
    // don't show items with zero quantity
    NSPredicate *quantityPredicate = [NSComparisonPredicate predicateWithLeftExpression:[NSExpression expressionForKeyPath:@"quantity"]
                                                                        rightExpression:[NSExpression expressionForConstantValue:@0]
                                                                               modifier:NSDirectPredicateModifier
                                                                                   type:NSGreaterThanPredicateOperatorType
                                                                                options:NSCaseInsensitivePredicateOption];
    
    

    NSArray *predicatesArray = @[predicateCarnet, quantityPredicate];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchBatchSize:50];
    
    NSSortDescriptor *sortDate = [[NSSortDescriptor alloc] initWithKey:@"identifier"
                                                             ascending:YES];

    [fetchRequest setSortDescriptors:@[sortDate]];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:[DMManager managedObjectContext]
                                                                      sectionNameKeyPath:@"waypoint.country.name"
                                                                               cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

#pragma mark - Fetched Results Controller Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert: {
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] forTableView:tableView atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
            
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case NSFetchedResultsChangeDelete: {
             [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];   
        }
            break;
        case NSFetchedResultsChangeMove:
            break;
        case NSFetchedResultsChangeUpdate:
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark - CBCountriesRouteViewDataSource

- (DMWaypoint *)countriesRouteView:(CBCountriesRouteView *)sender countryIdentifierAtIndex:(NSInteger)index
{
    DMWaypoint *waypoint = [self.carnet obtainWaypointByIndex:index];
    return waypoint;
}

- (NSInteger)numberOfItemsInCountriesRouteView:(CBCountriesRouteView *)sender
{
    return self.carnet.waypoints.count;
}

#pragma mark - CBCountriesRouteViewDelegate

- (void)countriesRouteViewDidPressAddNew:(CBCountriesRouteView *)sender
{
    [self performSegueWithIdentifier:SEGUE_SHOW_SOLICITING_CONTROLLER sender:self.carnet];
}

- (void)countriesRouteView:(CBCountriesRouteView *)sender didDetectLongPressInWaypoint:(DMWaypoint *)waypoint
{
	NSString *title = @"Removing Waypoint";
	NSString *date = [CBDateConvertionUtils expiringDateFromTimeInterval:waypoint.dateArrival];
	NSString *text = [NSString stringWithFormat:@"Traveling to %@ on %@. Remove this leg of your journey?", waypoint.country.name, date];
	[CBAlertView showAlertViewWithTitle:title
								message:text
					  cancelButtonTitle:NSLocalizedString(@"Keep", nil)
					  otherButtonTitles:@[NSLocalizedString(@"Remove", nil)]
							 completion:^(CBAlertView *sender, NSUInteger buttonIndex) {
						  if (buttonIndex != [CBAlertView cancelButtonIndex]) {
							  [DMManager removeWaypoint:waypoint];
                              [DMManager updateServerForCarnet:self.carnet];
							  [self.countriesRouteView reloadData];
						  }
					  }];
}

- (void)countriesRouteView:(CBCountriesRouteView *)aRouteView didDetectButtonWithTypeTapped:(CBAlertButtonType)aButton
          forAlertWithType:(CBAlertType)aType
               forWaypoint:(DMWaypoint *)aWaypoint
{
    
    DMManagerAlertHandlingAction retAction = [DMManager handleButtonWithTypeTapped:aButton
                                                          forLocationAlertWithType:aType
                                                                        atWaypoint:aWaypoint
                                                                        fromCarnet:_carnet];
    
    if (retAction == DMManagerAlertHandlingAction_Scan) {
        self.currentAlert = [aWaypoint alertWithType:aType];
    }
    
    [self handleManagerAction:retAction];
}

- (void)countriesRouteViewDidShowLastPage:(CBCountriesRouteView *)aRouteView
{
    [self refreshView];
}

#pragma mark - Remind me picker view

- (void)reminderView:(CBReminderView *)reminderView willHideWithDaysIntervalSelected:(NSUInteger)interval
{
    [self.reminderPicker setHidden:YES animated:YES animationCompletionBlock:nil];
    [DMManager scheduleReminderNotificationForCarnet:self.carnet afterDaysPassed:interval];
}

#pragma mark - CBScannerViewControllerDelegate


- (void)scannerViewController:(CBScannerViewController *)controller didCancelScannigManually:(BOOL)manually
                    withError:(NSError *)error
{
	if (error) {
        [CBAlertView showAlertViewWithTitle:@"Oops"
                                    message:[error localizedDescription]
                          cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                          otherButtonTitles:nil
                                 completion:nil];
	}
	else {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
    
    self.currentAlert = nil;
}

- (void)scannerViewController:(CBScannerViewController *)controller didRecognizeQRCodeWithString:(NSString *)code
{
    if ([CBReachabilityObserver networkStatus] == NotReachable) {
        NSString *connectionError = NSLocalizedString(@"No data connection.", nil);
        [self showAlertError:connectionError];
        return;
    }
	[self dismissViewControllerAnimated:NO
                             completion:^{
                                 [self loadCarnetWithGUID:code];
                             }];
    
}

- (void)loadCarnetWithGUID:(NSString *)guid
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Updating....", nil) maskType:SVProgressHUDMaskTypeClear];
    
    [DMManager  loadCarnetWithGUID:guid
                         afterScan:YES
                 completionHandler:^(DMCarnet *carnet, NSError *error) {
                     [self logUnsuccessfulScanIfNeededWithError:error carnetGUID:carnet.guid];
                     
                     if (error) {
                         [SVProgressHUD dismiss];
                         [self showAlertError:[error localizedDescription]];
                     }
                     else {
                         self.carnet = carnet;
                         [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Updated", nil)];
                         
                         if (self.currentAlert) {
                             self.currentAlert.shown = YES;
                             self.currentAlert.showingDate = [[[NSDate date] midnightUTC] timeIntervalSinceReferenceDate];
                             [DMManager saveContext];
                             [self refreshView];
                         }
                     }
                     
                     self.currentAlert = nil;
                 }];
}

- (void)showAlertError:(NSString *)errorMessage
{
    [CBAlertView showAlertViewWithTitle:nil
                                message:errorMessage
                      cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                      otherButtonTitles:nil
                             completion:nil];
}


#pragma makr - CBSplitBar Delegate

- (void)acceptButtonTappedInSplitBarView:(CBSplitBar *)splitBar
{
    [DMManager acceptAllSplittingChangesForCarnet:self.carnet
                                completionHandler:^(BOOL completed) {
                                    [self setSplitingViewHidden:completed animated:YES];
                                    [self.tableView reloadData];
                                    self.mode = CBCarnetDetailsViewControllerMode_Normal;
                                    
                                    [self.carnet refreshCarnetStatus];
                                    [self.carnetView refreshView];
                                }];
}

- (void)cancelButtonTappedInSplitBarView:(CBSplitBar *)splitBar
{
    [DMManager rollbackAllSplittingChangesForCarnet:self.carnet completionHandler:^(BOOL completed) {
		[self setSplitingViewHidden:completed animated:YES];
		[self.tableView reloadData];
		self.mode = CBCarnetDetailsViewControllerMode_Normal;
	}];    
}

#pragma mark - CBNewAlertListView
#pragma mark    DataSource
- (NSInteger)numberOfPagesInListView:(CBNewAlertListView *)aListView
{
    return _simpleAlertsArray.count;
}

- (void)listView:(CBNewAlertListView *)aListView configurePage:(CBAlertPageView *)tileView forIndex:(NSUInteger)anIndex
{
    if ([self.simpleAlertsArray[anIndex] isKindOfClass:[DMCheckpointAlert class]]) {
        DMCheckpointAlert *alert = (DMCheckpointAlert*)self.simpleAlertsArray[anIndex];
        self.chCurrentAlert = alert;
    }
    [tileView setAlert:self.simpleAlertsArray[anIndex]];
    tileView.alertIndex = anIndex;
}

#pragma mark    Delegate

- (void)listViewDidShowLastPage:(CBNewAlertListView *)aLisstView
{
    [self recalculateMode];
}

- (void)listView:(CBNewAlertListView *)aListView didDetectButtonTapped:(CBAlertButtonType)aButtonType forAlertWithType:(NSUInteger)anAlertType
{
    DMManagerAlertHandlingAction returnedAction = [DMManager handlingActionForSimpleAlertWithType:anAlertType
                                                                                    buttonPressed:aButtonType
                                                                                        forCarnet:self.carnet];
    [self handleManagerAction:returnedAction];
    
    if (returnedAction == DMManagerAlertHandlingAction_Dismiss) {
        [self performSelectorOnMainThread:@selector(cleanCheckpointLocation) withObject:nil waitUntilDone:NO];
    }
    else if (returnedAction != DMManagerAlertHandlingAction_PopController) {
        [self.carnetView refreshView];
    }
}

- (void)cleanCheckpointLocation
{
    if (self.chCurrentAlert) {
        self.chCurrentAlert.shown = [NSNumber numberWithBool:YES];
        self.chCurrentAlert.showingDate = [[NSDate date] midnightUTC];
        [DMManager saveContext];
        [self refreshView];
    }
    else {
        [self.carnetView refreshView];
    }
}

#pragma mark - Lazy Getters

- (NSMutableSet *)indexes
{
    if (!_indexes) {
        _indexes = [[NSMutableSet alloc] init];
    }
    return _indexes;
}

- (NSMutableArray *)simpleAlertsArray
{
    if (!_simpleAlertsArray) {
        _simpleAlertsArray = [[NSMutableArray alloc] init];
    }
    return _simpleAlertsArray;
}

- (NSMutableArray *)simplePopoversArray
{
    if (!_simplePopoversArray) {
        _simplePopoversArray = [[NSMutableArray alloc] init];
    }
    return _simplePopoversArray;
}

- (NSMutableArray *)locationAlertsArray
{
    if (!_locationAlertsArray) {
        _locationAlertsArray = [[NSMutableArray alloc] init];
    }
    return _locationAlertsArray;
}

- (NSMutableArray *)locationPopoversArray
{
    if (!_locationPopoversArray) {
        _locationPopoversArray = [[NSMutableArray alloc] init];
    }
    return _locationPopoversArray;
}

- (NSMutableArray *)instructionsArray
{
    if (!_instructionsArray) {
        _instructionsArray = [[NSMutableArray alloc] init];
    }
    return _instructionsArray;
}

#pragma mark - Private

- (void)setHidesBackButton:(BOOL)hide animated:(BOOL)animated
{
    if ([[UIDevice currentDevice] systemVersionGreaterOrEqual:7.0f]) {
        [self.navigationItem setLeftBarButtonItem:(hide ? nil : self.backButton) animated:animated];
    } else {
        [self.navigationItem setHidesBackButton:hide animated:animated];
    }
}

@end
