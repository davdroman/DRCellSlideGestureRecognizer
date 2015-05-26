//
//  DRCellSlideAction.h
//  DRCellSlideGestureRecognizer
//
//  Created by David Román Aguirre on 12/5/15.
//
//

#import <UIKit/UIKit.h>

@interface DRCellSlideAction : NSObject

typedef NS_ENUM(NSUInteger, DRCellSlideActionBehavior) {
	DRCellSlideActionPullBehavior,
	DRCellSlideActionPushBehavior,
};

typedef void(^DRCellSlideActionBlock)(UITableView *tableView, NSIndexPath *indexPath);
typedef void(^DRCellSlideActionStateBlock)(DRCellSlideAction *action, BOOL active);

@property (nonatomic) DRCellSlideActionBehavior behavior;
@property (nonatomic, readonly) CGFloat fraction;
@property (nonatomic) CGFloat elasticity;

@property (nonatomic, strong) UIColor *activeBackgroundColor;
@property (nonatomic, strong) UIColor *inactiveBackgroundColor;

@property (nonatomic, strong) UIColor *activeColor;
@property (nonatomic, strong) UIColor *inactiveColor;

@property (nonatomic, strong) UIImage *icon;
@property (nonatomic) CGFloat iconMargin;

@property (nonatomic, copy) DRCellSlideActionBlock willTriggerBlock;
@property (nonatomic, copy) DRCellSlideActionBlock didTriggerBlock;
@property (nonatomic, copy) DRCellSlideActionStateBlock didChangeStateBlock;

+ (instancetype)actionForFraction:(CGFloat)fraction;

@end
