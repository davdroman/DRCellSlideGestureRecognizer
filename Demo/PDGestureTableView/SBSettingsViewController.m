//
//  SBSettingsViewController.m
//  PDGestureTableView
//
//  Created by David Román Aguirre on 03/01/14.
//  Copyright (c) 2014 David Román Aguirre. All rights reserved.
//

#import "SBSettingsViewController.h"

#import "PDGestureTableView.h"

@implementation SBSettingsViewController

- (void)awakeFromNib {
    greenColor = [UIColor colorWithRed:85.0/255.0 green:213.0/255.0 blue:80.0/255.0 alpha:1];
    
    self.options = [NSArray new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
}

- (void)setup {
    for (NSInteger i = 0; i < 5; i++) {
        self.options = [self.options arrayByAddingObject:@{@"title": [NSString stringWithFormat:@"Option %i", i+1], @"key": [NSString stringWithFormat:@"option%i", i+1]}];
    }
    
    [self.tableView setAllowsSelection:NO];
    [self.tableView setBackgroundColor:[UIColor colorWithWhite:0.96 alpha:1]];
    [self.tableView setSeparatorColor:[UIColor colorWithWhite:0.85 alpha:1]];
    [self.tableView setRowHeight:60];
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
    static NSString *cellIdentifier = @"Cell";
    
    PDGestureTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    __unsafe_unretained typeof(self) _self = self;
    
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
    
    [cell.textLabel setText:self.options[indexPath.row][@"title"]];
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];
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

- (IBAction)dismissViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
