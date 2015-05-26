//
//  CBChatMessagesDateTableViewCell.m
//  CIBBoomerang
//
//  Created by Artem Stepanenko on 6/12/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBChatMessagesDateTableViewCell.h"
#import "CBDateConvertionUtils.h"

@interface CBChatMessagesDateTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

@end

@implementation CBChatMessagesDateTableViewCell

- (void)setDate:(NSDate *)date
{
    self.dateLabel.text =  [CBDateConvertionUtils chatDateStringFromDate:date];
}

@end
