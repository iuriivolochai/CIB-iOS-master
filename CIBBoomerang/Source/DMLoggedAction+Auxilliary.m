//
//  DMLoggedAction+Auxilliary.m
//  CIBBoomerang
//
//  Created by Roma on 6/10/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "DMLoggedAction+Auxilliary.h"

@implementation DMLoggedAction (Auxilliary)

+ (NSString *)actionNameForIndex:(DMLoggedActionType)index
{
    return [kActionsName objectAtIndex:index];
}

@end
