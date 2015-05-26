//
//  DRCellSlideAction.m
//  DRCellSlideGestureRecognizer
//
//  Created by David Román Aguirre on 12/5/15.
//
//

#import "DRCellSlideAction.h"

@implementation DRCellSlideAction

+ (instancetype)actionForFraction:(CGFloat)fraction {
	return [[self alloc] initWithFraction:fraction];
}

- (instancetype)initWithFraction:(CGFloat)fraction {
	if (self = [super init]) {
		_fraction = fraction;
		_activeBackgroundColor = [UIColor blueColor];
		_inactiveBackgroundColor = [UIColor colorWithWhite:0.94 alpha:1];
		_activeColor = _inactiveColor = [UIColor whiteColor];
		_iconMargin = 25;
	}
	
	return self;
}

- (void)setElasticity:(CGFloat)elasticity {
	_elasticity = fabs(elasticity)*[self fractionSign];
}

- (CGFloat)fractionSign {
	return self.fraction/fabs(self.fraction);
}

@end
