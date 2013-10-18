//
//  MainViewController.m
//  PDGesturedTableView
//
//  Created by David Román Aguirre on 27/08/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import "MainViewController.h"

#import "ConfigurationViewController.h"

#define kNavigationBarHeight 44

// Uncomment for iOS 7 compatibility
// #define kNavigationBarHeight 64

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
    
    [self.navigationBar setFrame:CGRectMake(0, 0, self.view.frame.size.width, kNavigationBarHeight)];
    
    UINavigationItem * item = [UINavigationItem new];
    [item setTitle:@"PDGesturedTableView"];
    
    UIImage * switcherIconImage = [UIImage imageNamed:@"switcherIcon.png"];
    
    UIButton * switcherButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [switcherButton setFrame:CGRectMake(0, 0, switcherIconImage.size.width+20, self.navigationBar.frame.size.height)];
    [switcherButton addTarget:self action:@selector(presentConfigurationViewController) forControlEvents:UIControlEventTouchUpInside];
    [switcherButton setShowsTouchWhenHighlighted:YES];
    [switcherButton setContentMode:UIViewContentModeCenter];
    [switcherButton setImage:switcherIconImage forState:UIControlStateNormal];
    
    item.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:switcherButton];
    
    [self.navigationBar setItems:@[item]];
    
    [self.view addSubview:self.navigationBar];
    
    CGFloat navigationBarVerticalPosition = self.navigationBar.frame.origin.y + self.navigationBar.frame.size.height;
    
    [self.gesturedTableView setFrame:CGRectMake(0, navigationBarVerticalPosition, self.view.frame.size.width, self.view.frame.size.height - navigationBarVerticalPosition)];
    [self.gesturedTableView setSecondaryDelegate:self];
    [self.gesturedTableView setDataSource:self];
    [self.gesturedTableView.titleTextViewModel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
    
    [self.view insertSubview:self.gesturedTableView belowSubview:self.navigationBar];
}

- (void)presentConfigurationViewController {
    ConfigurationViewController * configurationViewController = [ConfigurationViewController new];
    [configurationViewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self presentViewController:configurationViewController animated:YES completion:nil];
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

- (void)gesturedTableView:(PDGesturedTableView *)gesturedTableView gesturedTableViewCell:(PDGesturedTableViewCell *)gesturedTableViewCell titleTextViewDidEndEditing:(UITextView *)titleTextView {
    [titleTextView resignFirstResponder];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.strings count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIdentifier = @"Cell Identifier";
    
    PDGesturedTableViewCellSlidingSideView * leftSlidingSideView = [[PDGesturedTableViewCellSlidingSideView alloc] initWithIcon:[UIImage imageNamed:@"circle.png"] highlightIcon:[UIImage imageNamed:@"circle_highlighted.png"] width:60 highlightColor:[UIColor colorWithRed:0.2 green:0.8 blue:0.2 alpha:1]];
    
    PDGesturedTableViewCellSlidingSideView * rightSlidingSideView = [[PDGesturedTableViewCellSlidingSideView alloc] initWithIcon:[UIImage imageNamed:@"square.png"] highlightIcon:[UIImage imageNamed:@"square_highlighted.png"] width:60 highlightColor:[UIColor redColor]];
    
    PDGesturedTableViewCell * cell = [[PDGesturedTableViewCell alloc] initForGesturedTableView:self.gesturedTableView leftSlidingSideView:leftSlidingSideView rightSlidingSideView:rightSlidingSideView reuseIdentifier:cellIdentifier];
    
    [cell.titleTextView setText:self.strings[indexPath.row]];
    
    return cell;
}

@end