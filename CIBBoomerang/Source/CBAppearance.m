//
//  DCAppearance.m
//  PwC
//
//  Created by Roman on 2/26/13.
//  Copyright (c) 2013 Roman. All rights reserved.
//

#import "CBAppearance.h"
#import  <QuartzCore/QuartzCore.h>

@implementation CBAppearance

#pragma mark Bar Button Item
+ (UIImage *)barButtonBackgroundForState:(UIControlState )state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics
{
    NSString *name = @"Bar-Button";
    if (style == UIBarButtonItemStyleDone) {
        name = [name stringByAppendingString:@"-Done"];
    }
    if (barMetrics == UIBarMetricsLandscapePhone) {
        name = [name stringByAppendingString:@"-Landscape"];
    }
    if (state == UIControlStateHighlighted) {
        name = [name stringByAppendingString:@"-Highlighted"];
    }
    if (state == UIControlStateDisabled) {
        name = [name stringByAppendingString:@"-Disabled"];
    }
    UIImage *image = [UIImage imageNamed:name];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 7.0, 0.0, 7.0)];
    return image;
}

+ (UIImage *)backBackgroundForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics
{
    NSString *name = @"Bar-Back-Button";
    if (barMetrics == UIBarMetricsLandscapePhone) {
        name = [name stringByAppendingString:@"-Landscape"];
    }
    if (state == UIControlStateHighlighted) {
        name = [name stringByAppendingString:@"-Highlighted"];
    }
    UIImage *image = [UIImage imageNamed:name];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 7.0, 0.0, 7.0)];
    return image;
}

#pragma mark Navigation Bar
+ (UIImage *)navigationBackgroundForBarMetrics:(UIBarMetrics)metrics
{
    NSString *name = @"bg-navigation-bar-pattern.png";
    if (metrics == UIBarMetricsLandscapePhone) {
        name = [name stringByAppendingString:@"-Landscape"];
    }
    UIImage *image = [UIImage imageNamed:name];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)];
    return image;
}

+ (UIImage *)navigationShadow
{
    return [UIImage imageNamed:@"bg-shadow-navBar"];
}

#pragma mark - Toolbar

+ (UIImage *)toolbarBackgroundForBarMetrics:(UIBarMetrics)metrics
{
    NSString *name = @"bg-navigation-bar-pattern";
    if (metrics == UIBarMetricsLandscapePhone) {
        name = [name stringByAppendingString:@"-Landscape"];
    }
    UIImage *image = [UIImage imageNamed:name];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)];
    return image;
}


+ (void)custimzeNavigationBar
{
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    
    if ([[UIDevice currentDevice] systemVersionGreaterOrEqual:7.0f]) {
        // title
        [navigationBarAppearance setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:[CBFontUtils droidSansFontBold:YES ofSize:17.f], UITextAttributeFont, nil]];
        
        // buttons
        [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[CBFontUtils droidSansFontBold:NO ofSize:17.f], UITextAttributeFont, nil]
                                                    forState:UIControlStateNormal];
    } else {
        [navigationBarAppearance setBackgroundImage:[CBAppearance navigationBackgroundForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
        [navigationBarAppearance setBackgroundImage:[CBAppearance navigationBackgroundForBarMetrics:UIBarMetricsLandscapePhone] forBarMetrics:UIBarMetricsLandscapePhone];
        
        //    Bar button
        UIBarButtonItem *barButtonItemAppearance = [UIBarButtonItem appearance];
        //    Bar button bordered
        if ([[UIDevice currentDevice] systemVersionGreaterOrEqual:6.0f]) {
            [barButtonItemAppearance setBackgroundImage:[CBAppearance barButtonBackgroundForState:UIControlStateNormal style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsDefault] forState:UIControlStateNormal style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsDefault];
            [barButtonItemAppearance setBackgroundImage:[CBAppearance barButtonBackgroundForState:UIControlStateHighlighted style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsDefault] forState:UIControlStateHighlighted style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsDefault];
            [barButtonItemAppearance setBackgroundImage:[CBAppearance barButtonBackgroundForState:UIControlStateNormal style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsLandscapePhone] forState:UIControlStateNormal style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsLandscapePhone];
            [barButtonItemAppearance setBackgroundImage:[CBAppearance barButtonBackgroundForState:UIControlStateHighlighted style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsLandscapePhone] forState:UIControlStateHighlighted style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsLandscapePhone];
            
            //    Bar button done
            [barButtonItemAppearance setBackgroundImage:[CBAppearance barButtonBackgroundForState:UIControlStateNormal style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsDefault] forState:UIControlStateNormal style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsDefault];
            [barButtonItemAppearance setBackgroundImage:[CBAppearance barButtonBackgroundForState:UIControlStateHighlighted style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsDefault] forState:UIControlStateHighlighted style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsDefault];
            [barButtonItemAppearance setBackgroundImage:[CBAppearance barButtonBackgroundForState:UIControlStateNormal style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsLandscapePhone] forState:UIControlStateNormal style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsLandscapePhone];
            [barButtonItemAppearance setBackgroundImage:[CBAppearance barButtonBackgroundForState:UIControlStateHighlighted style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsLandscapePhone] forState:UIControlStateHighlighted style:UIBarButtonItemStyleDone barMetrics:UIBarMetricsLandscapePhone];
            
            //    Bar button Back
            [barButtonItemAppearance setBackButtonBackgroundImage:[CBAppearance backBackgroundForState:UIControlStateNormal barMetrics:UIBarMetricsDefault] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
            [barButtonItemAppearance setBackButtonBackgroundImage:[CBAppearance backBackgroundForState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
            [barButtonItemAppearance setBackButtonBackgroundImage:[CBAppearance backBackgroundForState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone] forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
            [barButtonItemAppearance setBackButtonBackgroundImage:[CBAppearance backBackgroundForState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone] forState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone];
            
            NSMutableDictionary *barButttonNormalTextAttributes = [[NSMutableDictionary alloc] init];
            [barButttonNormalTextAttributes setObject:[NSValue valueWithCGSize:CGSizeMake(0, 0)] forKey:UITextAttributeTextShadowOffset];
        }
    }
}

+ (void)customizeToolbar
{
    if (![[UIDevice currentDevice] systemVersionGreaterOrEqual:7.0f]) {
        UIToolbar *toolbarAppearance = [UIToolbar appearance];
        [toolbarAppearance setBackgroundImage:[CBAppearance toolbarBackgroundForBarMetrics:UIBarMetricsDefault]
                           forToolbarPosition:UIToolbarPositionAny
                                   barMetrics:UIBarMetricsDefault];
        [toolbarAppearance setBackgroundImage:[CBAppearance toolbarBackgroundForBarMetrics:UIBarMetricsLandscapePhone]
                           forToolbarPosition:UIToolbarPositionAny
                                   barMetrics:UIBarMetricsLandscapePhone];
    }
}

+ (NSArray *)getControllers:(UIViewController *)controller barButtonsForType:(CBAppearanceButtonType)buttonType
{
    switch (buttonType) {
        case CBAppearanceButtonTypeBack: {
            UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                               target:nil
                                               action:nil];
            negativeSpacer.width = -5;
            UIButton* backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [backBtn setImage:[UIImage imageNamed:@"icon-back"] forState:UIControlStateNormal];
            [backBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
            [backBtn addTarget:controller action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [backBtn setFrame:CGRectMake(0, 0, 45.f, 45.f)];
            UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
            return @[negativeSpacer, backBarButtonItem];
        }
            break;
        case CBAppearanceButtonTypeHelp: {
            UIButton *helpBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.f, 0.f, 60.f, 30.f)];
            [helpBtn setTitle:NSLocalizedString(@"Help", nil) forState:UIControlStateNormal];
            [helpBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [helpBtn addTarget:controller action:@selector(helpButtonTapped:)
              forControlEvents:UIControlEventTouchUpInside];
            [helpBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:12.f]];
            [helpBtn setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-pattern-top.png"]]];
            helpBtn.layer.borderColor = [UIColor whiteColor].CGColor;
            helpBtn.layer.borderWidth = 1.0f;
            helpBtn.layer.cornerRadius = 5.f;
            
            [helpBtn setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-pattern-top.png"]]];
            UIBarButtonItem *helpBarButtomItem = [[UIBarButtonItem alloc] initWithCustomView:helpBtn];
            return @[helpBarButtomItem];
        }
            break;
        case CBAppearanceButtonTypeSettings: {
            UIButton *settingBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30.f)];
            [settingBtn setTitle:NSLocalizedString(@"Settings", nil) forState:UIControlStateNormal];
            [settingBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [settingBtn addTarget:controller action:@selector(settingsButtonTapped:)
                 forControlEvents:UIControlEventTouchUpInside];
            [settingBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:12.f]];
            [settingBtn setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-pattern-top.png"]]];
            settingBtn.layer.borderColor = [UIColor whiteColor].CGColor;
            settingBtn.layer.borderWidth = 1.0f;
            settingBtn.layer.cornerRadius = 5.f;
            
            UIBarButtonItem *settingsBarButtomItem = [[UIBarButtonItem alloc] initWithCustomView:settingBtn];
            return @[settingsBarButtomItem];
        }
            break;
        default: {
            return nil;
        }
            break;
    }
}

#pragma mark - Public Methods

+ (void)customizeViewController:(UIViewController *)controller
                      withTitle:(NSString *)title
           leftBarBarButtonType:(CBAppearanceButtonType)left
             rightBarButtonType:(CBAppearanceButtonType)right
{
    /* center label */
    if ([[UIDevice currentDevice] systemVersionGreaterOrEqual:7.0f]) {
        controller.title = title;
    } else {
        UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(0.0f, 0.f, 180.f, 44.f)];
        [label setTextColor:[UIColor whiteColor]];
        [label setFont:[UIFont boldSystemFontOfSize:20.f]];
        [label setMinimumFontSize:10];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        label.text = title;
        controller.navigationItem.titleView = label;
    }
    
    NSArray *rightArray = [CBAppearance getControllers:controller barButtonsForType:right];
    if (rightArray.count)
        controller.navigationItem.rightBarButtonItems = rightArray;
    
    NSArray *leftArray = [CBAppearance getControllers:controller barButtonsForType:left];
    if (leftArray.count && ([UIDevice currentDevice].systemVersion.floatValue < 6.0))
        controller.navigationItem.leftBarButtonItems = leftArray;
}

+ (void)customizeAppearance
{
    [CBAppearance custimzeNavigationBar];
    [CBAppearance customizeToolbar];
}

@end
