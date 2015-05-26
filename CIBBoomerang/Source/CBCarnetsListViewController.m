//
//  CBFirstLevelViewController.m
//  CIBBoomerang
//
//  Created by Roma on 4/24/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBCarnetsListViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "CBAlertView.h"
#import "CBAppearance.h"
#import "CBAlertView.h"
#import "CBCarnetCell.h"
#import "CBCarnetDetailsViewController.h"
#import "CBSolicitingTravelViewController.h"
#import "CBReachabilityObserver.h"
#import "CBScannerViewController.h"
#import "CBSettingsViewController.h"
#import "DMManager.h"
#import "RKSwipeTableView.h"
#import "CBStoryboardUtil.h"
#import "CBConnectionManager.h"
#import "CBAppDelegate.h"

#import "SVProgressHUD.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

NSString *const keyLegalDisclaimerAgreed = @"keyLegalDisclaimerAgreed";

#define SEGUE_SHOW_CARNET_DETAILS       @"Segue_ShowCarnetDetails"
#define SEGUE_SHOW_SETTINGS             @"Show Settings Controller"
#define SEGUE_SHOW_NEW_CARNET_DETAILS   @"Show New Carnet Details"

@interface CBCarnetsListViewController () <RKSwipeTableViewDataSource, RKSwipeTableViewDelegate, CBScannerViewControllerDelegate ,
                                            NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet RKSwipeTableView *carnetTableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

/* empty view */
@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

/* bottom bar */
@property (weak, nonatomic) IBOutlet UILabel *bottomTextLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomBarView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomAccessoryView;
@property (weak, nonatomic) IBOutlet UIButton *addCarnetButton;

@property (strong) NSDate *lastShake;

- (IBAction)addCarnetButtonTapped:(UIButton *)sender;

@end

@implementation CBCarnetsListViewController

static BOOL agreementIsAsked = NO;
static BOOL firstAppearance = YES;

- (void)viewDidLoad
{
    [super viewDidLoad];
		
	[self addNotificationObserver];
    [self configureView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkNetworkReachability)
                                                 name:CBReachabilityObserverNetworkStatusDidChange
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // to hide title next to back sign on iOS 7
    if ([[UIDevice currentDevice] systemVersionGreaterOrEqual:7.0f]) {
        [self configureView];
    }
    
    // for shake gesture needs
    [self becomeFirstResponder];
    
    [self.carnetTableView reloadData];
    [self.carnetTableView deselectRowAtIndexPath:[self.carnetTableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!agreementIsAsked) {
        agreementIsAsked = YES;
        [self checkLegalAgreement];
    }
    
    if (firstAppearance) {
        firstAppearance = NO;
        
        [DMManager updateLocalCarnetsForCurrentCountry];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    // for shake gesture needs
    [self resignFirstResponder];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // to hide title next to back sign on iOS 7
    if ([[UIDevice currentDevice] systemVersionGreaterOrEqual:7.0f]) {
        self.title = @"";
    }
    
    [super viewDidDisappear:animated];
}

// for shake gesture needs
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)refreshView
{
    [self.carnetTableView reloadData];
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
                                message:@"Will you be travelling soon?"
                      cancelButtonTitle:@"NO"
                      otherButtonTitles:@[@"YES"]
                             completion:^(CBAlertView *sender, NSUInteger buttonIndex) {
                                 if (buttonIndex != [CBAlertView cancelButtonIndex]) {
//                                     [DMManager startTravelDayWorkflow];
                                 }
                             }];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_SHOW_CARNET_DETAILS]) {
        NSIndexPath *indexPath = [self.carnetTableView indexPathForSelectedRow];
        if (indexPath) {
            [[segue destinationViewController] setCarnet:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        }
    }
    
    if ([segue.identifier isEqualToString:SEGUE_SHOW_NEW_CARNET_DETAILS]) {
        [[segue destinationViewController] setCarnet:(DMCarnet *)sender];
    }
}

#pragma mark - IBAction

- (IBAction)addCarnetButtonTapped:(UIButton *)sender
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:keyLegalDisclaimerAgreed] == NO) {
        [self checkLegalAgreement];
    } else {
        CBScannerViewController *scanner = [self.storyboard instantiateViewControllerWithIdentifier:ScannerViewControllerStoryboardId];
        scanner.delegate = self;
        [self presentViewController:scanner animated:YES completion:nil];
    }
}

- (void)settingsButtonTapped:(UIBarButtonItem *)button
{
    [self performSegueWithIdentifier:SEGUE_SHOW_SETTINGS sender:self];
}

- (void)helpButtonTapped:(UIBarButtonItem *)button
{
    [self.navigationController performSegueWithIdentifier:SEGUE_SHOW_HELP sender:self];
}

#pragma mark - Private

- (void)configureView
{
    [CBAppearance customizeViewController:self
                                withTitle:NSLocalizedString(@"Carnets", nil)
                     leftBarBarButtonType:CBAppearanceButtonTypeNone
                       rightBarButtonType:CBAppearanceButtonTypeNone];

    [self configureBarButtons];
    
    self.carnetTableView.delegate = self;
    self.carnetTableView.dataSource = self;
}

- (void)configureBarButtons
{
    // settings button
    UIBarButtonItem *settingsBtn;
    
    if ([[UIDevice currentDevice] systemVersionGreaterOrEqual:7.0f]) {
        settingsBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_settings.png"]
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(settingsButtonTapped:)];
    } else {
        settingsBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Settings", nil)
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(settingsButtonTapped:)];
    }
    
    self.navigationItem.leftBarButtonItem = settingsBtn;
    
    // help button
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

    // bottom text label
    self.bottomTextLabel.text = NSLocalizedString(@"Open Scanner Here", nil);
    
    if ([[UIDevice currentDevice] systemVersionGreaterOrEqual:7.0f]) {
        self.bottomTextLabel.font = [CBFontUtils droidSansFontBold:NO ofSize:17.f];
    } else {
        self.bottomTextLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:13.f];
    }
    
    // add carnet button
    if ([[UIDevice currentDevice] systemVersionGreaterOrEqual:7.0f]) {
        self.addCarnetButton.titleLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:17.f];
    } else {
        self.addCarnetButton.titleLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:13.f];
    }
    
    if ([[UIDevice currentDevice] systemVersionGreaterOrEqual:7.0f]) {
        self.addCarnetButton.titleLabel.text = NSLocalizedString(@"Add Carnet", nil);
    } else {
        self.addCarnetButton.titleLabel.text = NSLocalizedString(@"ADD CARNET", nil);
        [self.addCarnetButton setBackgroundImage:[[UIImage imageNamed:@"Bar-Button-Done"] resizableImageWithCapInsets:UIEdgeInsetsMake(0., 7., 0, 7.)] forState:UIControlStateNormal];
    }
    
    // welcome label
    self.welcomeLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:18.f];
    
    // description label
    self.descriptionLabel.font = [CBFontUtils droidSansFontBold:NO ofSize:16.f];
    self.descriptionLabel.text = NSLocalizedString(@"Empty View Label", @"Carnet List empty view greetins and instructions label");
}

- (void)checkLegalAgreement
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:keyLegalDisclaimerAgreed] == NO) {
        NSString *title = @"Corporation for International Business User Agreement";
        NSString *msg = NSLocalizedString(@"Legal Agreement", nil);
        
        NSString *btnAgree = NSLocalizedString(@"Agree", nil);
        NSString *btnNoAgree = NSLocalizedString(@"Don't Agree", nil);
        [CBAlertView showAlertViewWithTitle:title
                                    message:msg
                          cancelButtonTitle:btnNoAgree
                          otherButtonTitles:@[btnAgree]
                                 completion:^(CBAlertView *sender, NSUInteger buttonIndex) {
                                     if (buttonIndex != [CBAlertView cancelButtonIndex]) {
                                         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:keyLegalDisclaimerAgreed];
                                         [[NSUserDefaults standardUserDefaults] synchronize];
                                     }
                                     
                                     [self checkNetworkReachability];
                                 }];
    }
    else {
        [self checkNetworkReachability];
    }
}

- (void)checkNetworkReachability
{
    if ([CBReachabilityObserver networkStatus] == NotReachable) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSString *connectionError = NSLocalizedString(@"No data connection.", nil);
            [self showAlertError:connectionError];
        });
    }
}

- (void)showAlertError:(NSString *)errorMessage
{
    [CBAlertView showAlertViewWithTitle:nil
                                message:errorMessage
                      cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                      otherButtonTitles:nil
                             completion:nil];
}

#pragma mark - Shake

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        if (self.lastShake && [self.lastShake timeIntervalSinceNow] < 15) {
            UIStoryboard *fakeLocationStoryboard = [CBStoryboardUtil createFakeLocationStoryboard];
            [self presentViewController:[fakeLocationStoryboard instantiateInitialViewController] animated:YES completion:nil];
        }
        self.lastShake = [NSDate date];
    }
}

#pragma mark - Table view data source

static NSString *CarnetCell = @"CarnetCell";

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[self.fetchedResultsController fetchedObjects] count];
    self.emptyView.hidden = (count != 0);
    self.carnetTableView.hidden = !self.emptyView.hidden;
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ((CBCarnetCell *)cell).carnet = [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [(RKSwipeTableView *)tableView dequeueReusableCellWithIdentifier:CarnetCell];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UIColor *)tableView:(RKSwipeTableView *)tableView backgroundColorForCellAtIndexPath:(NSIndexPath *)indexPath
      swipingDirection:(RKSwipeTablewViewSwipeDirection)direction
{
    return [UIColor redColor];
}

- (UIColor *)tableView:(RKSwipeTableView *)tableView contentColorForCellAtIndexPath:(NSIndexPath *)indexPath
      swipingDirection:(RKSwipeTablewViewSwipeDirection)direction
{
    return [UIColor whiteColor];
}

- (UIImage *)tableView:(RKSwipeTableView *)tableView accessoryImageForCellAtIndexPath:(NSIndexPath *)indexPath
      swipingDirection:(RKSwipeTablewViewSwipeDirection)direction
{
    return [UIImage imageNamed:@"delete.png"];
}

- (UIView *)tableView:(RKSwipeTableView *)tableView backgroundViewForCellAtIndexPath:(NSIndexPath *)indexPath
     swipingDirection:(RKSwipeTablewViewSwipeDirection)direction
{
    CBCarnetCell *cell = (CBCarnetCell *)[tableView cellForRowAtIndexPath:indexPath];
    return [cell coloredBackgroundView];
}

- (UIView *)tableView:(RKSwipeTableView *)tableView swipingViewForCellAtIndexPath:(NSIndexPath *)indexPath
     swipingDirection:(RKSwipeTablewViewSwipeDirection)direction
{
    CBCarnetCell *cell = (CBCarnetCell *)[tableView cellForRowAtIndexPath:indexPath];
    return [cell coloredContentView];
}

- (CGFloat)tableView:(RKSwipeTableView *)tableView swipingTriggerWidthCellAtIndexPath:(NSIndexPath *)indexPath
    swipingDirection:(RKSwipeTablewViewSwipeDirection)direction
{
    return 120.f;
}

- (NSArray *)tableView:(RKSwipeTableView *)tableView allowedSwipingDirectionsForCellAtIndexPath:(NSIndexPath *)indexPath
{
    return @[@(RKSwipeTablewViewSwipeDirectionLeft)];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:SEGUE_SHOW_CARNET_DETAILS
                              sender:[tableView cellForRowAtIndexPath:indexPath]];
}

- (void)tableView:(RKSwipeTableView *)tableView willEndSwipingCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
      inDirection:(RKSwipeTablewViewSwipeDirection)swipeDirection completionHandler:(RKSwipeTableViewCompletionHandler)completion
{
    [CBAlertView showAlertViewWithTitle:nil
                                message:[NSString stringWithFormat:NSLocalizedString(@"Do you really want to remove %@ carnet?", nil), ((CBCarnetCell *)cell).carnet.identifier]
                      cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                      otherButtonTitles:@[NSLocalizedString(@"Confirm", nil)]
                             completion:^(CBAlertView *sender, NSUInteger buttonIndex) {
                          if ([CBAlertView cancelButtonIndex] == buttonIndex) {
                              completion (NO);
                          }
                          else {
                              DMCarnet *carnet = ((CBCarnetCell *)cell).carnet;
                              if ([DMManager connectionAvailable]) {
                                  [DMManager removeCarnet:carnet];
                                  completion (YES);
                              }
                              else {
                                  [self showLoggingFailAlertViewWithAction:@"carnet deletion"];
                                  completion (NO);
                              }
                          }
                      }];
}

- (void)showLoggingFailAlertViewWithAction:(NSString *)action
{
    [CBAlertView showAlertViewWithTitle:@"Connection Problem"
                                message:[NSString stringWithFormat:@"Cannot perform %@ without Internet connection. Please check your internet connection and try again.", action]
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil
                             completion:nil];
}

#pragma mark - Fetched Results Controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([DMCarnet class])];
    [fetchRequest setFetchBatchSize:50];
    
    NSSortDescriptor *sortDate = [[NSSortDescriptor alloc] initWithKey:@"dateExpired"
                                                             ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDate]];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:[DMManager managedObjectContext]
                                                                      sectionNameKeyPath:nil
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
    [self.carnetTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    UITableView *tableView = self.carnetTableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert: {
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.carnetTableView endUpdates];
}

#pragma mark - CBScannerViewControllerDelegate

- (void)scannerViewController:(CBScannerViewController *)controller
     didCancelScannigManually:(BOOL)manually
                    withError:(NSError *)error
{
	if (error) {
		DDLogError(@"error %@ %s",[error localizedDescription], __PRETTY_FUNCTION__);
        [CBAlertView showAlertViewWithTitle:@"Oops"
                                    message:[error localizedDescription]
                          cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                          otherButtonTitles:nil
                                 completion:nil];
	}
	else {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

- (void)scannerViewController:(CBScannerViewController *)controller didRecognizeQRCodeWithString:(NSString *)code
{
    if ([CBReachabilityObserver networkStatus] == NotReachable) {
        NSString *connectionError = NSLocalizedString(@"No data connection.", nil);
        [self showAlertError:connectionError];
        return;
    }
    
	[self dismissViewControllerAnimated:YES
                             completion:^{
		[SVProgressHUD showWithStatus:@"Loading...." maskType:SVProgressHUDMaskTypeClear];
                                 
		[DMManager  loadCarnetWithGUID:code
                             afterScan:YES
					 completionHandler:^(DMCarnet *carnet, NSError *error) {
						 [SVProgressHUD dismiss];
                         
                         [self logUnsuccessfulScanIfNeededWithError:error carnetGUID:carnet.guid];
                         
						 if (error) {
                             [self showAlertError:[error localizedDescription]];
						 } else {
                             [self performSegueWithIdentifier:SEGUE_SHOW_NEW_CARNET_DETAILS
                                                       sender:carnet];
						 }
					 }];
	}];

}

@end
