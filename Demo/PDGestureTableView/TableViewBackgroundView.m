//
//  TableViewBackgroundView.m
//  PDGestureTableView
//
//  Created by David Román Aguirre on 22/12/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import "TableViewBackgroundView.h"

#import <Masonry.h>

@implementation TableViewBackgroundView

- (id)init {
    if (self = [super init]) {
        UILabel *congratsLabel = [UILabel new];
        [congratsLabel setBackgroundColor:[UIColor clearColor]];
        [congratsLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
        [congratsLabel setText:@"Congrats! You've just discovered PDGestureTableView :D"];
        [congratsLabel setNumberOfLines:2];
        [congratsLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:congratsLabel];
        
        [congratsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.right.equalTo(@0);
            make.centerY.equalTo(self);
        }];
        
        UIButton *tweetButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [tweetButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
        [tweetButton setTitle:@"Tweet" forState:UIControlStateNormal];
        [tweetButton addTarget:self action:@selector(didTapTweetButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:tweetButton];
        
        [tweetButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.right.equalTo(@0);
            make.bottom.equalTo(@-10);
            make.height.equalTo(@44);
        }];
    }
    
    return self;
}

- (void)didTapTweetButton:(UIButton *)button {
    if (self.didTapTweetButtonBlock) self.didTapTweetButtonBlock();
}

@end
