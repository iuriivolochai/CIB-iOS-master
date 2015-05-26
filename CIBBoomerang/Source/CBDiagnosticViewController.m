//
//  CBDiagnosticViewController.m
//  CIBBoomerang
//
//  Created by Alexander on 5/16/14.
//  Copyright (c) 2014 Roma. All rights reserved.
//

#import "CBDiagnosticViewController.h"
#import "CBServerLoggingUtils.h"
#import <CoreLocation/CoreLocation.h>
#import "Reachability.h"
#import "CBReachabilityObserver.h"
#import "DMCarnet+Auxilliary.h"
#import "CBGateway.h"

#define DIAGNOSTIC_EMAIL @"itsupport@atacarnet.com"

const NSString *propertyApplication = @"Application";
const NSString *propertyDeviceUDID = @"Device UDID";
const NSString *propertyGPSStatus = @"GPS status";
const NSString *propertyInternetConnection = @"Internet connection";
const NSString *propertyServerConnection = @"Server connection";
const NSString *propertyCarnets = @"Carnets";

@interface CBDiagnosticViewController ()
@property (assign) IBOutlet UITableView *tableView;

@property (strong) NSArray *keys;
@property (strong) NSMutableDictionary *properties;

@end

@implementation CBDiagnosticViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Custom initialization
    self.title = @"Diagnostic page";
    
    self.properties = [NSMutableDictionary dictionary];
    self.keys = @[propertyApplication,
                  propertyDeviceUDID,
                  propertyGPSStatus,
                  propertyInternetConnection,
                  propertyServerConnection,
                  propertyCarnets];
    
    for (NSString *key in self.keys) {
        self.properties[key] = @"";
    }
    
    [self collectDiagnosticInfo];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.keys.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdent = @"DiagnosticCellIdent";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdent];
    }
    
    NSString *key = self.keys[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", key, self.properties[key]];
    
    return cell;
}

#pragma mark - Actions

- (IBAction)sendDiagnosticInfo:(id)sender
{
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setToRecipients:@[DIAGNOSTIC_EMAIL]];
    [controller setSubject:@"Diagnostic CIB"];
    [controller setMessageBody:[self diagnosticDescription] isHTML:NO];
    if (controller)
        [self presentViewController:controller animated:YES completion:nil];
}

- (NSString*)diagnosticDescription
{
    NSMutableArray *strings = [NSMutableArray array];
    for (NSString *key in self.keys) {
        [strings addObject:[NSString stringWithFormat:@"%@: %@", key, self.properties[key]]];
    }
    return [strings componentsJoinedByString:@"\n"];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:^(){
        if (result == MFMailComposeResultSent) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

#pragma mark - Collect diagnostic info

- (void)collectDiagnosticInfo
{
    [self updateApplication];
    [self updateDeviceUDIDI];
    [self updateGPSStatus];
    [self updateInternetStatus];
    [self updateServerConeection];
    [self updateCarnetsList];
}

- (void)updateApplication
{
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    self.properties[propertyApplication] = [NSString stringWithFormat:@"CIB %@", [info objectForKey:@"CFBundleShortVersionString"]];
}

- (void)updateDeviceUDIDI
{
    self.properties[propertyDeviceUDID] = [CBServerLoggingUtils deviceId];
}

- (void)updateGPSStatus
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
            self.properties[propertyGPSStatus] = @"YES";
        }
        else {
            self.properties[propertyGPSStatus] = @"NO";
        }
    }
    else {
        self.properties[propertyGPSStatus] = @"Denied";
    }
}

- (void)updateInternetStatus
{
    switch ([CBReachabilityObserver networkStatus]) {
        case NotReachable:
            self.properties[propertyInternetConnection] = @"No";
            break;
            
        case ReachableViaWWAN:
            self.properties[propertyInternetConnection] = @"via WWAN";
            break;
            
        case ReachableViaWiFi:
            self.properties[propertyInternetConnection] = @"via WiFi";
            break;
    }
}

- (void)updateServerConeection
{
    self.properties[propertyServerConnection] = @"---";
    [CBGateway sendTestRequestToServerWithCompletionBlock:^(id obj){
        self.properties[propertyServerConnection] = @"YES";
        [self.tableView reloadData];
    }
                                               errorBlock:^(NSError *error){
                                                   if (error.code == 404) {
                                                       self.properties[propertyServerConnection] = @"YES";
                                                   }
                                                   else {
                                                       self.properties[propertyServerConnection] = @"NO";
                                                   }
                                                   [self.tableView reloadData];
                                               }];
}

- (void)updateCarnetsList
{
    NSArray *carnets = [DMCarnet obtainAllCarnets];
    if (carnets.count > 0) {
        NSMutableArray *carnetsString = [NSMutableArray array];
        for (DMCarnet *carnet in carnets) {
            NSString *info = [NSString stringWithFormat:@"%@", carnet.guid];
            [carnetsString addObject:info];
        }
        self.properties[propertyCarnets] = [NSString stringWithFormat:@"%d Carnets \n %@", carnets.count, [carnetsString componentsJoinedByString:@", \n"]];
    }
    else {
        self.properties[propertyCarnets] = @"None";
    }
}

@end
