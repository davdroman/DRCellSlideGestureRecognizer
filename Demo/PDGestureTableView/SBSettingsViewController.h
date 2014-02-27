//
//  SBSettingsViewController.h
//  PDGestureTableView
//
//  Created by David Román Aguirre on 03/01/14.
//  Copyright (c) 2014 David Román Aguirre. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDGestureTableView;

@interface SBSettingsViewController : UITableViewController {
    UIColor *greenColor;
}

@property (strong, nonatomic) NSArray *options;

- (IBAction)dismissViewController:(id)sender;

@end
