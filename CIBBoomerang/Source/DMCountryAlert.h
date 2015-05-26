//
//  DMCountryAlert.h
//  CIBBoomerang
//
//  Created by Roma on 9/3/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DMCountry;

@interface DMCountryAlert : NSManagedObject

@property (nonatomic) NSTimeInterval showingDate;
@property (nonatomic) BOOL shown;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) DMCountry *country;

@end
