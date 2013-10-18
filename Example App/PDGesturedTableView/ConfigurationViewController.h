//
//  ConfigurationViewController.h
//  PDGesturedTableView
//
//  Created by David Román Aguirre on 28/08/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PDGesturedTableView.h"

@interface ConfigurationViewController : UIViewController <PDGesturedTableViewSecondaryDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray * options;

@property (strong, nonatomic) UINavigationBar * navigationBar;
@property (strong, nonatomic) PDGesturedTableView * gesturedTableView;

@end
