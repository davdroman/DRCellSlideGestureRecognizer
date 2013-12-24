//
//  MainNavigationBar.m
//  PDGesturedTableView
//
//  Created by David Román Aguirre on 22/12/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import "MainNavigationBar.h"

@implementation MainNavigationBar

- (id)init {
    if (self = [super init]) {
        UINavigationItem * item = [UINavigationItem new];
        [item setTitle:@"PDGesturedTableView"];

        item.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settingsIcon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(didTapLeftButton:)];
        item.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didTapRightButton:)];
        
        [self setItems:@[item]];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (void)didTapLeftButton:(UIButton *)button {
    if (self.didTapLeftButtonBlock) self.didTapLeftButtonBlock(self);
}

- (void)didTapRightButton:(UIButton *)button {
    if (self.didTapRightButtonBlock) self.didTapRightButtonBlock(self);
}

@end
