//
//  chatApp4ModelMock.h
//  CIBBoomerang
//
//  Created by Artem Stepanenko on 6/12/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface chatApp4ModelMock : NSObject

@property (nonatomic, copy) NSString *skill;
@property (nonatomic, copy) NSString *siteid;
@property (nonatomic, copy) NSString *uri;
@property (nonatomic, assign) BOOL translate;

- (id)init;
- (NSInteger)startChat:(NSString *)vn;
- (NSInteger)stopChat:(Boolean)clearChatLines;
- (NSMutableArray *)getLines;
- (NSInteger)sendLine:(NSString *)line;
- (Boolean)isAvailableForChat:(NSString *)agent;

@end
