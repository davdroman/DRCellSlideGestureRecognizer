//
//  ConfigurationViewController.m
//  PDGesturedTableView
//
//  Created by David Román Aguirre on 28/08/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import "ConfigurationViewController.h"

#define kNavigationBarHeight 44

// Uncomment for iOS 7 compatibility
// #define kNavigationBarHeight 64

@implementation ConfigurationViewController

- (id)init {
    if (self = [super init]) {
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
    
    [self.navigationBar setFrame:CGRectMake(0, 0, self.view.frame.size.width, kNavigationBarHeight)];
    
    UINavigationItem * item = [UINavigationItem new];
    [item setTitle:@"Configuration Example"];
    
    item.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissConfigurationViewController)];
    
    [self.navigationBar setItems:@[item]];
    
    [self.view addSubview:self.navigationBar];
    
    CGFloat navigationBarVerticalPosition = self.navigationBar.frame.origin.y + self.navigationBar.frame.size.height;
    
    [self.gesturedTableView setFrame:CGRectMake(0, navigationBarVerticalPosition, self.view.frame.size.width, self.view.frame.size.height - navigationBarVerticalPosition)];
    [self.gesturedTableView setSecondaryDelegate:self];
    [self.gesturedTableView setDataSource:self];
    [self.gesturedTableView.titleTextViewModel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
    [self.gesturedTableView setSeparatorColor:[UIColor colorWithWhite:0.6 alpha:1]];
    
    [self.view insertSubview:self.gesturedTableView belowSubview:self.navigationBar];
}

- (void)dismissConfigurationViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)gesturedTableView:(PDGesturedTableView *)gesturedTableView stringForTitleTextViewForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.options[indexPath.row][@"title"];
}

- (void)changeCellColors:(PDGesturedTableViewCell *)cell {
    [cell.contentView setBackgroundColor:([cell.contentView.backgroundColor isEqual:[UIColor colorWithRed:0.2 green:0.8 blue:0.2 alpha:1]] ? [UIColor whiteColor] : [UIColor colorWithRed:0.2 green:0.8 blue:0.2 alpha:1])];
    [cell.titleTextView setTextColor:([cell.titleTextView.textColor isEqual:[UIColor whiteColor]] ? [UIColor blackColor] : [UIColor whiteColor])];
}

- (void)gesturedTableView:(PDGesturedTableView *)gesturedTableView cellDidReachLeftHighlightLimit:(PDGesturedTableViewCell *)cell {
    [self changeCellColors:cell];
}

- (void)gesturedTableView:(PDGesturedTableView *)gesturedTableView cellDidReachLeftNoHighlightLimit:(PDGesturedTableViewCell *)cell {
    [self changeCellColors:cell];
}

- (void)gesturedTableView:(PDGesturedTableView *)gesturedTableView didSlideLeftCell:(PDGesturedTableViewCell *)cell {
    NSInteger row = [gesturedTableView indexPathForCell:cell].row;
    
    NSString * optionKey = [[NSString alloc] initWithFormat:@"option%i", row+1];
    BOOL optionEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:optionKey];
    
    [[NSUserDefaults standardUserDefaults] setBool:!optionEnabled forKey:optionKey];
    
    [cell replace];
}

- (void)gesturedTableView:(PDGesturedTableView *)gesturedTableView gesturedTableViewCell:(PDGesturedTableViewCell *)gesturedTableViewCell titleTextViewDidEndEditing:(UITextView *)titleTextView {
    [titleTextView resignFirstResponder];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.options count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIdentifier = @"Cell Identifier";
    
    PDGesturedTableViewCellSlidingSideView * leftSlidingSideView = [[PDGesturedTableViewCellSlidingSideView alloc] initWithIcon:[UIImage imageNamed:@"circle.png"] highlightIcon:nil width:60 highlightColor:[UIColor clearColor]];
    
    PDGesturedTableViewCell * cell = [[PDGesturedTableViewCell alloc] initForGesturedTableView:self.gesturedTableView leftSlidingSideView:leftSlidingSideView rightSlidingSideView:nil reuseIdentifier:cellIdentifier];
    
    [cell.titleTextView setText:self.options[indexPath.row][@"title"]];
    BOOL optionEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:self.options[indexPath.row][@"key"]];
    
    if (optionEnabled) {
        [cell.contentView setBackgroundColor:[UIColor colorWithRed:0.2 green:0.8 blue:0.2 alpha:1]];
        [cell.titleTextView setTextColor:[UIColor whiteColor]];
    }
    [cell.titleTextView setEditable:NO];
    
    return cell;
}

@end
