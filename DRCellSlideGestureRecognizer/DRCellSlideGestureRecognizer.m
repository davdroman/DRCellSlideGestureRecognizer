//
//  DRCellSlideGestureRecognizer.m
//  DRCellSlideGestureRecognizer
//
//  Created by David Román Aguirre on 12/5/15.
//
//

#import "DRCellSlideGestureRecognizer.h"

#import "DRCellSlideActionView.h"

#define ElasticPoint(x, li, lf) atanf(tanf((M_PI*li)/(2*lf))*(x/li))*(2*lf/M_PI)

#define ANIMATION_TIME 0.4

@interface DRCellSlideGestureRecognizer ()

@property (nonatomic, strong) NSMutableArray *leftActions;
@property (nonatomic, strong) NSMutableArray *rightActions;

@property (nonatomic, assign) UITableView *tableView;
@property (nonatomic, assign) UITableViewCell *cell;
@property (nonatomic, strong) DRCellSlideActionView *actionView;

@end

@implementation DRCellSlideGestureRecognizer

- (instancetype)init {
	if (self = [super init]) {
		self.delegate = self;
		[self addTarget:self action:@selector(handlePan)];
		
		self.leftActions = [NSMutableArray new];
		self.rightActions = [NSMutableArray new];
		
		self.actionView = [DRCellSlideActionView new];
	}
	
	return self;
}

- (UITableView *)tableView {
	return (UITableView *)self.cell.superview.superview;
}

- (UITableViewCell *)cell {
	return (UITableViewCell *)self.view;
}

- (NSIndexPath *)indexPath {
	return [self.tableView indexPathForCell:self.cell];
}

- (void)addActions:(NSArray *)actions {
	safeFor(actions, ^(DRCellSlideAction *a) {
		if (a.fraction > 0) {
			[self.leftActions addObject:a];
		} else if (a.fraction < 0) {
			[self.rightActions addObject:a];
		}
	});
}

void safeFor(id arrayOrObject, void (^forBlock)(id object)) {
	if ([arrayOrObject isKindOfClass:[NSArray class]]) {
		for (id object in arrayOrObject) {
			forBlock(object);
		}
	} else {
		forBlock(arrayOrObject);
	}
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
	CGPoint velocity = [self velocityInView:self.view];
	
	return fabs(velocity.x) > fabs(velocity.y);
}

- (void)handlePan {
	if (self.state == UIGestureRecognizerStateBegan) {
		
		[self sortActions];
		
		[self.cell.superview insertSubview:self.actionView atIndex:0];
		self.actionView.frame = self.cell.frame;
		self.actionView.active = NO;
		
	} else if (self.state == UIGestureRecognizerStateChanged) {
		
		[self updateCellPosition];
		
		if ([self isActiveForCurrentCellPosition] != self.actionView.active) {
			self.actionView.active = [self isActiveForCurrentCellPosition];
			if (self.actionView.action.didChangeStateBlock) self.actionView.action.didChangeStateBlock(self.actionView.action, self.actionView.isActive);
		}
		
		if ([self actionForCurrentCellPosition] != self.actionView.action) {
			self.actionView.action = [self actionForCurrentCellPosition];
		}
		
	} else if (self.state == UIGestureRecognizerStateEnded) {
		
		[self performAction];
		
	}
}

- (CGFloat)currentHorizontalTranslation {
	CGFloat horizontalTranslation = [self translationInView:self.cell].x;
	
	if ((horizontalTranslation > 0 && self.leftActions.count == 0) || (horizontalTranslation < 0 && self.rightActions.count == 0)) {
		horizontalTranslation = 0;
	}
	
	return horizontalTranslation;
}

- (void)sortActions {
	[self.leftActions sortUsingComparator:^NSComparisonResult(DRCellSlideAction *a1, DRCellSlideAction *a2) {
		return a1.fraction > a2.fraction ? NSOrderedDescending : NSOrderedAscending;
	}];
	
	[self.rightActions sortUsingComparator:^NSComparisonResult(DRCellSlideAction *a1, DRCellSlideAction *a2) {
		return a1.fraction > a2.fraction ? NSOrderedAscending : NSOrderedDescending;
	}];
}

- (CGFloat)fractionForCurrentCellPosition {
	return self.cell.frame.origin.x/self.cell.frame.size.width;
}

- (NSArray *)actionsForCurrentCellPosition {
	return [self fractionForCurrentCellPosition] >= 0 ? self.leftActions : self.rightActions;
}

- (DRCellSlideAction *)actionForCurrentCellPosition {
	DRCellSlideAction *action;
	NSArray *actions = [self actionsForCurrentCellPosition];
	
	for (DRCellSlideAction *a in actions) {
		if (fabs([self fractionForCurrentCellPosition]) > fabs(a.fraction)) {
			action = a;
		} else {
			break;
		}
	}
	
	if (!action) action = [actions firstObject];
	
	return action;
}

- (BOOL)isActiveForCurrentCellPosition {
	return fabs([self fractionForCurrentCellPosition]) >= fabs([self actionForCurrentCellPosition].fraction);
}

- (void)updateCellPosition {
	
	CGFloat horizontalTranslation = [self currentHorizontalTranslation];
	
	DRCellSlideAction *lastAction = [[self actionsForCurrentCellPosition] lastObject];
	
	if (lastAction.elasticity != 0) {
		CGFloat li = self.cell.frame.size.width*lastAction.fraction;
		
		if (fabs(horizontalTranslation) >= fabs(li)) {
			CGFloat lf = li+lastAction.elasticity;
			horizontalTranslation = ElasticPoint(horizontalTranslation, li, lf);
		}
	}
	
	[self translateCellHorizontally:horizontalTranslation];
	[self.actionView cellDidUpdatePosition:self.cell];
}

- (void)translateCellHorizontally:(CGFloat)horizontalTranslation {
	self.cell.center = CGPointMake(self.cell.frame.size.width/2+horizontalTranslation, self.cell.center.y);
}

- (void)translateCellHorizontally:(CGFloat)horizontalTranslation animatedlyWithDuration:(NSTimeInterval)duration damping:(CGFloat)damping completion:(void (^)(BOOL finished))completion {
	[UIView animateWithDuration:duration delay:0 usingSpringWithDamping:damping initialSpringVelocity:1 options:kNilOptions animations:^{
		[self translateCellHorizontally:horizontalTranslation];
	} completion:completion];
}

- (void)performAction {
	if (self.actionView.active) {
		
		CGFloat horizontalTranslation = [self horizontalTranslationForActionBehavior];
		
		if (self.actionView.action.willTriggerBlock) self.actionView.action.willTriggerBlock(self.tableView, [self indexPath]);
		[self translateCellHorizontally:horizontalTranslation animatedlyWithDuration:ANIMATION_TIME damping:1 completion:^(BOOL finished) {
			
			if (self.actionView.action.behavior == DRCellSlideActionPushBehavior) {
				[self dismissActionView];
			} else {
				[self.actionView removeFromSuperview];
			}
			
			if (self.actionView.action.didTriggerBlock) self.actionView.action.didTriggerBlock(self.tableView, [self indexPath]);
		}];
		
	} else {
		
		[self translateCellHorizontally:0 animatedlyWithDuration:ANIMATION_TIME damping:0.65 completion:^(BOOL finished) {
			[self.actionView removeFromSuperview];
		}];
		
	}
}

- (CGFloat)horizontalTranslationForActionBehavior {
	return self.actionView.action.behavior == DRCellSlideActionPullBehavior ? 0 : self.cell.frame.size.width*(self.actionView.action.fraction/fabs(self.actionView.action.fraction));
}

- (void)dismissActionView {
	[UIView animateWithDuration:(0.3) animations:^{
		self.actionView.alpha = 0;
	} completion:^(BOOL finished) {
		[self.actionView removeFromSuperview];
		self.actionView.alpha = 1;
	}];
}

@end
