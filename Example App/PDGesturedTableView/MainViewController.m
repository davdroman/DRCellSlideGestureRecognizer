//
//  MainViewController.m
//  PDGesturedTableView
//
//  Created by David Román Aguirre on 27/08/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import "MainViewController.h"

#import <Social/Social.h>
#import <Masonry.h>

#import "MainNavigationBar.h"
#import "PDGesturedTableView.h"
#import "TableViewBackgroundView.h"

#import "SettingsViewController.h"

@implementation MainViewController

- (id)init {
    if (self = [super init]) {
        self.strings = [NSMutableArray new];
        
        self.navigationBar = [MainNavigationBar new];
        self.gesturedTableView = [PDGesturedTableView new];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self setupView];
    [self setupConstraints]; // Applies Autolayout constraints through a great framework called Masonry. If you don't know it yet, I totally recommend it ;)
}

- (void)setup {
    [self.strings addObjectsFromArray:@[@"Swipe right at different lengths",
                                        @"You can also swipe left",
                                        @"Swipe some cells at once, too!",
                                        @"Tap and hold a cell to move it",
                                        @"Finally, swipe all cells"]];
    
    __unsafe_unretained typeof(self) _self = self; // This prevents retain cycles in the following blocks.
    
    [self.navigationBar setDidTapLeftButtonBlock:^(MainNavigationBar * navigationBar) {
        [_self presentViewController:[SettingsViewController new] animated:YES completion:nil];
    }];
    
    [self.navigationBar setDidTapRightButtonBlock:^(MainNavigationBar * navigationBar) {
        [_self.strings addObject:[NSString stringWithFormat:@"Cell %i", _self.strings.count+1]];
        [_self.gesturedTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_self.strings.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
    }];
    
    [self.gesturedTableView setBackgroundColor:[UIColor colorWithWhite:0.96 alpha:1]];
    [self.gesturedTableView setDataSource:self];
    [self.gesturedTableView setRowHeight:60];
    
    [self.gesturedTableView setDidMoveCellFromIndexPathToIndexPathBlock:^(NSIndexPath * fromIndexPath, NSIndexPath * toIndexPath) {
        [_self.strings exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
    }];
    
    // Gestured Table View "backgroundView" setup (the view that will automatically show up when there're no cells on the table view).
    
    TableViewBackgroundView * backgroundView = [TableViewBackgroundView new];
    
    [backgroundView setDidTapTweetButtonBlock:^{
        SLComposeViewController * tweetComposerViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetComposerViewController setInitialText:@"I've just discovered PDGesturedTableView by @Dromaguirre and it's awesome! You should check it out!"];
        [tweetComposerViewController addURL:[NSURL URLWithString:@"http://github.com/Dromaguirre/PDGesturedTableView"]];
        [_self presentViewController:tweetComposerViewController animated:YES completion:nil];
    }];
    
    [self.gesturedTableView setBackgroundView:backgroundView];
}

- (void)setupView {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:self.navigationBar];
    [self.view insertSubview:self.gesturedTableView belowSubview:self.navigationBar];
}

- (void)setupConstraints {
    [self.navigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.height.equalTo(@64);
    }];
    
    [self.gesturedTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navigationBar.mas_bottom);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.bottom.equalTo(@0);
    }];
}

#pragma mark UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.strings count];
}

- (UITableViewCell *)tableView:(PDGesturedTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIdentifier = @"Cell";
    
    PDGesturedTableViewCell * cell = (PDGesturedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        __unsafe_unretained typeof(self) _self = self;
        
        // The following block is used for all cells as all of them do the same thing in this case: dismissing.
        
        void (^removeCellBlock)(PDGesturedTableView *, PDGesturedTableViewCell *) = ^(PDGesturedTableView * gesturedTableView, PDGesturedTableViewCell * cell) {
            [gesturedTableView removeCell:cell completion:^{
                NSIndexPath * indexPath = [gesturedTableView indexPathForCell:cell];
                
                [_self.strings removeObjectAtIndex:indexPath.row];
            }];
        };
        
        cell = [[PDGesturedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
        
        [cell addActionForFraction:0.25 icon:[UIImage imageNamed:@"circle"] color:[UIColor colorWithRed:85.0/255.0 green:213.0/255.0 blue:80.0/255.0 alpha:1] activationBlock:removeCellBlock highlightBlock:nil unhighlightBlock:nil];
        
        [cell addActionForFraction:0.7 icon:[UIImage imageNamed:@"square"] color:[UIColor colorWithRed:213.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1] activationBlock:removeCellBlock highlightBlock:nil unhighlightBlock:nil];
        
        [cell addActionForFraction:-0.25 icon:[UIImage imageNamed:@"circle"] color:[UIColor colorWithRed:236.0/255.0 green:223.0/255 blue:60.0/255 alpha:1] activationBlock:removeCellBlock highlightBlock:nil unhighlightBlock:nil];
        
        [cell addActionForFraction:-0.7 icon:[UIImage imageNamed:@"square.png"] color:[UIColor colorWithRed:182.0/255.0 green:127.0/255 blue:78.0/255 alpha:1] activationBlock:removeCellBlock highlightBlock:nil unhighlightBlock:nil];
    }
    
    [cell.textLabel setText:self.strings[indexPath.row]];
    
    return cell;
}

@end