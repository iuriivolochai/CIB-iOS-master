//
//  CBHelpViewController.m
//  CIBBoomerang
//
//  Created by Roma on 5/13/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBHelpViewController.h"

#import "CBAppearance.h"
#import "CBHelpCellView.h"
#import "CBHelpIssue.h"
#import "CBHelpIssueCell.h"
#import "CBHelpIssueHeaderView.h"

#import "LIOLookIOManager.h"

NSString *const HelpViewControllerStoryboardId = @"Help ViewController";

@interface CBHelpViewController () <CBHelpIssueHeaderViewDelegate, LIOLookIOManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *issues;
@property (strong, nonatomic) NSArray *issueViews;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

- (IBAction)chatButtonTapped:(id)sender;

@end

@implementation CBHelpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureView];
    [[LIOLookIOManager sharedLookIOManager] setDelegate:self];
    
//    self.descriptionTextView.frame = CGRectMake(self.descriptionTextView.frame.origin.x,
//                                               self.descriptionTextView.frame.origin.y,
//                                               self.descriptionTextView.frame.size.width,
//                                               self.descriptionTextView.contentSize.height);
    self.descriptionTextView.scrollEnabled = NO;
    self.descriptionTextView.bounces = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [[LIOLookIOManager sharedLookIOManager] setDelegate:nil];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBHelpIssue *issue = [self.issues objectAtIndex:indexPath.section];
    CGSize maximumLabelSize = CGSizeMake(235.f, 9999);
    
    CGSize expectedTitleLabelSize = [issue.issueDescription sizeWithFont:[CBFontUtils droidSansFontBold:NO ofSize:13.f]
                                                  constrainedToSize:maximumLabelSize
                                                      lineBreakMode:NSLineBreakByWordWrapping];
    return expectedTitleLabelSize.height + 30.f;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.issueViews.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CBHelpIssueHeaderView *headerView = self.issueViews[section];
    return (headerView.selected) ? 1 : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    CBHelpIssueCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    CBHelpIssue *issue = self.issues[indexPath.section];
    cell.titleLabel.text = issue.issueDescription;
    cell.titleLabel.font = [CBFontUtils droidSansFontBold:NO ofSize:13.f];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.issueViews[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 56.;
}

#pragma mark - Private

- (void)configureView
{
    [CBAppearance customizeViewController:self withTitle:NSLocalizedString(@"Help", nil)
                      leftBarBarButtonType:CBAppearanceButtonTypeBack
                       rightBarButtonType:CBAppearanceButtonTypeNone];
    
    self.descriptionTextView.font = [CBFontUtils droidSansFontBold:NO ofSize:13.f];
    self.issues = @[[CBHelpIssue issueWithTitle:@"WHERE DO I FIND CUSTOMS AT THE AIRPORT?"
                                    description:@"Before checking your bags, you must get your Carnet stamped by a customs officer. Consult a public information office or seek the help of airport staff to locate the airport's customs office."],
                    
                    [CBHelpIssue issueWithTitle:@"WHERE DO I SIGN THE CARNET TO HAVE IT VALIDATED?"
                                    description:@"You must sign box J on the green cover page of the Carnet prior to presenting it to customs."],
                    
                    [CBHelpIssue issueWithTitle:@"HOW CAN I GET ADDITIONAL COUNTERFOILS AND VOUCHERS? I'M RUNNING LOW!"
                                    description:@"Login to your account at www.atacarnet.com and choose Carnet Request, then Request Additional Certificates. If you need assistance please call Customer Service at (800) 282-2900."],
                    
                    [CBHelpIssue issueWithTitle:@"I'VE LOST MY CARNET. WHAT CAN I DO?"
                                    description:@"You can request a replacement. Login to your account at www.atacarnet.com and choose Carnet Request, then fill out the form for Lost Carnet. For immediate assistance please call Customer Service at (800) 282-2900."],

                    [CBHelpIssue issueWithTitle:@"CAN I LEAVE A PORTION OF THE CARNET'S GOODS IN A FOREIGN COUNTRY AND PICK THEM UP LATER?"
                                    description:@"Yes, we refer to this as a split shipment. Of course these goods must be picked up and brought back to the US (and the Carnet stamped by US customs) by the Carnet's expiration date. You cannot leave any of the Carnet's goods in a foreign country indefinitely."],
                    
                    [CBHelpIssue issueWithTitle:@"MY CARNET IS EXPIRING. CAN THE EXPIRATION DATE BE EXTENDED?"
                                    description:@"An extension or replacement Carnet can be requested, and may or may not be granted depending on the country to which the goods have been temporarily imported. Please call Customer Service at (800) 282-2900."],
                    
                    [CBHelpIssue issueWithTitle:@"WHERE DO CUSTOMS SIGN?"
                                    description:@"US Customs will sign the green cover page upon first use of the Carnet. This signature (and yours on the same page) activates the Carnet and its yellow counterfoils. Foreign customs will stamp and sign white counterfoils and vouchers."],
                    
                    [CBHelpIssue issueWithTitle:@"I FORGOT TO GET MY CARNET STAMPED AND SIGNED. WHAT CAN I DO?"
                                    description:@"Please call Customer Service at (800) 282-2900 immediately."],
                    
                    [CBHelpIssue issueWithTitle:@"THE COUNTRY I'M TRAVELING TO IS NOT LISTED ON THE CARNET. WHAT DOES THAT MEAN?"
                                    description:@"If the country you are traveling to is not listed on the Carnet it is not an ATA Carnet-accepting country. Only the countries listed on the green cover page of your Carnet accept ATA Carnets. "],
                    
                    [CBHelpIssue issueWithTitle:@"CUSTOMS SIGNED THE WRONG BOX. NOW WHAT?"
                                    description:@"If you are still at the airport and can have customs sign the correct box, please do so. If not, how and where customs signed the Carnet will determine your next steps. Please call Customer Service at (800) 282-2900."],
                    
                    [CBHelpIssue issueWithTitle:@"SOME OR ALL OF THE CARNET'S GOODS HAVE BEEN SOLD IN A FOREIGN COUNTRY. WHAT SHOULD I DO?"
                                    description:@"Please advise customs of the country in which goods were sold which line item numbers have been sold. Then, when paying duties and taxes for those goods on your departure, make sure you have foreign customs note the Carnet number on your payment receipt. Otherwise when the claim comes to us for payment we will notify you."]];
    
    NSMutableArray *mutableIssueViews = [NSMutableArray arrayWithCapacity:self.issues.count];
    for (NSInteger i = 0; i < self.issues.count; i++) {
        CBHelpIssueHeaderView *issueView = [[CBHelpIssueHeaderView alloc] initWithFrame:CGRectMake(0., 0., 320., 56.)];
        issueView.issue = self.issues[i];
        issueView.index = i;
        issueView.delegate = self;
        [mutableIssueViews addObject:issueView];
    }
    self.issueViews = [NSArray arrayWithArray:mutableIssueViews];
    [self.tableView reloadData];
}

#pragma mark - CBHelpIssueHeaderView delegate

- (void)helpIssueHeaderViewDidSelect:(CBHelpIssueHeaderView *)view
{
    [view setSelected:!view.selected animated:YES];
    NSInteger section = [self.issueViews indexOfObject:view];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section]
                  withRowAnimation:UITableViewRowAnimationFade];
	if (view.selected) {
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
	}
}

#pragma mark - Actions

- (IBAction)backButtonTapped:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)chatButtonTapped:(id)sender {
    [[LIOLookIOManager sharedLookIOManager] beginChat];
}

#pragma mark - LIOLookIOManager Delegate

- (void)lookIOManagerDidEndChat:(LIOLookIOManager *)aManager
{
}

@end