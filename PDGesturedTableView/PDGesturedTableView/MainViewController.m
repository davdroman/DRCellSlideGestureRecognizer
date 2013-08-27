//
//  MainViewController.m
//  PDGesturedTableView
//
//  Created by David Román Aguirre on 27/08/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)init {
    if (self = [super init]) {
        self.navigationBar = [UINavigationBar new];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.navigationBar setFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [[self.navigationBar.items lastObject] setTitle:@"PDGesturedTableView"];
    
    [self.view addSubview:self.navigationBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
