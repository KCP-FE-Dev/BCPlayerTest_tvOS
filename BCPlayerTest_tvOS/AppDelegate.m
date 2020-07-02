//
//  AppDelegate.m
//  BCPlayerTest_tvOS
//
//  Created by 신승환 on 2020/07/02.
//  Copyright © 2020 신승환. All rights reserved.
//

#import "AppDelegate.h"

@import KCPSDK;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    //BrightCove Player
    NSString *customerToken = @"tDlwutBf4Xu8mfUPH7RFNRxCvuuwyZ92SLHVPZZ5U6VTMT66";// @"9nBB2Boc5PKDMhRUcs87gr8yXDEE761FYLv8HExwUs1UfnjY";
    [Kcp loginWithToken:customerToken completion:^(NSError * _Nullable error) {
        if (error)
        {
            NSLog(@"[BCP] Kcp init error");
            NSLog(@"[BCP] Description %@", [error description]);
        }
        else
        {
            NSLog(@"[BCP] Kcp init correctly");
        }
    }];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


@end
