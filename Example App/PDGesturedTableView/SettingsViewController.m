//
//  ConfigurationViewController.m
//  PDGesturedTableView
//
//  Created by David Román Aguirre on 28/08/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import "SettingsViewController.h"

@implementation SettingsViewController

- (id)init {
    if (self = [super init]) {
        greenColor = [UIColor colorWithRed:0.2 green:0.8 blue:0.2 alpha:1];
        
        self.options = [NSArray new];
        
        self.navigationBar = [UINavigationBar new];
        self.gesturedTableView = [PDGesturedTableView new];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    for (NSInteger i = 0; i < 5; i++) {
        self.options = [self.options arrayByAddingObject:@{@"title": [NSString stringWithFormat:@"Option %i", i+1], @"key": [NSString stringWithFormat:@"option%i", i+1]}];
    }
    
    [self.navigationBar setFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    
    UINavigationItem * item = [UINavigationItem new];
    [item setTitle:@"Example Settings"];
    item.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissSettingsViewController)];
    
    [self.navigationBar setItems:@[item]];
    
    [self.view addSubview:self.navigationBar];
    
    [self.gesturedTableView setFrame:CGRectMake(0, self.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.navigationBar.frame.size.height)];
    [self.gesturedTableView setBackgroundColor:[UIColor colorWithWhite:0.96 alpha:1]];
    [self.gesturedTableView setDataSource:self];
    [self.gesturedTableView setSeparatorColor:[UIColor colorWithWhite:0.85 alpha:1]];
    [self.gesturedTableView setRowHeight:60];
    
    [self.view insertSubview:self.gesturedTableView belowSubview:self.navigationBar];
}

- (void)dismissSettingsViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)changeCellColors:(PDGesturedTableViewCell *)cell {
    [cell.contentView setBackgroundColor:[self inverseBackgroundColor:cell.contentView.backgroundColor]];
    [cell.textLabel setTextColor:[self inverseTextColor:cell.textLabel.textColor]];
}

- (UIColor *)inverseBackgroundColor:(UIColor *)color {
    if ([color isEqual:greenColor]) {
        return [UIColor whiteColor];
    }
    
    return greenColor;
}

- (UIColor *)inverseTextColor:(UIColor *)color {
    if ([color isEqual:[UIColor whiteColor]]) {
        return [UIColor blackColor];
    }
    
    return [UIColor whiteColor];
}

#pragma mark UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.options count];
}

- (UITableViewCell *)tableView:(PDGesturedTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIdentifier = @"Cell Identifier";
    
    PDGesturedTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        __unsafe_unretained typeof(self) _self = self;
        
        cell = [[PDGesturedTableViewCell alloc] initForGesturedTableView:tableView style:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setBouncesAtLastSlidingFraction:YES];
        
        PDGesturedTableViewCellSlidingFraction * checkSlidingFraction = [PDGesturedTableViewCellSlidingFraction slidingFractionWithIcon:[UIImage imageNamed:@"circle.png"] color:[UIColor clearColor] activationFraction:0.25];
        
        [checkSlidingFraction setDidActivateBlock:^(PDGesturedTableView * gesturedTableView, PDGesturedTableViewCell * cell) {
            [_self changeCellColors:cell];
        }];
        
        [checkSlidingFraction setDidDeactivateBlock:^(PDGesturedTableView * gesturedTableView, PDGesturedTableViewCell * cell) {
            [_self changeCellColors:cell];
        }];
        
        [checkSlidingFraction setDidReleaseBlock:^(PDGesturedTableView * gesturedTableView, PDGesturedTableViewCell * cell) {
            NSInteger row = [_self.gesturedTableView indexPathForCell:cell].row;
            
            NSString * optionKey = [[NSString alloc] initWithFormat:@"option%i", row+1];
            BOOL optionEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:optionKey];
            
            [[NSUserDefaults standardUserDefaults] setBool:!optionEnabled forKey:optionKey];
            
            [cell replace];
        }];
        
        [cell addSlidingFraction:checkSlidingFraction];
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
