//
//  PDGesturedTableView.h
//  Proday
//
//  Created by David Román Aguirre on 24/08/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDGesturedTableView;
@class PDGesturedTableViewCell;

#pragma mark Interfaces

@interface PDGesturedTableViewCellAction : NSObject

@property (copy, nonatomic) void (^didActivateBlock)(PDGesturedTableView *, PDGesturedTableViewCell *);
@property (copy, nonatomic) void (^didHighlightBlock)(PDGesturedTableView *, PDGesturedTableViewCell *);
@property (copy, nonatomic) void (^didUnhighlightBlock)(PDGesturedTableView *, PDGesturedTableViewCell *);

+ (id)actionForFraction:(CGFloat)fraction icon:(UIImage *)icon color:(UIColor *)color;

@end

@interface PDGesturedTableViewCell : UITableViewCell <UIGestureRecognizerDelegate>

- (void)addActionForFraction:(CGFloat)fraction icon:(UIImage *)icon color:(UIColor *)color activationBlock:(void (^)(PDGesturedTableView * gesturedTableView, PDGesturedTableViewCell * cell))activationBlock highlightBlock:(void (^)(PDGesturedTableView * gesturedTableView, PDGesturedTableViewCell * cell))highlightBlock unhighlightBlock:(void (^)(PDGesturedTableView * gesturedTableView, PDGesturedTableViewCell * cell))unhighlightBlock;
- (void)addAction:(PDGesturedTableViewCellAction *)action;

@end

@interface PDGesturedTableView : UITableView {
    BOOL justMovedToNewSuperview;
}

@property (copy, nonatomic) void (^didMoveCellFromIndexPathToIndexPathBlock)(NSIndexPath * fromIndexPath, NSIndexPath * toIndexPath);
@property (copy, nonatomic) void (^didFinishMovingCellBlock)(NSIndexPath * oldIndexPath, NSIndexPath * newIndexPath);

@property (nonatomic) BOOL enabled;
@property (nonatomic) CGFloat edgeSlidingMargin;

- (void)updateAnimatedly:(BOOL)animatedly;
- (void)removeCell:(PDGesturedTableViewCell *)cell completion:(void (^)(void))completion;
- (void)replaceCell:(PDGesturedTableViewCell *)cell completion:(void (^)(void))completion;

@end