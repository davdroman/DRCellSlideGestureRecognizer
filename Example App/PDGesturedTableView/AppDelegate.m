//
//  AppDelegate.m
//  PDGesturedTableView
//
//  Created by David Román Aguirre on 27/08/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import "AppDelegate.h"

#import "MainViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSDictionary * defaults = @{@"option1": @YES,
                                @"option2": @YES,
                                @"option3": @YES,
                                @"option4": @NO,
                                @"option5": @NO};
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    [self.window setRootViewController:[MainViewController new]];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end