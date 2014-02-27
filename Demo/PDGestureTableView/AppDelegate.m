//
//  AppDelegate.m
//  PDGestureTableView
//
//  Created by David Román Aguirre on 30/12/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import "AppDelegate.h"

#import "MainViewController.h"
#import "PDGestureTableView.h"

@implementation AppDelegate

- (id)init {
    if (self = [super init]) {
        self.window = [UIWindow new];
    }
    
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSDictionary *defaults = @{@"option1": @YES,
                                @"option2": @YES,
                                @"option3": @YES,
                                @"option4": @NO,
                                @"option5": @NO};
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    
    [self.window setFrame:[[UIScreen mainScreen] bounds]];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    
    // Code implementation
    // [self.window setRootViewController:[[UINavigationController alloc] initWithRootViewController:[MainViewController new]]];
    
    // Storyboard implementation
    [self.window setRootViewController:[[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController]];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
