//
//  CBCountriesListAlert.h
//  CIBBoomerang
//
//  Created by Artem Stepanenko on 5/7/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DMCountry;

typedef void (^CBCountriesListAlertDidSelectCountry) (DMCountry *country);

@interface CBCountriesListAlert : NSObject

- (void)showWithCompletion:(CBCountriesListAlertDidSelectCountry)completion;

@end
