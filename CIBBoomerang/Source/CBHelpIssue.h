//
//  CBHelpIssueData.h
//  CIBBoomerang
//
//  Created by Daria Kopaliani on 5/29/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CBHelpIssue : NSObject

@property (strong, nonatomic) NSString *issueDescription;
@property (strong, nonatomic) NSString *title;

+ (CBHelpIssue *)issueWithTitle:(NSString *)title description:(NSString *)description;
- (id)initWithTitle:(NSString *)title description:(NSString *)description;

@end
