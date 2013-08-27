//
//  MainViewController.m
//  PDGesturedTableView
//
//  Created by David Román Aguirre on 27/08/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController

- (id)init {
    if (self = [super init]) {
        self.strings = [NSMutableArray new];
        
        self.navigationBar = [UINavigationBar new];
        self.gesturedTableView = [PDGesturedTableView new];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.strings = [[@"lorem ipsum dolor sit amet consectetur adipiscing elit cras gravida quam eu adipiscing elementum" componentsSeparatedByString:@" "] mutableCopy];
    
    [self.navigationBar setFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [self.navigationBar setItems:@[[UINavigationItem new]]];
    [[self.navigationBar.items lastObject] setTitle:@"PDGesturedTableView"];
    
    [self.view addSubview:self.navigationBar];
    
    CGFloat navigationBarVerticalPosition = self.navigationBar.frame.origin.y + self.navigationBar.frame.size.height;
    
    [self.gesturedTableView setFrame:CGRectMake(0, navigationBarVerticalPosition, self.view.frame.size.width, self.view.frame.size.height - navigationBarVerticalPosition)];
    [self.gesturedTableView setSecondaryDelegate:self];
    [self.gesturedTableView setDataSource:self];
    
    [self.view insertSubview:self.gesturedTableView belowSubview:self.navigationBar];
}

- (NSString *)gesturedTableView:(PDGesturedTableView *)gesturedTableView stringForTitleTextViewForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.strings[indexPath.row];
}

- (void)gesturedTableView:(PDGesturedTableView *)gesturedTableView didSlideLeftCell:(PDGesturedTableViewCell *)cell {
    NSInteger row = [gesturedTableView indexPathForCell:cell].row;
    
    [cell dismissWithCompletion:^{
        [self.strings removeObjectAtIndex:row];
    }];
}

- (void)gesturedTableView:(PDGesturedTableView *)gesturedTableView didSlideRightCell:(PDGesturedTableViewCell *)cell {
    NSInteger row = [gesturedTableView indexPathForCell:cell].row;
    
    [cell dismissWithCompletion:^{
        [self.strings removeObjectAtIndex:row];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.strings count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIdentifier = @"Cell Identifier";
    
    PDGesturedTableViewCellSlidingSideView * leftSlidingSideView = [[PDGesturedTableViewCellSlidingSideView alloc] initWithIcon:[UIImage imageNamed:@"circle.png"] highlightIcon:[UIImage imageNamed:@"circle_highlighted.png"] width:60 highlightColor:[UIColor colorWithRed:0.2 green:0.8 blue:0.2 alpha:1]];
    
    PDGesturedTableViewCellSlidingSideView * rightSlidingSideView = [[PDGesturedTableViewCellSlidingSideView alloc] initWithIcon:[UIImage imageNamed:@"circle.png"] highlightIcon:[UIImage imageNamed:@"circle_highlighted.png"] width:60 highlightColor:[UIColor redColor]];
    
    PDGesturedTableViewCell * cell = [[PDGesturedTableViewCell alloc] initForGesturedTableView:self.gesturedTableView leftSlidingSideView:leftSlidingSideView rightSlidingSideView:rightSlidingSideView reuseIdentifier:cellIdentifier];
    
    [cell.titleTextView setText:self.strings[indexPath.row]];
    
    return cell;
}

@end