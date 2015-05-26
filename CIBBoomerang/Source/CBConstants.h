//
//  CBConstants.h
//  CIBBoomerang
//
//  Created by Roma on 5/27/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CONNECTION_MANAGER_DOMAIN (ACTIVE_SERVER_PROVIDES_CERTIFICATE == 0) ? @"com.waverley.connection" : @"ws.atacarnet.com"
#define HOST_NAME (ACTIVE_SERVER_PROVIDES_CERTIFICATE == 0)                 ? @"com.waverley.connection" : @"ws.atacarnet.com"