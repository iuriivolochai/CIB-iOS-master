//
//  CBAgentChatMessageTableViewCell.m
//  CIBBoomerang
//
//  Created by Artem Stepanenko on 6/12/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "CBAgentChatMessageTableViewCell.h"

@interface CBAgentChatMessageTableViewCell ()

@property (nonatomic, weak) IBOutlet UIImageView *backImageView;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;

@end

@implementation CBAgentChatMessageTableViewCell

- (void)setMessage:(NSString *)message
{
    self.messageLabel.text = message;
    
    self.messageLabel.frame = CGRectMake(0, 0, self.frame.size.width, 0);
    [self.messageLabel sizeToFit];
    
    CGFloat messageWidth = self.messageLabel.frame.size.width > 240 ? 240 : self.messageLabel.frame.size.width;
    
    self.messageLabel.frame = CGRectMake(
                                      40,
                                      (self.bounds.size.height - self.messageLabel.frame.size.height) / 2,
                                      messageWidth,
                                      self.messageLabel.frame.size.height);
    
    self.backImageView.frame = CGRectMake(
                                          self.messageLabel.frame.origin.x - 25,
                                          self.messageLabel.frame.origin.y - 5,
                                          self.messageLabel.frame.size.width + 35,
                                          self.messageLabel.frame.size.height + 10);
    
}

@end
