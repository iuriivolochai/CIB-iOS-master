//
//  CBCountriesListAlert.m
//  CIBBoomerang
//
//  Created by Artem Stepanenko on 5/7/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBCountriesListAlert.h"
#import "DMCountry.h"
#import "DMCountry+Auxilliary.h"
#import "SBTableAlert.h"

@interface CBCountriesListAlert () <SBTableAlertDataSource, SBTableAlertDelegate>

@property (nonatomic, assign) BOOL isBusy;
@property (nonatomic, strong) SBTableAlert *tableAlert;
@property (nonatomic, strong, readonly) NSArray *countries;
@property (nonatomic, strong) NSIndexPath *checkedIndexPath;
@property (nonatomic, strong) CBCountriesListAlertDidSelectCountry completion;

- (void)resetCountries;

@end

@implementation CBCountriesListAlert

@synthesize isBusy;
@synthesize tableAlert;
@synthesize countries;
@synthesize checkedIndexPath;

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.isBusy = NO;
    }
    
    return self;
}

- (void)showWithCompletion:(CBCountriesListAlertDidSelectCountry)completion
{
    if (self.isBusy)
    {
        if (completion)
        {
            completion(nil);
        }
    }
    
    self.isBusy = YES;
    self.completion = completion;
    
    self.checkedIndexPath = nil;
    [self resetCountries];
    
    self.tableAlert = [[SBTableAlert alloc] initWithTitle:@"Select the country you\nplan to visit next:"
                                        cancelButtonTitle:nil
                                            messageFormat:nil];
    
    [[tableAlert view] addButtonWithTitle:@"Select"];
    [tableAlert setType:SBTableAlertTypeMultipleSelct];
    tableAlert.delegate = self;
    tableAlert.dataSource = self;
    [tableAlert show];
}

#pragma mark - SBTableAlertDelegate

- (void)tableAlert:(SBTableAlert *)tableAlert didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[self.tableAlert tableView] deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.checkedIndexPath)
    {
        if ([self.checkedIndexPath isEqual:indexPath])
        {
            return;
        }
        
        UITableViewCell *prevCheckedCell = [[self.tableAlert tableView] cellForRowAtIndexPath:self.checkedIndexPath];
        prevCheckedCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    self.checkedIndexPath = indexPath;
    UITableViewCell *curCheckedCell = [[self.tableAlert tableView] cellForRowAtIndexPath:self.checkedIndexPath];
    curCheckedCell.accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)tableAlertCancel:(SBTableAlert *)tableAlert
{
    if (self.completion)
    {
        self.completion(nil);
    }
}

- (void)tableAlert:(SBTableAlert *)tableAlert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.checkedIndexPath)
    {
        if (self.completion)
        {
            self.completion(self.countries[self.checkedIndexPath.row]);
        }
    }
    else
    {
        if (self.completion)
        {
            self.completion(nil);
        }
    }
}

#pragma mark - SBTableAlertDataSource

- (UITableViewCell *)tableAlert:(SBTableAlert *)tableAlert cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CountryCellIdentifier";
    UITableViewCell *cell = [[[self tableAlert] tableView] dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // checked or not?
    if (self.checkedIndexPath && [self.checkedIndexPath isEqual:indexPath])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    // set country name
    DMCountry *country = (DMCountry *)self.countries[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [country identifier], [country name]];
    
    return cell;
}

- (NSInteger)tableAlert:(SBTableAlert *)tableAlert numberOfRowsInSection:(NSInteger)section
{
    return [self.countries count];
}

#pragma mark - Private

- (void)resetCountries
{
    countries = nil;
}

- (NSArray *)countries
{
    if (!countries)
    {
        countries = [DMCountry countries];
    }
    
    return countries;
}

@end
