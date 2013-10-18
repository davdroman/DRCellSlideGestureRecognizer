//
//  PDGesturedTableView.h
//  Proday
//
//  Created by David Román Aguirre on 24/08/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDGesturedTableView;

#pragma mark Interfaces

@interface PDGesturedTableViewCellSlidingSideView : UIView

- (id)initWithIcon:(UIImage *)icon highlightedIcon:(UIImage *)highlightedIcon width:(CGFloat)width highlightedColor:(UIColor *)highlightedColor;

@property (strong, nonatomic) UIImageView * iconImageView;
@property (strong, nonatomic) UIColor * highlightedColor;

@end

@interface PDGesturedTableViewCell : UITableViewCell <UITextViewDelegate, UIGestureRecognizerDelegate>

- (id)initForGesturedTableView:(PDGesturedTableView *)gesturedTableView style:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@property (strong, nonatomic) PDGesturedTableViewCellSlidingSideView * leftSlidingSideView;
@property (strong, nonatomic) PDGesturedTableViewCellSlidingSideView * rightSlidingSideView;

- (void)replace;
- (void)dismissWithCompletion:(void (^)(NSIndexPath * indexPath))completion;

@end

@interface PDGesturedTableView : UITableView

@property (copy, nonatomic) void (^didTriggerLeftSideBlock)(PDGesturedTableViewCell * cell);
@property (copy, nonatomic) void (^didTriggerRightSideBlock)(PDGesturedTableViewCell * cell);
@property (copy, nonatomic) void (^cellDidReachLeftHighlightLimit)(PDGesturedTableViewCell * cell);
@property (copy, nonatomic) void (^cellDidReachLeftNoHighlightLimit)(PDGesturedTableViewCell * cell);
@property (copy, nonatomic) void (^cellDidReachRightHighlightLimit)(PDGesturedTableViewCell * cell);
@property (copy, nonatomic) void (^cellDidReachRightNoHighlightLimit)(PDGesturedTableViewCell * cell);

@property (nonatomic) CGFloat edgeSlidingMargin;

@property (strong, nonatomic) UIView * backgroundView;
@property (nonatomic) BOOL enabled;

@end