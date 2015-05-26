//
//  AppDelegate.m
//  DRCellSlideGestureRecognizerDemo
//
//  Created by David Román Aguirre on 12/5/15.
//
//

#import "AppDelegate.h"

#import "TableViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	self.window.backgroundColor = [UIColor whiteColor];
	self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[TableViewController new]];
	[self.window makeKeyAndVisible];
	
	return YES;
}

@end
