//
//  CBFakeLocationsViewController.m
//  CIBBoomerang
//
//  Created by Artem Stepanenko on 10/15/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBFakeLocationsViewController.h"
#import "CBAppearance.h"
#import "CBFakeLocationTableViewCell.h"
#import "DMManager.h"
#import "DMCheckpoint.h"
#import "DMCountry+Auxilliary.h"
#import "UIDevice-Hardware.h"

#pragma mark -

@interface DMCountry (CellTitle)

- (NSString *)ct_cellTitle;

@end

@implementation DMCountry (CellTitle)

- (NSString *)ct_cellTitle
{
    return self.name;
}

@end

#pragma mark -

@interface DMCheckpoint (CellTitle)

- (NSString *)ct_cellTitle;

@end

@implementation DMCheckpoint (CellTitle)

- (NSString *)ct_cellTitle
{
    NSMutableString *temp = [NSMutableString string];
    
    if (![self isFault] && self.country && self.country.name && ([self.country.name length] > 0)) {
        [temp appendString:self.country.name];
    }
    
    if (self.location && ([self.location length] > 0)) {
        if ([temp length] > 0) {
            [temp appendFormat:@", %@", self.location];
        } else {
            [temp appendString:self.location];
        }
    }
    
    if (self.name && ([self.name length] > 0)) {
        if ([temp length] > 0) {
            [temp appendFormat:@", %@", self.name];
        } else {
            [temp appendString:self.name];
        }
    }
    
    [temp appendFormat:@" %@", self.ident];
    
    return [NSString stringWithString:temp];
}

@end

#pragma mark -
#pragma mark -

#define LOCATION_TYPE_VIEW_HEIGHT   ([[UIDevice currentDevice] systemVersionGreaterOrEqual:7.0f] ? 29.0f : 44.0f) * 1.5f

typedef enum {
    FakeLocationTypeCountry = 0,
    FakeLocationTypeAirport = 1,
    FakeLocationTypeBorders = 2,
    FakeLocationTypePorts = 3,
    FakeLocationTypeDefault = FakeLocationTypeCountry,
} FakeLocationType;

@interface CBFakeLocationsViewController () <UISearchBarDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, weak) IBOutlet UILabel *currentFakeLocationLabel;
@property (nonatomic, weak) IBOutlet UIView *fakeLocationView;
@property (nonatomic, weak) IBOutlet UIButton *enableFakeLocationButton;

@property (nonatomic, weak) IBOutlet UILabel *disableFakeLocationLabel;
@property (nonatomic, weak) IBOutlet UIButton *disableFakeLocationButton;

@property (nonatomic, assign) FakeLocationType currentFakeLocationType;

@property (nonatomic, strong) NSArray *currentItems;
@property (nonatomic, strong) NSArray *filteredItems;
@property (nonatomic, strong) NSArray *allAirports;
@property (nonatomic, strong) NSArray *allBorders;
@property (nonatomic, strong) NSArray *allPorts;
@property (nonatomic, strong) NSArray *allCountries;
@property (nonatomic, copy) NSComparator countriesSortingComparator;
@property (nonatomic, copy) NSComparator airportsSortingComparator;
@property (nonatomic, strong) NSString *searchString;


@end

@implementation CBFakeLocationsViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.currentFakeLocationType = FakeLocationTypeDefault;
        
        self.countriesSortingComparator = ^NSComparisonResult (DMCountry *country1, DMCountry *country2) {
            return [[country1 ct_cellTitle] compare:[country2 ct_cellTitle]];
        };
        
        self.airportsSortingComparator = ^NSComparisonResult (DMCheckpoint *airport1, DMCheckpoint *airport2) {
            return [[airport1 ct_cellTitle] compare:[airport2 ct_cellTitle]];
        };
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateFakeLocationView];
    [self updateTableViewFrame];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self resetSearchString];
    [self.tableView reloadData];
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading....", nil) maskType:SVProgressHUDMaskTypeClear];
    
    [self loadCountriesAndAirportsWithCompletion:^{
        [self applyFilters];
        [self.tableView reloadData];
        
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Loaded", nil)];
    }];
}

- (void)configureView
{
    // cancel button
    UIBarButtonItem *cancelBarButtonItem;
    
    if ([[UIDevice currentDevice] systemVersionGreaterOrEqual:7.0f]) {
        cancelBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_close.png"]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(cancelButtonTapped:)];
    } else {
        cancelBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil)
                                                                                style:UIBarButtonItemStyleBordered
                                                                               target:self
                                                                               action:@selector(cancelButtonTapped:)];
    }
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = cancelBarButtonItem;
    
    // enableFakeLocationButton
    [self.enableFakeLocationButton setBackgroundImage:[[UIImage imageNamed:@"Bar-Button-Done"] resizableImageWithCapInsets:UIEdgeInsetsMake(0., 7., 0, 7.)] forState:UIControlStateNormal];
    self.enableFakeLocationButton.titleLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:13.f];
    
    // appearance
    [CBAppearance customizeViewController:self
                                withTitle:NSLocalizedString(@"Fake Location", nil)
                     leftBarBarButtonType:CBAppearanceButtonTypeNone
                       rightBarButtonType:CBAppearanceButtonTypeNone];
    
    self.disableFakeLocationLabel.font = [CBFontUtils droidSansFontBold:NO ofSize:14];
    self.currentFakeLocationLabel.font = [CBFontUtils droidSansFontBold:NO ofSize:14];
    self.disableFakeLocationButton.titleLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:14];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return LOCATION_TYPE_VIEW_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self createLocationTypeContentView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [DMManager enableFakeLocation:self.filteredItems[indexPath.row]];
    [self closeFakeLocationScreenFlow];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"fakeLocationCell";
    
    CBFakeLocationTableViewCell *cell = (CBFakeLocationTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [self updateContentForCell:cell withIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.searchString = searchText;
    [self applyFilters];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self resetSearchString];
    [self applyFilters];
    [self reloadTables];
}

#pragma mark - Actions

- (IBAction)cancelDidPress:(id)sender
{
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)locationTypeChanged:(UISegmentedControl *)sender
{
    self.currentFakeLocationType = sender.selectedSegmentIndex;
    [self applyFilters];
    [self reloadTables];
}

- (IBAction)disableFakeLocationButtonTapped:(id)sender
{
    [DMManager disableFakeLocation];
    [self closeFakeLocationScreenFlow];
}

#pragma mark - Private

- (void)cancelButtonTapped:(id)sender
{
    [self closeFakeLocationScreenFlow];
}

- (void)closeFakeLocationScreenFlow
{
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (UIView *)createLocationTypeContentView
{
    UIView *locationTypeContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, LOCATION_TYPE_VIEW_HEIGHT)];
    locationTypeContentView.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:0.8f];
    
    // segmented control
    UISegmentedControl *locationTypeSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Country", nil),
                                                                                                   NSLocalizedString(@"Airports", nil),
                                                                                                   NSLocalizedString(@"Borders", nil),
                                                                                                   NSLocalizedString(@"Ports", nil)]];
    locationTypeSegmentedControl.tintColor = [UIColor colorWithRed:0.09f green:0.27f blue:0.62f alpha:1];
    
    // segmented control
    [locationTypeSegmentedControl addTarget:self action:@selector(locationTypeChanged:) forControlEvents:UIControlEventValueChanged];
    locationTypeSegmentedControl.selectedSegmentIndex = self.currentFakeLocationType;
    
    locationTypeSegmentedControl.center = CGPointMake(CGRectGetWidth(locationTypeContentView.frame) / 2,
                                                      CGRectGetHeight(locationTypeContentView.frame) / 2);
    
    [locationTypeContentView addSubview:locationTypeSegmentedControl];
    
    // separator line
    UIView *separatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, LOCATION_TYPE_VIEW_HEIGHT - 1, CGRectGetWidth(locationTypeContentView.frame), 1)];
    separatorLine.backgroundColor = [UIColor colorWithRed:0.75f green:0.75f blue:0.75f alpha:0.8f];
    [locationTypeContentView addSubview:separatorLine];
    
    return locationTypeContentView;
}

- (void)loadCountriesAndAirportsWithCompletion:(void(^)())completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self loadCountries];
        [self loadAirports];
        [self loadBorders];
        [self loadPorts];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion();
            }
        });
    });
}

- (void)loadCountries
{
    self.allCountries = [[DMCountry countries] sortedArrayUsingComparator:self.countriesSortingComparator];
}

- (void)loadBorders
{
    self.allBorders = [[DMCheckpoint borders] sortedArrayUsingComparator:self.airportsSortingComparator];
}

- (void)loadPorts
{
    self.allPorts = [[DMCheckpoint ports] sortedArrayUsingComparator:self.airportsSortingComparator];
}

- (void)loadAirports
{
    self.allAirports = [[DMCheckpoint airports] sortedArrayUsingComparator:self.airportsSortingComparator];
}

- (void)applyFilters
{
    [self applyFakeLocationType];
    [self applySearchStringIfExists];
}

- (void)applyFakeLocationType
{
    if (self.currentFakeLocationType == FakeLocationTypeCountry) {
        self.currentItems = self.allCountries;
    } else if (self.currentFakeLocationType == FakeLocationTypeAirport) {
        self.currentItems = self.allAirports;
    } else if (self.currentFakeLocationType == FakeLocationTypeBorders) {
        self.currentItems = self.allBorders;
    } else if (self.currentFakeLocationType == FakeLocationTypePorts) {
        self.currentItems = self.allPorts;
    } else {
        self.currentItems = nil;
    }
}

- (void)updateContentForCell:(CBFakeLocationTableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    NSObject *locationItem = self.filteredItems[indexPath.row];
    
    // title
    if ([locationItem respondsToSelector:@selector(ct_cellTitle)]) {
        cell.title = [locationItem performSelector:@selector(ct_cellTitle)];
    } else {
        cell.title = @"";
    }
    
    // check
    if ([self isThisCurrentFakeLocation:locationItem]) {
        [cell showCheck];
    } else {
        [cell hideCheck];
    }
}

- (BOOL)isThisCurrentFakeLocation:(NSObject *)locationItem
{
    if (![DMManager fakeLocation] || !locationItem) {
        return NO;
    } else if ([(NSObject *)[DMManager fakeLocation] isEqual:locationItem]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)resetSearchString
{
    self.searchString = nil;
    [self applySearchStringIfExists];
}

- (void)applySearchStringIfExists
{
    if (self.searchString && (self.searchString.length > 0)) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ct_cellTitle CONTAINS[cd] %@", self.searchString];
        self.filteredItems = [self.currentItems filteredArrayUsingPredicate:predicate];
    } else {
        self.filteredItems = self.currentItems;
    }
}

- (void)reloadTables
{
    [self.tableView reloadData];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)updateFakeLocationView
{
    id fakeLocation = [DMManager fakeLocation];
    
    if (fakeLocation) {
        self.fakeLocationView.hidden = NO;
        
        if ([fakeLocation respondsToSelector:@selector(ct_cellTitle)]) {
            self.currentFakeLocationLabel.text = [fakeLocation performSelector:@selector(ct_cellTitle)];
        } else {
            self.currentFakeLocationLabel.text = @"";
        }
    } else {
        self.fakeLocationView.hidden = YES;
    }
}

- (void)updateTableViewFrame
{
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
                                      self.tableView.frame.origin.y,
                                      self.tableView.frame.size.width,
                                      self.view.frame.size.height - self.tableView.frame.origin.y - (self.fakeLocationView.hidden ? 0 : self.fakeLocationView.frame.size.height));
}

@end
