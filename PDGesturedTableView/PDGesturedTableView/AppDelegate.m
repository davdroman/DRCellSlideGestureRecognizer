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
    MainViewController * mainViewController = [MainViewController new];
    
    [self.window setRootViewController:mainViewController];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
