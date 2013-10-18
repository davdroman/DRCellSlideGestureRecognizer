//
//  MainViewController.h
//  PDGesturedTableView
//
//  Created by David Román Aguirre on 27/08/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PDGesturedTableView.h"

@interface MainViewController : UIViewController <PDGesturedTableViewSecondaryDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray * strings;

@property (strong, nonatomic) UINavigationBar * navigationBar;
@property (strong, nonatomic) PDGesturedTableView * gesturedTableView;

@end