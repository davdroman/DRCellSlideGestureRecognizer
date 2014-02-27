//
//  PDGestureTableView.h
//  Proday
//
//  Created by David Román Aguirre on 24/08/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDGestureTableView;
@class PDGestureTableViewCell;

#pragma mark Interfaces

@interface PDGestureTableViewCellAction : NSObject

@property (strong, nonatomic) UIImage *icon;
@property (strong, nonatomic) UIColor *color;
@property (nonatomic) CGFloat fraction;
// @property (nonatomic) CGFloat elasticity;

@property (copy, nonatomic) void (^didTriggerBlock)(PDGestureTableView *, NSIndexPath *);
@property (copy, nonatomic) void (^didHighlightBlock)(PDGestureTableView *, PDGestureTableViewCell *);
@property (copy, nonatomic) void (^didUnhighlightBlock)(PDGestureTableView *, PDGestureTableViewCell *);

+ (id)actionWithIcon:(UIImage *)icon color:(UIColor *)color fraction:(CGFloat)fraction didTriggerBlock:(void (^)(PDGestureTableView *gestureTableView, NSIndexPath *cell))didTriggerBlock;

@end

@interface PDGestureTableViewCell : UITableViewCell <UIGestureRecognizerDelegate>

@property (nonatomic) BOOL actionIconsFollowSliding;
@property (nonatomic) CGFloat actionIconsMargin;
// @property (nonatomic) BOOL movesFreely;
// @property (nonatomic) BOOL bounces;

@property (strong, nonatomic) PDGestureTableViewCellAction *firstLeftAction;
@property (strong, nonatomic) PDGestureTableViewCellAction *secondLeftAction;

@property (strong, nonatomic) PDGestureTableViewCellAction *firstRightAction;
@property (strong, nonatomic) PDGestureTableViewCellAction *secondRightAction;

- (void)setup;

@end

@interface PDGestureTableView : UITableView

@property (nonatomic, getter = isEnabled) BOOL enabled;
@property (nonatomic) NSTimeInterval animationsDuration;
@property (nonatomic) BOOL cellBounceWhenReplaced;
// @property (nonatomic) CGFloat edgeAutoscrollMargin;

@property (copy, nonatomic) BOOL (^shouldMoveCellFromIndexPathToIndexPathBlock)(NSIndexPath *, NSIndexPath *);
@property (copy, nonatomic) void (^didMoveCellFromIndexPathToIndexPathBlock)(NSIndexPath *, NSIndexPath *);

- (void)setup;

- (void)pushCellForIndexPath:(NSIndexPath *)indexPath completion:(void (^)(void))completion;
- (void)deleteCellForIndexPath:(NSIndexPath *)indexPath animation:(UITableViewRowAnimation)animation completion:(void (^)(void))completion;

- (void)pushAndDeleteCellForIndexPath:(NSIndexPath *)indexPath completion:(void (^)(void))completion;

- (void)replaceCellForIndexPath:(NSIndexPath *)indexPath completion:(void (^)(void))completion;

@end