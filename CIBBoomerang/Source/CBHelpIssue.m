//
//  CBHelpIssueData.m
//  CIBBoomerang
//
//  Created by Daria Kopaliani on 5/29/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBHelpIssue.h"


@implementation CBHelpIssue

+ (CBHelpIssue *)issueWithTitle:(NSString *)title description:(NSString *)description
{
    return [[self alloc] initWithTitle:title description:description];
}

- (id)initWithTitle:(NSString *)title description:(NSString *)description
{
    self = [super init];
    if (self) {
        self.title = title;
        self.issueDescription = description;
    }
    return self;
}

@end