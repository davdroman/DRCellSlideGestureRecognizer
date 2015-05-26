//
//  DRCellSlideActionView.m
//  DRCellSlideGestureRecognizer
//
//  Created by David Román Aguirre on 17/5/15.
//
//

#import "DRCellSlideActionView.h"

#import "DRCellSlideAction.h"

@interface DRCellSlideActionView ()

@property (nonatomic, strong) UIImageView *iconImageView;

@end

@implementation DRCellSlideActionView

- (instancetype)init {
	if (self = [super init]) {
		self.iconImageView = [UIImageView new];
		[self addSubview:self.iconImageView];
	}
	
	return self;
}

- (void)updateIconImageViewFrame {
	self.iconImageView.frame = CGRectMake(0, 0, self.frame.size.width-self.action.iconMargin*2, self.frame.size.height);
	self.iconImageView.center = CGPointMake(self.center.x, self.iconImageView.frame.size.height/2);
}

- (void)cellDidUpdatePosition:(UITableViewCell *)cell {
	// NSLog(@"%@", self.superview);
	[self updateIconImageViewFrame];
	self.iconImageView.alpha = fabs(cell.frame.origin.x)/(self.iconImageView.image.size.width+self.action.iconMargin*2);
}

- (void)tint {
	self.iconImageView.tintColor = self.active ? self.action.activeColor : self.action.inactiveColor;
	self.backgroundColor = self.active ? self.action.activeBackgroundColor : self.action.inactiveBackgroundColor;
}

- (void)setAction:(DRCellSlideAction *)action {
	_action = action;
	
	self.iconImageView.image = [action.icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	self.iconImageView.contentMode = action.fraction >= 0 ? UIViewContentModeLeft : UIViewContentModeRight;
	
	[self tint];
	[self updateIconImageViewFrame];
}

- (void)setActive:(BOOL)active {
	if (_active != active) {
		_active = active;
		
		[self tint];
	}
}

@end
