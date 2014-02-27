//
//  ConfigurationViewController.m
//  PDGestureTableView
//
//  Created by David Román Aguirre on 28/08/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import "SettingsViewController.h"

#import "PDGestureTableView.h"

#import <Masonry.h>

@implementation SettingsViewController

- (id)init {
    if (self = [super init]) {
        greenColor = [UIColor colorWithRed:85.0/255.0 green:213.0/255.0 blue:80.0/255.0 alpha:1];
        
        self.options = [NSArray new];
        
        self.gestureTableView = [PDGestureTableView new];
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
    
    [self setTitle:@"Example Settings"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(didTapRightButton)];
    
    [self.gestureTableView setAllowsSelection:NO];
    [self.gestureTableView setBackgroundColor:[UIColor colorWithWhite:0.96 alpha:1]];
    [self.gestureTableView setDataSource:self];
    [self.gestureTableView setSeparatorColor:[UIColor colorWithWhite:0.85 alpha:1]];
    [self.gestureTableView setRowHeight:60];
}

- (void)didTapRightButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupView {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:self.gestureTableView];
}

- (void)setupConstraints {
    [self.gestureTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
}

#pragma mark Color Methods

- (void)changeCellColors:(PDGestureTableViewCell *)cell {
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

- (UITableViewCell *)tableView:(PDGestureTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Option Cell";
    
    PDGestureTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        __unsafe_unretained typeof(self) _self = self;
        
        cell = [[PDGestureTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        [cell setFirstLeftAction:[PDGestureTableViewCellAction actionWithIcon:[UIImage imageNamed:@"green-circle"] color:[UIColor clearColor] fraction:0.25 didTriggerBlock:^(PDGestureTableView *gestureTableView, NSIndexPath *indexPath) {
            NSString *optionKey = [[NSString alloc] initWithFormat:@"option%i", indexPath.row+1];
            BOOL optionEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:optionKey];
            
            [[NSUserDefaults standardUserDefaults] setBool:!optionEnabled forKey:optionKey];

            [gestureTableView replaceCellForIndexPath:indexPath completion:nil];
        }]];
        
        [cell.firstLeftAction setDidHighlightBlock:^(PDGestureTableView *gestureTableView, PDGestureTableViewCell *cell) {
            [_self changeCellColors:cell];
        }];
        
        [cell.firstLeftAction setDidUnhighlightBlock:cell.firstLeftAction.didHighlightBlock];
    }
    
    [cell.textLabel setText:self.options[indexPath.row][@"title"]];
    [cell setActionIconsFollowSliding:NO];
    
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
