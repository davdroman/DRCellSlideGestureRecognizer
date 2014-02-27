//
//  SBMainViewController.h
//  PDGestureTableView
//
//  Created by David Román Aguirre on 03/01/14.
//  Copyright (c) 2014 David Román Aguirre. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDGestureTableView;

@interface SBMainViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *strings;

- (IBAction)addCell:(id)sender;

@end
