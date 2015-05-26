//
//  DMLoggedAction.h
//  CIBBoomerang
//
//  Created by Roma on 6/10/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DMLoggedAction : NSManagedObject

@property (nonatomic) int16_t index;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * carnetGUID;
@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic) NSTimeInterval date;
@property (nonatomic, retain) NSString * deiviceID;
@property (nonatomic, retain) NSString * data;

@end
