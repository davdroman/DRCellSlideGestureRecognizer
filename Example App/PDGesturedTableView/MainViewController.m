//
//  MainViewController.m
//  PDGesturedTableView
//
//  Created by David Román Aguirre on 27/08/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import "MainViewController.h"

#import "SettingsViewController.h"

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
    
    [self.view.layer setCornerRadius:4.5];
    [self.view.layer setMasksToBounds:YES];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.strings = [[@"lorem ipsum dolor sit amet consectetur adipiscing elit cras gravida quam eu adipiscing elementum" componentsSeparatedByString:@" "] mutableCopy];
    
    [self.navigationBar setFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    
    UINavigationItem * item = [UINavigationItem new];
    [item setTitle:@"PDGesturedTableView"];
    
    UIImage * settingsIconImage = [UIImage imageNamed:@"settingsIcon.png"];
    
    UIButton * settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingsButton setFrame:CGRectMake(0, 0, settingsIconImage.size.width, 44)];
    [settingsButton addTarget:self action:@selector(presentSettingsViewController) forControlEvents:UIControlEventTouchUpInside];
    [settingsButton setContentMode:UIViewContentModeCenter];
    [settingsButton setImage:settingsIconImage forState:UIControlStateNormal];
    
    item.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
    
    [self.navigationBar setItems:@[item]];
    
    [self.view addSubview:self.navigationBar];
    
    [self.gesturedTableView setFrame:CGRectMake(0, self.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.navigationBar.frame.size.height)];
    [self.gesturedTableView setBackgroundColor:[UIColor colorWithWhite:0.96 alpha:1]];
    [self.gesturedTableView setDataSource:self];
    [self.gesturedTableView setRowHeight:60];
    
    UILabel * noMoreLoremIpsumLabel = [UILabel new];
    [noMoreLoremIpsumLabel setBackgroundColor:[UIColor clearColor]];
    [noMoreLoremIpsumLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:19]];
    [noMoreLoremIpsumLabel setText:@"No more lorem ipsum!"];
    [noMoreLoremIpsumLabel sizeToFit];
    [noMoreLoremIpsumLabel setCenter:CGPointMake(self.gesturedTableView.backgroundView.frame.size.width/2, self.gesturedTableView.backgroundView.frame.size.height/2)];
    
    [self.gesturedTableView.backgroundView addSubview:noMoreLoremIpsumLabel];
    
    [self.view insertSubview:self.gesturedTableView belowSubview:self.navigationBar];
}

- (void)presentSettingsViewController {
    SettingsViewController * settingsViewController = [SettingsViewController new];
    [settingsViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:settingsViewController animated:YES completion:nil];
}

#pragma mark UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.strings count];
}

- (UITableViewCell *)tableView:(PDGesturedTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIdentifier = @"Cell Identifier";
    
    PDGesturedTableViewCell * cell = (PDGesturedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        __unsafe_unretained typeof(self) _self = self;
        
        void (^completionForReleaseBlocks)(PDGesturedTableView *, PDGesturedTableViewCell *) = ^(PDGesturedTableView * gesturedTableView, PDGesturedTableViewCell * cell){
            [gesturedTableView removeCell:cell completion:^{
                NSIndexPath * indexPath = [gesturedTableView indexPathForCell:cell];
                
                [_self.strings removeObjectAtIndex:indexPath.row];
            }];
        };
        
        cell = [[PDGesturedTableViewCell alloc] initForGesturedTableView:tableView style:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        PDGesturedTableViewCellSlidingFraction * greenSlidingFraction = [PDGesturedTableViewCellSlidingFraction slidingFractionWithIcon:[UIImage imageNamed:@"circle.png"] color:[UIColor colorWithRed:0.2 green:0.8 blue:0.2 alpha:1] activationFraction:0.25];
        
        [greenSlidingFraction setDidReleaseBlock:completionForReleaseBlocks];
        
        [cell addSlidingFraction:greenSlidingFraction];
        
        PDGesturedTableViewCellSlidingFraction * redSlidingFraction = [PDGesturedTableViewCellSlidingFraction slidingFractionWithIcon:[UIImage imageNamed:@"square.png"] color:[UIColor redColor] activationFraction:0.75];
        
        [redSlidingFraction setDidReleaseBlock:completionForReleaseBlocks];
        
        [cell addSlidingFraction:redSlidingFraction];
        
        PDGesturedTableViewCellSlidingFraction * yellowSlidingFraction = [PDGesturedTableViewCellSlidingFraction slidingFractionWithIcon:[UIImage imageNamed:@"circle.png"] color:[UIColor colorWithRed:239.0/255.0 green:222.0/255 blue:24.0/255 alpha:1] activationFraction:-0.25];
        
        [yellowSlidingFraction setDidReleaseBlock:completionForReleaseBlocks];
        
        [cell addSlidingFraction:yellowSlidingFraction];
        
        PDGesturedTableViewCellSlidingFraction * brownSlidingFraction = [PDGesturedTableViewCellSlidingFraction slidingFractionWithIcon:[UIImage imageNamed:@"square.png"] color:[UIColor brownColor] activationFraction:-0.75];
        
        [brownSlidingFraction setDidReleaseBlock:completionForReleaseBlocks];
        
        [cell addSlidingFraction:brownSlidingFraction];
        
        [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
    }
    
    [cell.textLabel setText:self.strings[indexPath.row]];
    
    return cell;
}

@end