//
//  main.m
//  CIBBoomerang
//
//  Created by Roma on 4/23/13.
//  Copyright (c) 2013 Roma. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CBAppDelegate.h"
#import "lecore.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        le_init();
        le_set_token("b5e8b525-4af6-42d9-b1b0-a23b710b953d");
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([CBAppDelegate class]));
    }
}
