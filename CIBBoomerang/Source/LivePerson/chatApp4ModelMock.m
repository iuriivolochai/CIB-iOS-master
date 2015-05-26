//
//  chatApp4ModelMock.m
//  CIBBoomerang
//
//  Created by Artem Stepanenko on 6/12/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import "chatApp4ModelMock.h"

#import "chatApp4Model.h"
#import "chatApp4Message.h"

@interface chatApp4ModelMock ()

@property (nonatomic, readonly) NSMutableArray *lines;

@property (nonatomic, retain) NSTimer *addSystemMessageTimer;

@end

@implementation chatApp4ModelMock

@synthesize lines;

//- (id)init
//{
//    self = [super init];
//    
//    if (self) {
//        // TODO
//    }
//    
//    return self;
//}

- (id)init
{
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

- (NSInteger)startChat:(NSString *)vn
{
    self.addSystemMessageTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(addSystemMessage) userInfo:nil repeats:YES];
    
    return 201;
}

- (NSInteger)stopChat:(Boolean)clearChatLines
{
    if (self.addSystemMessageTimer) {
        if (self.addSystemMessageTimer.isValid) {
            [self.addSystemMessageTimer invalidate];
        }
        
        self.addSystemMessageTimer = nil;
    }
    
    if (clearChatLines) {
        [self.lines removeAllObjects];
    }
    
    return 201;
}

- (NSMutableArray *)getLines
{
    return self.lines;
}

- (NSInteger)sendLine:(NSString *)line
{
    chatApp4Message *newMessage = [[chatApp4Message alloc] init];
	newMessage.line = line;
	newMessage.visitor = YES;
    [self.lines addObject:newMessage];
    
    return 201;
}

- (Boolean)isAvailableForChat:(NSString *)agent
{
    return YES;
}

#pragma mark Private

- (void)addSystemMessage
{
    chatApp4Message *newMessage = [[chatApp4Message alloc] init];
	newMessage.line = @"System messagea sdgfasghahrgaehrghxc nvbdearga eirhagxcvba aidrgt aia";
	newMessage.system = YES;
    [self.lines addObject:newMessage];
}

- (NSMutableArray *)lines
{
    if (!lines) {
        lines = [[NSMutableArray alloc] init];
    }
    
    return lines;
}

@end
