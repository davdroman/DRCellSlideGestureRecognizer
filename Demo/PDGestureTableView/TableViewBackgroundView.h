//
//  TableViewBackgroundView.h
//  PDGestureTableView
//
//  Created by David Román Aguirre on 22/12/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewBackgroundView : UIView

@property (copy, nonatomic) void (^didTapTweetButtonBlock)(void);

@end
