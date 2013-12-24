//
//  SettingsNavigationBar.h
//  PDGesturedTableView
//
//  Created by David Román Aguirre on 23/12/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsNavigationBar : UINavigationBar

@property (copy, nonatomic) void (^didTapRightButtonBlock)(SettingsNavigationBar *);

@end
