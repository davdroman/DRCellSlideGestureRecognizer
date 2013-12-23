//
//  SettingsNavigationBar.m
//  PDGesturedTableView
//
//  Created by David Román Aguirre on 23/12/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import "SettingsNavigationBar.h"

@implementation SettingsNavigationBar

- (id)init {
    if (self = [super init]) {
        UINavigationItem * item = [UINavigationItem new];
        [item setTitle:@"Example Settings"];
        item.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(didTapRightButton:)];
        
        [self setItems:@[item]];
    }
    
    return self;
}

- (void)didTapRightButton:(UIBarButtonItem *)barButton {
    if (self.didTapRightButtonBlock) self.didTapRightButtonBlock(self);
}

@end
