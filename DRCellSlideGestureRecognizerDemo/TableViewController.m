//
//  TableViewController.m
//  DRCellSlideGestureRecognizer
//
//  Created by David Román Aguirre on 12/5/15.
//
//

#import "TableViewController.h"

#import "DRCellSlideGestureRecognizer.h"

NSString * const cellReuseIdentifier = @"Cell Reuse Identifier";

NSString * const stringForCell1 = @"Push left actions";
NSString * const stringForCell2 = @"Pull right actions";
NSString * const stringForCell3 = @"Left and right actions";
NSString * const stringForCell4 = @"Elastic left and right actions";

@interface TableViewController () {
	NSMutableArray *strings;
}

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"DRCellSlideGestureRecognizer";
	self.view.backgroundColor = [UIColor whiteColor];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(resetCells)];
	self.tableView.tableFooterView = [UIView new];
	self.tableView.rowHeight = 60;
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellReuseIdentifier];
	
	[self resetCells];
}

- (void)resetCells {
	strings = [NSMutableArray arrayWithObjects:stringForCell1, stringForCell2, stringForCell3, stringForCell4, nil];
	
	[self.tableView beginUpdates];
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
	[self.tableView endUpdates];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return strings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
	cell.textLabel.text = strings[indexPath.row];
	
	DRCellSlideGestureRecognizer *slideGestureRecognizer = [DRCellSlideGestureRecognizer new];
	
	UIColor *greenColor = [UIColor colorWithRed:91/255.0 green:220/255.0 blue:88/255.0 alpha:1];
	UIColor *redColor = [UIColor colorWithRed:222/255.0 green:61/255.0 blue:14/255.0 alpha:1];
	UIColor *blueColor = [UIColor colorWithRed:14/255.0 green:182/255.0 blue:222/255.0 alpha:1];
	
	UIColor *yellowColor = [UIColor colorWithRed:254/255.0 green:217/255.0 blue:56/255.0 alpha:1];
	UIColor *brownColor = [UIColor colorWithRed:206/255.0 green:149/255.0 blue:98/255.0 alpha:1];
	UIColor *purpleColor = [UIColor colorWithRed:148/255.0 green:14/255.0 blue:222/255.0 alpha:1];
	
	DRCellSlideAction *squareAction = [DRCellSlideAction actionForFraction:0.25];
	squareAction.icon = [UIImage imageNamed:@"square"];
	squareAction.activeBackgroundColor = greenColor;
	
	DRCellSlideAction *circleAction = [DRCellSlideAction actionForFraction:0.5];
	circleAction.icon = [UIImage imageNamed:@"circle"];
	circleAction.activeBackgroundColor = redColor;
	
	DRCellSlideAction *roundedSquareAction = [DRCellSlideAction actionForFraction:0.75];
	roundedSquareAction.icon = [UIImage imageNamed:@"rounded-square"];
	roundedSquareAction.activeBackgroundColor = blueColor;
	
	DRCellSlideAction *triangleAction = [DRCellSlideAction actionForFraction:-0.25];
	triangleAction.icon = [UIImage imageNamed:@"triangle"];
	triangleAction.activeBackgroundColor = yellowColor;
	
	DRCellSlideAction *octagonAction = [DRCellSlideAction actionForFraction:-0.5];
	octagonAction.icon = [UIImage imageNamed:@"octagon"];
	octagonAction.activeBackgroundColor = brownColor;
	
	DRCellSlideAction *starAction = [DRCellSlideAction actionForFraction:-0.75];
	starAction.icon = [UIImage imageNamed:@"star"];
	starAction.activeBackgroundColor = purpleColor;
	
	if ([strings[indexPath.row] isEqualToString:stringForCell1]) {
		
		squareAction.behavior = circleAction.behavior = DRCellSlideActionPushBehavior;
		squareAction.didTriggerBlock = circleAction.didTriggerBlock = [self pushTriggerBlock];
		
		[slideGestureRecognizer addActions:@[squareAction, circleAction]];
		
	} else if ([strings[indexPath.row] isEqualToString:stringForCell2]) {
		
		triangleAction.behavior = octagonAction.behavior = DRCellSlideActionPullBehavior;
		triangleAction.didTriggerBlock = octagonAction.didTriggerBlock = [self pullTriggerBlock];
		
		[slideGestureRecognizer addActions:@[triangleAction, octagonAction]];
		
	} else if ([strings[indexPath.row] isEqualToString:stringForCell3]) {
		
		squareAction.behavior = circleAction.behavior = roundedSquareAction.behavior = DRCellSlideActionPushBehavior;
		squareAction.didTriggerBlock = circleAction.didTriggerBlock = roundedSquareAction.didTriggerBlock = [self pushTriggerBlock];
		
		triangleAction.behavior = octagonAction.behavior = starAction.behavior = DRCellSlideActionPullBehavior;
		triangleAction.didTriggerBlock = octagonAction.didTriggerBlock = starAction.didTriggerBlock = [self pullTriggerBlock];
		
		[slideGestureRecognizer addActions:@[squareAction, circleAction, roundedSquareAction, triangleAction, octagonAction, starAction]];
		
	} else if ([strings[indexPath.row] isEqualToString:stringForCell4]) {
		
		squareAction.behavior = DRCellSlideActionPushBehavior;
		squareAction.elasticity = 40;
		squareAction.didTriggerBlock = [self pushTriggerBlock];
		
		triangleAction.behavior = DRCellSlideActionPullBehavior;
		triangleAction.elasticity = 40;
		triangleAction.didTriggerBlock = [self pullTriggerBlock];
		
		[slideGestureRecognizer addActions:@[squareAction, triangleAction]];
		
	}
	
	[cell addGestureRecognizer:slideGestureRecognizer];
    
    return cell;
}

- (DRCellSlideActionBlock)pushTriggerBlock {
	return ^(UITableView *tableView, NSIndexPath *indexPath) {
		[strings removeObjectAtIndex:indexPath.row];
		[tableView beginUpdates];
		[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
		[tableView endUpdates];
	};
}

- (DRCellSlideActionBlock)pullTriggerBlock {
	return ^(UITableView *tableView, NSIndexPath *indexPath) {
		UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hooray!" message:@"You just triggered a cell action." preferredStyle:UIAlertControllerStyleAlert];
		[alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
			[alertController dismissViewControllerAnimated:YES completion:nil];
		}]];
		
		[self presentViewController:alertController animated:YES completion:nil];
	};
}

@end
