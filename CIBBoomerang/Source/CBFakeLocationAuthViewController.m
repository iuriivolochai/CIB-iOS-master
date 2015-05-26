//
//  CBFakeLocationAuthViewController.m
//  CIBBoomerang
//
//  Created by Artem Stepanenko on 10/15/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBFakeLocationAuthViewController.h"

@interface CBFakeLocationAuthViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UILabel *passwordTitleLabel;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;

@end

@implementation CBFakeLocationAuthViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.passwordTitleLabel setFont:[CBFontUtils droidSansFontBold:NO ofSize:17]];
    [self.passwordTextField setFont:[CBFontUtils droidSansFontBold:NO ofSize:17]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.passwordTextField.text = @"";
    [self.passwordTextField becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.text isEqualToString:@"fake"]) { // TODO: move to key chain
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"CBFakeLocationsViewController"] animated:YES];
    }
    
    return NO;
}

#pragma mark - Actions

- (IBAction)cancelDidPress:(id)sender
{
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private

@end
