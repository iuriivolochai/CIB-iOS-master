//
//  CBScannerViewController.m
//  CIBBoomerang
//
//  Created by Roma on 4/23/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBScannerViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "ZBarSDK.h"

#import "CBReachabilityObserver.h"
#import "DMManager.h"

NSString * const ScannerViewControllerStoryboardId = @"Scanner View Controller";

@interface CBScannerViewController () <ZBarReaderViewDelegate>

@property (weak, nonatomic) IBOutlet ZBarReaderView *readerView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UILabel *instructionsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end

@implementation CBScannerViewController

+ (void)load
{
    [ZBarReaderView class];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.readerView start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View Configuration

- (void)configureView
{
    if (![[UIDevice currentDevice] systemVersionGreaterOrEqual:7.0f]) {
        [self.cancelButton setBackgroundImage:[[UIImage imageNamed:@"Bar-Button-Done"] resizableImageWithCapInsets:UIEdgeInsetsMake(0., 7., 0, 7.)] forState:UIControlStateNormal];
        self.backgroundImageView.image = [[UIImage imageNamed:@"bg-navigation-bar-pattern.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 5, 2, 5)];
    }
    
    self.instructionsLabel.font = [CBFontUtils droidSansFontBold:NO ofSize:17.f];
    self.instructionsLabel.text = NSLocalizedString(@"SCANNER_INSTRUCTIONS_TEXT", nil);
    self.cancelButton.titleLabel.font = [CBFontUtils droidSansFontBold:YES ofSize:17.f];
    [self configureReader];
	[self configureOverlayView];
}

- (void)configureReader
{
    self.readerView.readerDelegate = self;
    ZBarImageScanner *scanner = self.readerView.scanner;
    [scanner setSymbology:ZBAR_QRCODE
                   config:ZBAR_CFG_ENABLE
                       to:1];
    self.readerView.trackingColor = [UIColor yellowColor];
}

- (void)configureOverlayView
{
	self.overlayView.layer.borderWidth = 2.f;
	self.overlayView.layer.borderColor = [UIColor orangeColor].CGColor;    
}

#pragma mark - IBActions

- (IBAction)cancelButtonTapped:(UIButton *)sender
{
    [self.readerView stop];
}

#pragma mark - ZBarReaderViewDelegate

- (void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image
{
    ZBarSymbol *symbol = nil;
    NSString *hiddenData;
    for(symbol in symbols) {
        hiddenData = [NSString stringWithString:symbol.data];
	}
    
    NSMutableString *resString = [[NSMutableString alloc] initWithString:hiddenData];
    NSRange range = [hiddenData rangeOfString:@"}"];
    if (range.location != NSNotFound) {
        NSString *str = [resString substringToIndex:range.location];
        resString = [[NSMutableString alloc] initWithString:str];
        [resString deleteCharactersInRange:NSMakeRange(0, 1)];
    }
    
    if (resString.length) {
        [CBSoundUtils playSound:CBSystemSoundTypeTick];
        [self.delegate scannerViewController:self didRecognizeQRCodeWithString:resString];
        [DMManager carnetQRScannedWithGUID:resString];
    }
    else {
        [CBSoundUtils playSound:CBSystemSoundTypeError];
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : NSLocalizedString(@"QR-code recognition failed. Unknow QR-code format", nil)};
        NSError *error = [[NSError alloc] initWithDomain:CONNECTION_MANAGER_DOMAIN code:1000 userInfo:userInfo];
        [self.delegate scannerViewController:self didCancelScannigManually:NO withError:error];
    }
}

- (void)readerViewDidStart:(ZBarReaderView *)readerView
{
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//#warning tempo
//	99ac1bd3-2ee4-4d7d-9b13-5eb638e18916
//#ifdef DEBUG
//    6ff023ac-c5a9-49e6-9cc9-f81d9b99d982
//    55eec5f2-fd75-4112-b94b-a1a6f8bfcf00
//    98f40599-d53a-4f75-9a41-11f03ccc4431
//    [self.delegate scannerViewController:self didRecognizeQRCodeWithString:@"98f40599-d53a-4f75-9a41-11f03ccc4431"];
//#endif
}

- (void)readerView:(ZBarReaderView *)readerView didStopWithError:(NSError *)error
{
    [self.delegate scannerViewController:self didCancelScannigManually:(error == nil) withError:error];
}

@end
