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

#pragma mark Protocols

@protocol PDGesturedTableViewSecondaryDelegate <NSObject>

@required
- (NSString *)gesturedTableView:(PDGesturedTableView *)gesturedTableView stringForTitleTextViewForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)gesturedTableView:(PDGesturedTableView *)gesturedTableView didSlideLeftCell:(PDGesturedTableViewCell *)cell;
- (void)gesturedTableView:(PDGesturedTableView *)gesturedTableView didSlideRightCell:(PDGesturedTableViewCell *)cell;

@optional
- (void)gesturedTableView:(PDGesturedTableView *)gesturedTableView gesturedTableViewCell:(PDGesturedTableViewCell *)gesturedTableViewCell titleTextViewDidBeginEditing:(UITextView *)titleTextView;
- (void)gesturedTableView:(PDGesturedTableView *)gesturedTableView gesturedTableViewCell:(PDGesturedTableViewCell *)gesturedTableViewCell titleTextViewDidEndEditing:(UITextView *)titleTextView;

- (void)gesturedTableView:(PDGesturedTableView *)gesturedTableView cellDidReachLeftHighlightLimit:(PDGesturedTableViewCell *)cell;
- (void)gesturedTableView:(PDGesturedTableView *)gesturedTableView cellDidReachLeftNoHighlightLimit:(PDGesturedTableViewCell *)cell;

- (void)gesturedTableView:(PDGesturedTableView *)gesturedTableView cellDidReachRightHighlightLimit:(PDGesturedTableViewCell *)cell;
- (void)gesturedTableView:(PDGesturedTableView *)gesturedTableView cellDidReachRightNoHighlightLimit:(PDGesturedTableViewCell *)cell;

@end

#pragma mark Interfaces

@interface PDGesturedTableViewCellTitleTextView : UITextView

@end

@interface PDGesturedTableViewCellSlidingSideView : UIView

- (id)initWithIcon:(UIImage *)icon highlightIcon:(UIImage *)highlightIcon width:(CGFloat)width highlightColor:(UIColor *)highlightColor;

@property (strong, nonatomic) UIImageView * iconImageView;
@property (strong, nonatomic) UIColor * highlightColor;

@end

@interface PDGesturedTableViewCell : UITableViewCell <UITextViewDelegate, UIGestureRecognizerDelegate>

- (id)initForGesturedTableView:(PDGesturedTableView *)gesturedTableView leftSlidingSideView:(PDGesturedTableViewCellSlidingSideView *)leftSlidingSideView rightSlidingSideView:(PDGesturedTableViewCellSlidingSideView *)rightSlidingSideView reuseIdentifier:(NSString *)reuseIdentifier;

@property (strong, nonatomic) PDGesturedTableViewCellTitleTextView * titleTextView;

@property (strong, nonatomic) PDGesturedTableViewCellSlidingSideView * leftSlidingSideView;
@property (strong, nonatomic) PDGesturedTableViewCellSlidingSideView * rightSlidingSideView;

- (void)replace;
- (void)dismissWithCompletion:(void (^)(void))completion;

@end

@interface PDGesturedTableView : UITableView <UITableViewDelegate>

@property (strong, nonatomic) id <PDGesturedTableViewSecondaryDelegate> secondaryDelegate;

// @property (strong, nonatomic) UIView * backgroundView;

@property (strong, nonatomic) UITextView * titleTextViewModel;
@property (nonatomic) CGFloat titleTextViewMargin;

@end