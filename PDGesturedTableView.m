//
//  PDGesturedTableView.m
//  Proday
//
//  Created by David Román Aguirre on 24/08/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import "PDGesturedTableView.h"

#pragma mark Interface Extensions

@interface PDGesturedTableViewCellSlidingSideView ()

@property (nonatomic) BOOL active;

@end

@interface PDGesturedTableViewCell ()

@property (strong, nonatomic) PDGesturedTableView * gesturedTableView;
@property (strong, nonatomic) UIView * slidingSideViewsBaseView;

@end

@interface PDGesturedTableView ()

@property (nonatomic) BOOL deleting;

@end

#pragma mark Implementations

@implementation PDGesturedTableViewCellSlidingSideView

- (id)initWithIcon:(UIImage *)icon highlightIcon:(UIImage *)highlightIcon width:(CGFloat)width highlightColor:(UIColor *)highlightColor {
    if (self = [super initWithFrame:CGRectMake(0, 0, width, 0)]) {
        self.highlightColor = highlightColor;
        
        self.iconImageView = [[UIImageView alloc] initWithImage:icon highlightedImage:highlightIcon];
        
        [self addSubview:self.iconImageView];
    }
    
    return self;
}

@end

@implementation PDGesturedTableViewCell

- (void)setFrame:(CGRect)frame {
    [super setFrame:(self.gesturedTableView.deleting ? CGRectMake(self.frame.origin.x, frame.origin.y, frame.size.width, frame.size.height) : frame)];
}

- (id)initForGesturedTableView:(PDGesturedTableView *)gesturedTableView leftSlidingSideView:(PDGesturedTableViewCellSlidingSideView *)leftSlidingSideView rightSlidingSideView:(PDGesturedTableViewCellSlidingSideView *)rightSlidingSideView reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.gesturedTableView = gesturedTableView;
        
        self.slidingSideViewsBaseView = [UIView new];
        self.leftSlidingSideView = leftSlidingSideView;
        self.rightSlidingSideView = rightSlidingSideView;
        
        UIPanGestureRecognizer * slidePanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(slideCell:)];
        [slidePanGestureRecognizer setDelegate:self];
        [self addGestureRecognizer:slidePanGestureRecognizer];
    }
    
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:NSClassFromString(@"UIPanGestureRecognizer")]) {
        UIPanGestureRecognizer * panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        
        CGFloat horizontalLocation = [panGestureRecognizer locationInView:self].x;
        CGPoint translation = [panGestureRecognizer translationInView:self];
        
        // Testing Stuff...
        
        /* NSLog(@"--------------");
        NSLog(@"1: %@", (horizontalLocation > self.gesturedTableView.edgeSlidingMargin ? @"YES" : @"NO"));
        NSLog(@"2: %@", (horizontalLocation < panGestureRecognizer.view.frame.size.width - self.gesturedTableView.edgeSlidingMargin ? @"YES" : @"NO"));
        NSLog(@"3: %@", (fabsf(translation.x) >= fabsf(translation.y) ? @"YES" : @"NO"));
        NSLog(@"4: %@", (self.gesturedTableView.enabled ? @"YES" : @"NO")); */
         
        if (horizontalLocation > self.gesturedTableView.edgeSlidingMargin && horizontalLocation < panGestureRecognizer.view.frame.size.width - self.gesturedTableView.edgeSlidingMargin && fabsf(translation.x) >= fabsf(translation.y) && self.gesturedTableView.enabled) {
            return YES;
        }
        
        return NO;
    }
    
    return YES;
}

- (void)slideCell:(UIPanGestureRecognizer *)slidePanGestureRecognizer {
    if (slidePanGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self.slidingSideViewsBaseView setFrame:CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
        [self.gesturedTableView insertSubview:self.slidingSideViewsBaseView belowSubview:self];
        [self.gesturedTableView sendSubviewToBack:self.slidingSideViewsBaseView];
        
        if (self.leftSlidingSideView != nil) {
            [self.leftSlidingSideView setFrame:CGRectMake(0, 0, self.leftSlidingSideView.frame.size.width, self.slidingSideViewsBaseView.frame.size.height)];
            [self.leftSlidingSideView.iconImageView setCenter:CGPointMake(self.leftSlidingSideView.frame.size.width/2, self.leftSlidingSideView.frame.size.height/2)];
            [self.slidingSideViewsBaseView addSubview:self.leftSlidingSideView];
        }
        
        if (self.rightSlidingSideView != nil) {
            [self.rightSlidingSideView setFrame:CGRectMake(self.frame.size.width-self.rightSlidingSideView.frame.size.width, 0, self.rightSlidingSideView.frame.size.width, self.slidingSideViewsBaseView.frame.size.height)];
            [self.rightSlidingSideView.iconImageView setCenter:CGPointMake(self.rightSlidingSideView.frame.size.width/2, self.rightSlidingSideView.frame.size.height/2)];
            [self.slidingSideViewsBaseView addSubview:self.rightSlidingSideView];
        }
    } else if (slidePanGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat horizontalTranslation = [slidePanGestureRecognizer translationInView:self].x;
        [slidePanGestureRecognizer setTranslation:CGPointZero inView:self];
        
        if (self.leftSlidingSideView == nil && horizontalTranslation > 0 && self.frame.origin.x >= 0) {
            [self setFrame:CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
        } else if (self.rightSlidingSideView == nil && horizontalTranslation < 0 && self.frame.origin.x <= 0) {
            [self setFrame:CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
        } else {
            CGFloat weight = 1;
            
            BOOL leftSideReached = self.frame.origin.x > self.leftSlidingSideView.frame.size.width;
            BOOL rightSideReached = self.frame.size.width - (self.frame.origin.x + self.frame.size.width) > self.rightSlidingSideView.frame.size.width;
            
            if (leftSideReached || rightSideReached) {
                weight = 5;
            }
            
            [self setFrame:CGRectMake(self.frame.origin.x + horizontalTranslation/weight, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
            
            if (self.frame.origin.x > 0) {
                if (![self.leftSlidingSideView active] && leftSideReached) {
                    [self.slidingSideViewsBaseView setBackgroundColor:self.leftSlidingSideView.highlightColor];
                    [self.leftSlidingSideView.iconImageView setHighlighted:YES];
                    if (self.gesturedTableView.cellDidReachLeftHighlightLimit) self.gesturedTableView.cellDidReachLeftHighlightLimit(self);
                    [self.leftSlidingSideView setActive:YES];
                } else if ([self.leftSlidingSideView active] && !leftSideReached) {
                    [self.slidingSideViewsBaseView setBackgroundColor:[UIColor clearColor]];
                    [self.leftSlidingSideView.iconImageView setHighlighted:NO];
                    if (self.gesturedTableView.cellDidReachLeftNoHighlightLimit) self.gesturedTableView.cellDidReachLeftNoHighlightLimit(self);
                    [self.leftSlidingSideView setActive:NO];
                }
            } else {
                if (![self.rightSlidingSideView active] && rightSideReached) {
                    [self.slidingSideViewsBaseView setBackgroundColor:self.rightSlidingSideView.highlightColor];
                    [self.rightSlidingSideView.iconImageView setHighlighted:YES];
                    if (self.gesturedTableView.cellDidReachRightHighlightLimit) self.gesturedTableView.cellDidReachRightHighlightLimit(self);
                    [self.rightSlidingSideView setActive:YES];
                } else if ([self.rightSlidingSideView active] && !rightSideReached) {
                    [self.slidingSideViewsBaseView setBackgroundColor:[UIColor clearColor]];
                    [self.rightSlidingSideView.iconImageView setHighlighted:NO];
                    if (self.gesturedTableView.cellDidReachRightNoHighlightLimit) self.gesturedTableView.cellDidReachRightNoHighlightLimit(self);
                    [self.rightSlidingSideView setActive:NO];
                }
            }
            
            [self.leftSlidingSideView.iconImageView setAlpha:self.frame.origin.x/self.leftSlidingSideView.frame.size.width];
            [self.rightSlidingSideView.iconImageView setAlpha:(self.frame.size.width - (self.frame.origin.x + self.frame.size.width))/self.rightSlidingSideView.frame.size.width];
        }
    } else if (slidePanGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (self.leftSlidingSideView.active) {
            self.gesturedTableView.didTriggerLeftSideBlock(self);
        } else if (self.rightSlidingSideView.active) {
            self.gesturedTableView.didTriggerRightSideBlock(self);
        } else if (self.frame.origin.x != 0) {
            [UIView animateWithDuration:0.1 animations:^{
                [self setFrame:CGRectMake((self.frame.origin.x > 0 ? -7 : 7), self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
                [self.slidingSideViewsBaseView setAlpha:0];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.1 animations:^{
                    [self setFrame:CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
                } completion:^(BOOL finished) {
                    [self.slidingSideViewsBaseView removeFromSuperview];
                    [self.slidingSideViewsBaseView setAlpha:1];
                }];
            }];
        }
    }
}

- (void)replace {
    [UIView animateWithDuration:0.3 animations:^{
        [self setFrame:CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
        [self.slidingSideViewsBaseView setAlpha:0];
    } completion:^(BOOL finished) {
        [self.slidingSideViewsBaseView setBackgroundColor:[UIColor clearColor]];
        [self.leftSlidingSideView.iconImageView setHighlighted:NO];
        [self.rightSlidingSideView.iconImageView setHighlighted:NO];
        [self.slidingSideViewsBaseView removeFromSuperview];
        [self.slidingSideViewsBaseView setAlpha:1];
        [self.leftSlidingSideView setActive:NO];
        [self.rightSlidingSideView setActive:NO];
    }];
}

- (void)moveCellToHorizontalPosition:(CGFloat)horizontalPosition completion:(void (^)(NSIndexPath * indexPath))completion {
    [UIView animateWithDuration:0.4 animations:^{
        [self setFrame:CGRectMake(horizontalPosition, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.slidingSideViewsBaseView setAlpha:0];
        } completion:^(BOOL finished) {
            NSIndexPath * indexPath = [self.gesturedTableView indexPathForCell:self];
            completion(indexPath);
            [self.gesturedTableView setDeleting:YES];
            [self.gesturedTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
            [self.gesturedTableView setDeleting:NO];
            [self.slidingSideViewsBaseView removeFromSuperview];
        }];
    }];
}

- (void)dismissWithCompletion:(void (^)(NSIndexPath * indexPath))completion {
    [self moveCellToHorizontalPosition:(self.frame.origin.x > 0 ? self.frame.size.width : -self.frame.size.width) completion:completion];
}

@end

@implementation PDGesturedTableView

- (id)init {
    if (self = [super init]) {
        [self setAllowsSelection:NO];
        [self setSeparatorInset:UIEdgeInsetsZero];
        
        [self setEdgeSlidingMargin:35];
        [self setEnabled:YES];
        
        [self setTableFooterView:[UIView new]];
    }
    
    return self;
}

@end