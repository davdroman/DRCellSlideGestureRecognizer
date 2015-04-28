//
//  MainViewController.m
//  PDGestureTableView
//
//  Created by David Román Aguirre on 27/08/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import "MainViewController.h"

#import <Social/Social.h>
#import <Masonry.h>

#import "PDGestureTableView.h"
#import "TableViewBackgroundView.h"

#import "SettingsViewController.h"

@implementation MainViewController

- (id)init {
    if (self = [super init]) {
        self.strings = [NSMutableArray new];
        
        self.gestureTableView = [PDGestureTableView new];
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
                                        @"Tap and hold a cell to move it",
                                        @"Finally, swipe all cells"]];
    
    __unsafe_unretained typeof(self) _self = self; // This prevents retain cycles in the following blocks.
    
    [self setTitle:@"PDGestureTableView"];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings"] style:UIBarButtonItemStylePlain target:self action:@selector(didTapLeftButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didTapRightButton)];
    
    [self.gestureTableView setAllowsSelection:NO];
    [self.gestureTableView setBackgroundColor:[UIColor colorWithWhite:0.96 alpha:1]];
    [self.gestureTableView setDataSource:self];
    [self.gestureTableView setRowHeight:65];
    
    [self.gestureTableView setDidMoveCellFromIndexPathToIndexPathBlock:^(NSIndexPath *fromIndexPath, NSIndexPath *toIndexPath) {
        [_self.strings exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
    }];
    
    // Gesture Table View "backgroundView" setup (the view that will automatically show up when there're no cells on the table view).
    
    TableViewBackgroundView *backgroundView = [TableViewBackgroundView new];
    
    [backgroundView setDidTapTweetButtonBlock:^{
        SLComposeViewController *tweetComposerViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetComposerViewController setInitialText:@"I've just discovered PDGestureTableView by @Dromaguirre and it's awesome! You should check it out!"];
        [tweetComposerViewController addURL:[NSURL URLWithString:@"http://github.com/Dromaguirre/PDGestureTableView"]];
        [_self presentViewController:tweetComposerViewController animated:YES completion:nil];
    }];
    
    [self.gestureTableView setBackgroundView:backgroundView];
}

- (void)didTapLeftButton {
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:[SettingsViewController new]] animated:YES completion:nil];
}

- (void)didTapRightButton {
    [self.strings addObject:[NSString stringWithFormat:@"Cell %i", self.strings.count+1]];
    [self.gestureTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.strings.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
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

#pragma mark UITableView Delegates Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.strings count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    PDGestureTableViewCell *cell = (PDGestureTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        __unsafe_unretained typeof(self) _self = self;
        
        // The following block is used for all cells as all of them do the same thing in this case (disappearing).
        
        void (^pushAndDeleteCellBlock)(PDGestureTableView *, NSIndexPath *) = ^(PDGestureTableView *gestureTableView, NSIndexPath *indexPath) {
            [_self.strings removeObjectAtIndex:indexPath.row];
            
            [gestureTableView pushAndDeleteCellForIndexPath:indexPath completion:nil];
        };
        
        cell = [[PDGestureTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];

        UIColor *greenColor = [UIColor colorWithRed:85.0/255.0 green:213.0/255.0 blue:80.0/255.0 alpha:1];
        UIColor *redColor = [UIColor colorWithRed:213.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1];
        UIColor *yellow1 = [UIColor colorWithRed:250.0/255.0 green:255.0/255 blue:94.0/255 alpha:1];
        UIColor *yellow2 = [UIColor colorWithRed:255.0/255.0 green:249.0/255 blue:94.0/255 alpha:1];
        UIColor *yellow3 = [UIColor colorWithRed:255.0/255.0 green:242.0/255 blue:94.0/255 alpha:1];
        UIColor *yellow4 = [UIColor colorWithRed:255.0/255.0 green:229.0/255 blue:94.0/255 alpha:1];
        UIColor *yellow5 = [UIColor colorWithRed:255.0/255.0 green:216.0/255 blue:94.0/255 alpha:1];


        cell.leftActions = @[
                [PDGestureTableViewCellAction actionWithIcon:[UIImage imageNamed:@"star_icon"] color:yellow1 fraction:0.2 didTriggerBlock:pushAndDeleteCellBlock],
                [PDGestureTableViewCellAction actionWithIcon:[UIImage imageNamed:@"star_icon2"] color:yellow2 fraction:0.32 didTriggerBlock:pushAndDeleteCellBlock],
                [PDGestureTableViewCellAction actionWithIcon:[UIImage imageNamed:@"star_icon3"] color:yellow3 fraction:0.44 didTriggerBlock:pushAndDeleteCellBlock],
                [PDGestureTableViewCellAction actionWithIcon:[UIImage imageNamed:@"star_icon4"] color:yellow4 fraction:0.56 didTriggerBlock:pushAndDeleteCellBlock],
                [PDGestureTableViewCellAction actionWithIcon:[UIImage imageNamed:@"star_icon5"] color:yellow5 fraction:0.68 didTriggerBlock:pushAndDeleteCellBlock]
        ];

        cell.rightActions = @[
                [PDGestureTableViewCellAction actionWithIcon:[UIImage imageNamed:@"circle"] color:greenColor fraction:0.25 didTriggerBlock:pushAndDeleteCellBlock],
                [PDGestureTableViewCellAction actionWithIcon:[UIImage imageNamed:@"square"] color:redColor fraction:0.7 didTriggerBlock:pushAndDeleteCellBlock]
        ];

    }
    
    [cell.textLabel setText:self.strings[indexPath.row]];
    
    return cell;
}

@end