//
//  MainViewController.h
//  PDGestureTableView
//
//  Created by David Román Aguirre on 27/08/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDGestureTableView;

@interface MainViewController : UIViewController <UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *strings;

@property (strong, nonatomic) PDGestureTableView *gestureTableView;

@end