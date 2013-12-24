//
//  MainViewController.h
//  PDGesturedTableView
//
//  Created by David Román Aguirre on 27/08/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainNavigationBar;
@class PDGesturedTableView;

@interface MainViewController : UIViewController <UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray * strings;

@property (strong, nonatomic) MainNavigationBar * navigationBar;
@property (strong, nonatomic) PDGesturedTableView * gesturedTableView;

@end