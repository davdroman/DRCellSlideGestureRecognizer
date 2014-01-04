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

@property (copy, nonatomic) void (^didTriggerBlock)(PDGestureTableView *, PDGestureTableViewCell *);
@property (copy, nonatomic) void (^didHighlightBlock)(PDGestureTableView *, PDGestureTableViewCell *);
@property (copy, nonatomic) void (^didUnhighlightBlock)(PDGestureTableView *, PDGestureTableViewCell *);

+ (id)actionWithIcon:(UIImage *)icon color:(UIColor *)color;
+ (id)actionWithIcon:(UIImage *)icon color:(UIColor *)color fraction:(CGFloat)fraction;
+ (id)actionWithIcon:(UIImage *)icon color:(UIColor *)color fraction:(CGFloat)fraction didTriggerBlock:(void (^)(PDGestureTableView * gestureTableView, PDGestureTableViewCell * cell))didTriggerBlock;
+ (id)actionWithIcon:(UIImage *)icon color:(UIColor *)color fraction:(CGFloat)fraction didTriggerBlock:(void (^)(PDGestureTableView * gestureTableView, PDGestureTableViewCell * cell))didTriggerBlock didHighlightBlock:(void (^)(PDGestureTableView * gestureTableView, PDGestureTableViewCell * cell))didHighlightBlock didUnhighlightBlock:(void (^)(PDGestureTableView * gestureTableView, PDGestureTableViewCell * cell))didUnhighlightBlock;

@end

@interface PDGestureTableViewCell : UITableViewCell <UIGestureRecognizerDelegate>

@property (nonatomic) BOOL iconsFollowSliding;
@property (nonatomic) CGFloat iconsMargin;
@property (strong, nonatomic) UIColor * normalColor;
@property (nonatomic) CGFloat replacementDuration;

// @property (nonatomic) BOOL bounces;
// @property (nonatomic) CGFloat elasticity;

@property (strong, nonatomic) PDGestureTableViewCellAction * firstLeftAction;
@property (strong, nonatomic) PDGestureTableViewCellAction * secondLeftAction;

@property (strong, nonatomic) PDGestureTableViewCellAction * firstRightAction;
@property (strong, nonatomic) PDGestureTableViewCellAction * secondRightAction;

@end

@interface PDGestureTableView : UITableView

@property (copy, nonatomic) void (^didMoveCellFromIndexPathToIndexPathBlock)(NSIndexPath * fromIndexPath, NSIndexPath * toIndexPath);
@property (copy, nonatomic) void (^didFinishMovingCellBlock)(NSIndexPath * oldIndexPath, NSIndexPath * newIndexPath);

@property (nonatomic, getter = isEnabled) BOOL enabled;
@property (nonatomic) CGFloat edgeSlidingMargin;

- (void)removeCell:(PDGestureTableViewCell *)cell completion:(void (^)(void))completion;
- (void)replaceCell:(PDGestureTableViewCell *)cell bounce:(CGFloat)bounce completion:(void (^)(void))completion;

@end