//
//  PDGesturedTableView.m
//  Proday
//
//  Created by David Román Aguirre on 24/08/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import "PDGesturedTableView.h"

#pragma mark Interfaces Extensions

@interface PDGesturedTableViewCellTitleTextView ()

- (void)recalculateFrame;

@end

@interface PDGesturedTableViewCellSlidingSideView ()

@property (nonatomic) BOOL active;

@end

@interface PDGesturedTableViewCell ()

@property (strong, nonatomic) PDGesturedTableView * gesturedTableView;
@property (strong, nonatomic) UIView * slidingSideViewsBaseView;

@end

@interface PDGesturedTableView ()

@property (nonatomic) BOOL updating;

@property (strong, nonatomic) NSMutableArray * indexPathsToDismiss;

@property (strong, nonatomic) NSIndexPath * currentUpdatingRowIndexPath;
@property (strong, nonatomic) UITextView * currentUpdatingTitleTextView; // I store this value because it's used in tableView:heightForRowAtIndexPath: and whether you call cellForRowAtIndexPath: to get the current updating cell through currentUpdatingRowIndexPath, what basically happens is: infinite loop = CRASH.

- (CGFloat)heightForTextViewContainingString:(NSString *)string;

@end

#pragma mark Implementations

@implementation PDGesturedTableViewCellTitleTextView

- (id)init {
    if (self = [super init]) {
        [self setScrollEnabled:NO];
        [self setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:20]];
        [self setSpellCheckingType:UITextSpellCheckingTypeNo];
    }
    
    return self;
}

- (void)setText:(NSString *)text {
    [super setText:text];
    
    [self recalculateFrame];
}

- (void)recalculateFrame {
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.contentSize.height)];
}

@end

@implementation PDGesturedTableViewCellSlidingSideView

- (id)initWithIcon:(UIImage *)icon highlightIcon:(UIImage *)highlightIcon width:(CGFloat)width highlightColor:(UIColor *)highlightColor {
    if (self = [super initWithFrame:CGRectMake(0, 0, width, 0)]) {
        self.highlightColor = highlightColor;
        
        self.iconImageView = [[UIImageView alloc] initWithImage:icon];
        [self.iconImageView setHighlightedImage:highlightIcon];
        [self addSubview:self.iconImageView];
    }
    
    return self;
}

@end

#define kDefaultSlidingMargin 25

@implementation PDGesturedTableViewCell

- (id)initForGesturedTableView:(PDGesturedTableView *)gesturedTableView leftSlidingSideView:(PDGesturedTableViewCellSlidingSideView *)leftSlidingSideView rightSlidingSideView:(PDGesturedTableViewCellSlidingSideView *)rightSlidingSideView reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.gesturedTableView = gesturedTableView;
        
        self.titleTextView = [PDGesturedTableViewCellTitleTextView new];
        [self.titleTextView setFrame:CGRectMake(self.gesturedTableView.titleTextViewMargin, self.gesturedTableView.titleTextViewMargin, self.gesturedTableView.frame.size.width - self.gesturedTableView.titleTextViewMargin*2, 0)];
        [self.titleTextView setDelegate:self];
        [self.titleTextView setBackgroundColor:[UIColor clearColor]];
        [self.titleTextView setFont:self.gesturedTableView.titleTextViewModel.font];
        [self.titleTextView setTextColor:self.gesturedTableView.titleTextViewModel.textColor];
        
        self.slidingSideViewsBaseView = [UIView new];
        self.leftSlidingSideView = leftSlidingSideView;
        self.rightSlidingSideView = rightSlidingSideView;
        
        UIPanGestureRecognizer * slidePanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(slideCell:)];
        [slidePanGestureRecognizer setDelegate:self];
        [self addGestureRecognizer:slidePanGestureRecognizer];
        
        [self.contentView addSubview:self.titleTextView];
    }
    
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:NSClassFromString(@"UIPanGestureRecognizer")]) {
        UIPanGestureRecognizer * panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        
        CGFloat horizontalLocation = [panGestureRecognizer locationInView:self].x;
        CGPoint translation = [panGestureRecognizer translationInView:self];
        
        CGFloat slidingMargin = kDefaultSlidingMargin;
        
        if (horizontalLocation > slidingMargin && horizontalLocation < panGestureRecognizer.view.frame.size.width - slidingMargin && fabsf(translation.x) > fabsf(translation.y)) {
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
        
        if (self.leftSlidingSideView == nil && horizontalTranslation >= 0 && self.frame.origin.x == 0) {
            [self setFrame:CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
        } else if (self.rightSlidingSideView == nil && horizontalTranslation < 0 && self.frame.origin.x <= 0) {
            [self setFrame:CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
        } else {
            [self.leftSlidingSideView setActive:self.frame.origin.x > self.leftSlidingSideView.frame.size.width];
            [self.rightSlidingSideView setActive:self.frame.size.width - (self.frame.origin.x + self.frame.size.width) > self.rightSlidingSideView.frame.size.width];
            
            CGFloat weight = 1;
            
            if (self.leftSlidingSideView.active) {
                weight = 1/(self.frame.origin.x-self.leftSlidingSideView.frame.size.width);
            } else if (self.rightSlidingSideView.active) {
                weight = 1/((self.frame.size.width - (self.frame.origin.x + self.frame.size.width)) - self.rightSlidingSideView.frame.size.width);
            }
            
            weight = MIN(1, weight);
            
            [self setFrame:CGRectMake(self.frame.origin.x + horizontalTranslation * weight, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
            
            if (self.frame.origin.x > 0) {
                if ([self.leftSlidingSideView active] && horizontalTranslation > 0) {
                    [self.slidingSideViewsBaseView setBackgroundColor:self.leftSlidingSideView.highlightColor];
                    [self.leftSlidingSideView.iconImageView setHighlighted:YES];
                    if ([self.gesturedTableView.secondaryDelegate respondsToSelector:@selector(gesturedTableView:cellDidReachLeftHighlightLimit:)]) {
                        [self.gesturedTableView.secondaryDelegate gesturedTableView:self.gesturedTableView cellDidReachLeftHighlightLimit:self];
                    }
                } else if (![self.leftSlidingSideView active] && horizontalTranslation < 0) {
                    [self.slidingSideViewsBaseView setBackgroundColor:[UIColor clearColor]];
                    [self.leftSlidingSideView.iconImageView setHighlighted:NO];
                    if ([self.gesturedTableView.secondaryDelegate respondsToSelector:@selector(gesturedTableView:cellDidReachLeftNoHighlightLimit:)]) {
                        [self.gesturedTableView.secondaryDelegate gesturedTableView:self.gesturedTableView cellDidReachLeftNoHighlightLimit:self];
                    }
                }
            } else {
                if ([self.rightSlidingSideView active] && horizontalTranslation < 0) {
                    [self.slidingSideViewsBaseView setBackgroundColor:self.rightSlidingSideView.highlightColor];
                    [self.rightSlidingSideView.iconImageView setHighlighted:YES];
                    if ([self.gesturedTableView.secondaryDelegate respondsToSelector:@selector(gesturedTableView:cellDidReachRightHighlightLimit:)]) {
                        [self.gesturedTableView.secondaryDelegate gesturedTableView:self.gesturedTableView cellDidReachRightHighlightLimit:self];
                    }
                } else if (![self.rightSlidingSideView active] && horizontalTranslation > 0) {
                    [self.slidingSideViewsBaseView setBackgroundColor:[UIColor clearColor]];
                    [self.rightSlidingSideView.iconImageView setHighlighted:NO];
                    if ([self.gesturedTableView.secondaryDelegate respondsToSelector:@selector(gesturedTableView:cellDidReachRightNoHighlightLimit:)]) {
                        [self.gesturedTableView.secondaryDelegate gesturedTableView:self.gesturedTableView cellDidReachRightNoHighlightLimit:self];
                    }
                }
            }
            
            [self.leftSlidingSideView.iconImageView setAlpha:self.frame.origin.x/self.leftSlidingSideView.frame.size.width];
            [self.rightSlidingSideView.iconImageView setAlpha:(self.frame.size.width - (self.frame.origin.x + self.frame.size.width))/self.rightSlidingSideView.frame.size.width];
        }
    } else if (slidePanGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (self.leftSlidingSideView.active) {
            [self.gesturedTableView.secondaryDelegate gesturedTableView:self.gesturedTableView didSlideLeftCell:self];
        } else if (self.rightSlidingSideView.active) {
            [self.gesturedTableView.secondaryDelegate gesturedTableView:self.gesturedTableView didSlideRightCell:self];
        } else {
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
    
    [slidePanGestureRecognizer setTranslation:CGPointZero inView:self];
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
    }];
}

- (void)moveCellToHorizontalPosition:(CGFloat)horizontalPosition completion:(void (^)(void))completion {
    [self.gesturedTableView.indexPathsToDismiss addObject:[self.gesturedTableView indexPathForCell:self]];
    
    [UIView animateWithDuration:0.4 animations:^{
        [self setFrame:CGRectMake(horizontalPosition, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.slidingSideViewsBaseView setAlpha:0];
        } completion:^(BOOL finished) {
            [self setHidden:YES];
            if (completion) completion();
            if ([[self.gesturedTableView indexPathForCell:self] isEqual:[self.gesturedTableView.indexPathsToDismiss lastObject]]) {
                [self.gesturedTableView deleteRowsAtIndexPaths:self.gesturedTableView.indexPathsToDismiss withRowAnimation:UITableViewRowAnimationNone];
                [self.gesturedTableView.indexPathsToDismiss removeAllObjects];
            }
            [self.slidingSideViewsBaseView removeFromSuperview];
        }];
    }];
}

- (void)dismissWithCompletion:(void (^)(void))completion {
    if (self.frame.origin.x > 0) {
        [self moveCellToHorizontalPosition:self.frame.size.width completion:completion];
    } else {
        [self moveCellToHorizontalPosition:-self.frame.size.width completion:completion];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([self.gesturedTableView.secondaryDelegate respondsToSelector:@selector(gesturedTableView:gesturedTableViewCell:titleTextViewDidBeginEditing:)]) [self.gesturedTableView.secondaryDelegate gesturedTableView:self.gesturedTableView gesturedTableViewCell:self titleTextViewDidBeginEditing:textView];
    
    for (NSIndexPath * indexPath in self.gesturedTableView.indexPathsForVisibleRows) {
        PDGesturedTableViewCell * cell = (PDGesturedTableViewCell *)[self.gesturedTableView cellForRowAtIndexPath:indexPath];
        if (cell.titleTextView == (PDGesturedTableViewCellTitleTextView *)textView) {
            self.gesturedTableView.currentUpdatingRowIndexPath = indexPath;
            self.gesturedTableView.currentUpdatingTitleTextView = (PDGesturedTableViewCellTitleTextView *)textView;
        }
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    [self.gesturedTableView beginUpdates];
    [self.gesturedTableView endUpdates];
    [self.titleTextView recalculateFrame];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        if ([self.gesturedTableView.secondaryDelegate respondsToSelector:@selector(gesturedTableView:gesturedTableViewCell:titleTextViewDidEndEditing:)]) [self.gesturedTableView.secondaryDelegate gesturedTableView:self.gesturedTableView gesturedTableViewCell:self titleTextViewDidEndEditing:textView];
        return NO;
    }
    
    return YES;
}

@end

@implementation PDGesturedTableView

- (id)init {
    if (self = [super init]) {
        [self setDelegate:self];
        [self setAllowsSelection:NO];
        
        self.indexPathsToDismiss = [NSMutableArray array];
        
        self.titleTextViewMargin = 10;
        
        self.titleTextViewModel = [PDGesturedTableViewCellTitleTextView new];
        [self.titleTextViewModel setFrame:CGRectMake(self.titleTextViewMargin, self.titleTextViewMargin, 0, 0)];
        [self.titleTextViewModel setHidden:YES];
        
        [self addSubview:self.titleTextViewModel];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [self.titleTextViewModel setFrame:CGRectMake(self.titleTextViewMargin, self.titleTextViewMargin, self.frame.size.width-self.titleTextViewMargin*2, 0)];
}

- (void)beginUpdates {
    self.updating = YES;
    [UIView setAnimationsEnabled:NO];
    [super beginUpdates];
}

- (void)endUpdates {
    [super endUpdates];
    [UIView setAnimationsEnabled:YES];
    self.updating = NO;
}

- (CGFloat)heightForTextViewContainingString:(NSString *)string {
    [self.titleTextViewModel setText:string];
    
    return self.titleTextViewModel.contentSize.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.00000001;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.updating == YES && [self.currentUpdatingRowIndexPath isEqual:indexPath]) {
        return self.currentUpdatingTitleTextView.contentSize.height+self.titleTextViewMargin*2;
    }
    
    NSString * string = [self.secondaryDelegate gesturedTableView:self stringForTitleTextViewForRowAtIndexPath:indexPath];
    
    CGFloat height = [self heightForTextViewContainingString:string] + self.titleTextViewMargin*2;
    
    return height;
}

@end