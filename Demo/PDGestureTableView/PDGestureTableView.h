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

@property (strong, nonatomic) UIImage * icon;
@property (strong, nonatomic) UIColor * color;
@property (nonatomic) CGFloat fraction;
// @property (nonatomic) CGFloat elasticity;

@property (copy, nonatomic) void (^didTriggerBlock)(PDGestureTableView *, PDGestureTableViewCell *);
@property (copy, nonatomic) void (^didHighlightBlock)(PDGestureTableView *, PDGestureTableViewCell *);
@property (copy, nonatomic) void (^didUnhighlightBlock)(PDGestureTableView *, PDGestureTableViewCell *);

+ (id)actionWithIcon:(UIImage *)icon color:(UIColor *)color fraction:(CGFloat)fraction didTriggerBlock:(void (^)(PDGestureTableView * gestureTableView, PDGestureTableViewCell * cell))didTriggerBlock;

@end

@interface PDGestureTableViewCell : UITableViewCell <UIGestureRecognizerDelegate>

@property (nonatomic) BOOL actionIconsFollowSliding;
@property (nonatomic) CGFloat actionIconsMargin;
@property (strong, nonatomic) UIColor * actionNormalColor;

// @property (nonatomic) BOOL bounces;

@property (strong, nonatomic) PDGestureTableViewCellAction * firstLeftAction;
@property (strong, nonatomic) PDGestureTableViewCellAction * secondLeftAction;

@property (strong, nonatomic) PDGestureTableViewCellAction * firstRightAction;
@property (strong, nonatomic) PDGestureTableViewCellAction * secondRightAction;

@end

@interface PDGestureTableView : UITableView

@property (nonatomic, getter = isEnabled) BOOL enabled;

@property (nonatomic) CGFloat edgeSlidingMargin;
@property (nonatomic) CGFloat edgeAutoscrollMargin;

@property (copy, nonatomic) void (^cellReplacingBlock)(PDGestureTableView *, PDGestureTableViewCell *);
@property (copy, nonatomic) BOOL (^shouldMoveCellFromIndexPathToIndexPathBlock)(NSIndexPath * fromIndexPath, NSIndexPath * toIndexPath);
@property (copy, nonatomic) void (^didMoveCellFromIndexPathToIndexPathBlock)(NSIndexPath * fromIndexPath, NSIndexPath * toIndexPath);

- (void)removeCell:(PDGestureTableViewCell *)cell duration:(NSTimeInterval)duration completion:(void (^)(void))completion;
- (void)replaceCell:(PDGestureTableViewCell *)cell duration:(NSTimeInterval)duration bounce:(CGFloat)bounce completion:(void (^)(void))completion;

@end