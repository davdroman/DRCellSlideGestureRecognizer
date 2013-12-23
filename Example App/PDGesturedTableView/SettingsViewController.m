//
//  ConfigurationViewController.m
//  PDGesturedTableView
//
//  Created by David Román Aguirre on 28/08/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import "SettingsViewController.h"

#import "SettingsNavigationBar.h"
#import "PDGesturedTableView.h"

#import <Masonry.h>

@implementation SettingsViewController

- (id)init {
    if (self = [super init]) {
        greenColor = [UIColor colorWithRed:85.0/255.0 green:213.0/255.0 blue:80.0/255.0 alpha:1];
        
        self.options = [NSArray new];
        
        self.navigationBar = [SettingsNavigationBar new];
        self.gesturedTableView = [PDGesturedTableView new];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self setupView];
    [self setupConstraints];
}

- (void)setup {
    for (NSInteger i = 0; i < 5; i++) {
        self.options = [self.options arrayByAddingObject:@{@"title": [NSString stringWithFormat:@"Option %i", i+1], @"key": [NSString stringWithFormat:@"option%i", i+1]}];
    }
    
    __unsafe_unretained typeof(self) _self = self;
    
    [self.navigationBar setDidTapRightButtonBlock:^(SettingsNavigationBar * navigationBar) {
        [_self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [self.gesturedTableView setBackgroundColor:[UIColor colorWithWhite:0.96 alpha:1]];
    [self.gesturedTableView setDataSource:self];
    [self.gesturedTableView setSeparatorColor:[UIColor colorWithWhite:0.85 alpha:1]];
    [self.gesturedTableView setRowHeight:60];
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
        make.bottom.equalTo(@0);
        make.right.equalTo(@0);
    }];
}

#pragma mark Color Methods

- (void)changeCellColors:(PDGesturedTableViewCell *)cell {
    [cell.contentView setBackgroundColor:[self inverseBackgroundColor:cell.contentView.backgroundColor]];
    [cell.textLabel setTextColor:[self inverseTextColor:cell.textLabel.textColor]];
}

- (UIColor *)inverseBackgroundColor:(UIColor *)color {
    return [color isEqual:greenColor] ? [UIColor whiteColor] : greenColor;
}

- (UIColor *)inverseTextColor:(UIColor *)color {
    return [color isEqual:[UIColor whiteColor]] ? [UIColor blackColor] : [UIColor whiteColor];
}

#pragma mark UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.options count];
}

- (UITableViewCell *)tableView:(PDGesturedTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIdentifier = @"Option Cell";
    
    PDGesturedTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        __unsafe_unretained typeof(self) _self = self;
        
        cell = [[PDGesturedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        [cell addActionForFraction:0.25 icon:[UIImage imageNamed:@"green-circle.png"] color:[UIColor clearColor] activationBlock:^(PDGesturedTableView *gesturedTableView, PDGesturedTableViewCell *cell) {
            NSInteger row = [_self.gesturedTableView indexPathForCell:cell].row;
            
            NSString * optionKey = [[NSString alloc] initWithFormat:@"option%i", row+1];
            BOOL optionEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:optionKey];
            
            [[NSUserDefaults standardUserDefaults] setBool:!optionEnabled forKey:optionKey];
            
            [gesturedTableView replaceCell:cell completion:nil];
        } highlightBlock:^(PDGesturedTableView *gesturedTableView, PDGesturedTableViewCell *cell) {
            [_self changeCellColors:cell];
        } unhighlightBlock:^(PDGesturedTableView *gesturedTableView, PDGesturedTableViewCell *cell) {
            [_self changeCellColors:cell];
        }];
    }
    
    [cell.textLabel setText:self.options[indexPath.row][@"title"]];
    BOOL optionEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:self.options[indexPath.row][@"key"]];
    
    if (optionEnabled) {
        [cell.contentView setBackgroundColor:greenColor];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
    } else {
        [cell.contentView setBackgroundColor:[UIColor whiteColor]];
        [cell.textLabel setTextColor:[UIColor blackColor]];
    }
    
    return cell;
}

@end
