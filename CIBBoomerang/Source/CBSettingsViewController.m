//
//  CBSettingsViewController.m
//  CIBBoomerang
//
//  Created by Roma on 5/10/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBSettingsViewController.h"
#import "CBAppearance.h"
#import "CBHelpViewController.h"
#import "CBSettings.h"

#define VERSION_VIEW_HEIGHT         60
#define VERSION_VIEW_RIGHT_MARGIN   18
#define VERSION_VIEW_BOTTOM_MARGIN  12
#define VERSION_VIEW_INNER_MARGIN   5



NSString *const SettingsViewControllerStoryboardId = @"Settings View Controller";

@interface CBSettingsViewController ()

/* basic alerts */
@property (weak, nonatomic) IBOutlet UILabel *basicAlertTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *basicAlertDescriptionLabel;
@property (weak, nonatomic) IBOutlet UISwitch *basicAlertSlider;

/* sound */
@property (weak, nonatomic) IBOutlet UILabel *soundTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *soundDescriptionLabel;
@property (weak, nonatomic) IBOutlet UISwitch *soundSlider;

 /* wifi */
@property (weak, nonatomic) IBOutlet UILabel *wifiTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *wifiDescriptionLabel;
@property (weak, nonatomic) IBOutlet UISwitch *wifiSlider;

/* version labek*/
@property (strong, nonatomic) UIView *versionView;
@property (strong, nonatomic) UILabel *versionLabel;
@property (strong, nonatomic) UILabel *versionTextLabel;

- (IBAction)basicAlertSwitchValueChanged:(UISwitch *)switcher;
- (IBAction)soundSwitchValueChanged:(UISwitch *)switcher;
- (IBAction)wifiSwitchValueChanged:(UISwitch *)switcher;

@end

@implementation CBSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureSwitchers];
}

#pragma mark - View Configuration

- (void)configureView
{
    // set back button and title
    if ([[UIDevice currentDevice] systemVersionGreaterOrEqual:7.0f]) {
        self.title = NSLocalizedString(@"Settings", nil);
        
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.leftBarButtonItem = backButton;
    } else {
        [CBAppearance customizeViewController:self
                                    withTitle:NSLocalizedString(@"Settings", nil)
                         leftBarBarButtonType:CBAppearanceButtonTypeBack
                           rightBarButtonType:CBAppearanceButtonTypeNone];
    }
    
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
    
	NSString *versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];

	self.versionLabel.text = [NSString stringWithFormat:@"%@", versionString];
    
    self.basicAlertTitleLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:15.f];
    self.basicAlertDescriptionLabel.font = [CBFontUtils droidSansFontBold:NO ofSize:14.f];
    
    self.soundTitleLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:15.f];;
    self.soundDescriptionLabel.font = [CBFontUtils droidSansFontBold:NO ofSize:14.f];;
    
    self.wifiTitleLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:15.f];;
    self.wifiDescriptionLabel.font = [CBFontUtils droidSansFontBold:NO ofSize:14.f];;
    
    self.versionLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:15.f];;
    self.versionTextLabel.font = [CBFontUtils droidSansFontBold:NO ofSize:14.f];;
}

- (void)configureSwitchers
{
    self.basicAlertSlider.on = [CBSettings basicAlertsOn];
    self.soundSlider.on = [CBSettings soundsOn];
    self.wifiSlider.on = [CBSettings wifiOnlyOn];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 3) {
        return VERSION_VIEW_HEIGHT;
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 3) {
        if (!self.versionView) {
            self.versionView = [[UIView alloc] init];
            self.versionView.backgroundColor = [UIColor clearColor];
            
            // text
            self.versionTextLabel = [[UILabel alloc] init];
            self.versionTextLabel.font = [UIFont systemFontOfSize:10];
            self.versionTextLabel.backgroundColor = [UIColor clearColor];
            self.versionTextLabel.text = NSLocalizedString(@"Version", nil);
            [self.versionTextLabel sizeToFit];
            [self.versionView addSubview:self.versionTextLabel];
            
            // version
            self.versionLabel = [[UILabel alloc] init];
            self.versionLabel.font = [UIFont boldSystemFontOfSize:12];
            self.versionLabel.backgroundColor = [UIColor clearColor];
            self.versionLabel.text = [self versionString];
            [self.versionLabel sizeToFit];
            [self.versionView addSubview:self.versionLabel];
            
            // frames
            self.versionView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), VERSION_VIEW_HEIGHT);
            
            self.versionLabel.frame = CGRectMake(CGRectGetWidth(self.versionView.frame) - CGRectGetWidth(self.versionLabel.frame) - VERSION_VIEW_RIGHT_MARGIN,
                                                 CGRectGetMaxY(self.versionView.frame) - CGRectGetHeight(self.versionLabel.frame) - VERSION_VIEW_BOTTOM_MARGIN,
                                                 CGRectGetWidth(self.versionLabel.frame),
                                                 CGRectGetHeight(self.versionLabel.frame));
            
            self.versionTextLabel.frame = CGRectMake(CGRectGetMinX(self.versionLabel.frame) - CGRectGetWidth(self.versionTextLabel.frame) - VERSION_VIEW_INNER_MARGIN,
                                                     CGRectGetMinY(self.versionLabel.frame) + (CGRectGetHeight(self.versionLabel.frame) - CGRectGetHeight(self.versionTextLabel.frame)) / 2,
                                                     CGRectGetWidth(self.versionTextLabel.frame),
                                                     CGRectGetHeight(self.versionTextLabel.frame));
        }
        
        return self.versionView;
    } else {
        return nil;
    }
}

- (NSString *)versionString
{
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    return [info objectForKey:@"CFBundleShortVersionString"];
}

#pragma mark - IBActions

- (IBAction)basicAlertSwitchValueChanged:(UISwitch *)switcher
{
    [CBSettings turnBasicAlertsOn:switcher.on];
}

- (IBAction)soundSwitchValueChanged:(UISwitch *)switcher
{
    [CBSettings turnSoundsOn:switcher.on];
}

- (IBAction)wifiSwitchValueChanged:(UISwitch *)switcher
{
    [CBSettings turnWifiOnlyOn:switcher.on];
}

- (void)backButtonTapped:(UIBarButtonItem *)backBtn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)helpButtonTapped:(UIBarButtonItem *)button
{
    [self.navigationController performSegueWithIdentifier:SEGUE_SHOW_HELP sender:self];
}

@end
