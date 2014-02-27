//
//  SettingsViewController.h
//  PDGestureTableView
//
//  Created by David Román Aguirre on 28/08/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDGestureTableView;

@interface SettingsViewController : UIViewController <UITableViewDataSource> {
    UIColor *greenColor;
}

@property (strong, nonatomic) NSArray *options;

@property (strong, nonatomic) PDGestureTableView *gestureTableView;

@end
