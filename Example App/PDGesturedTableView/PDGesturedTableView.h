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

@interface PDGesturedTableViewCellSlidingFraction : NSObject

@property (copy, nonatomic) void (^didReleaseBlock)(PDGesturedTableView * gestureTableView, PDGesturedTableViewCell * cell);
@property (copy, nonatomic) void (^didActivateBlock)(PDGesturedTableView * gestureTableView, PDGesturedTableViewCell * cell);
@property (copy, nonatomic) void (^didDeactivateBlock)(PDGesturedTableView * gestureTableView, PDGesturedTableViewCell * cell);

+ (id)slidingFractionWithIcon:(UIImage *)icon color:(UIColor *)color activationFraction:(CGFloat)activationFraction;

@end

@interface PDGesturedTableViewCell : UITableViewCell <UITextViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) BOOL bouncesAtLastSlidingFraction;

- (id)initForGesturedTableView:(PDGesturedTableView *)gesturedTableView style:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (void)addSlidingFraction:(PDGesturedTableViewCellSlidingFraction *)slidingFraction;

@end

@interface PDGesturedTableView : UITableView

@property (nonatomic) CGFloat edgeSlidingMargin;

@property (nonatomic) BOOL enabled;

- (void)updateAnimatedly:(BOOL)animatedly;
- (void)removeCell:(PDGesturedTableViewCell *)cell completion:(void (^)(void))completion;
- (void)replaceCell:(PDGesturedTableViewCell *)cell completion:(void (^)(void))completion;

@end