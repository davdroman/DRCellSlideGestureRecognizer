//
//  MainNavigationBar.h
//  PDGesturedTableView
//
//  Created by David Román Aguirre on 22/12/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainNavigationBar : UINavigationBar

@property (strong, nonatomic) void (^didTapLeftButtonBlock)(MainNavigationBar *);
@property (strong, nonatomic) void (^didTapRightButtonBlock)(MainNavigationBar *);

@end
