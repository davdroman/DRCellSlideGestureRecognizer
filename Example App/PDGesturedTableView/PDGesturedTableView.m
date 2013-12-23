//
//  PDGesturedTableView.m
//  Proday
//
//  Created by David Román Aguirre on 24/08/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import "PDGesturedTableView.h"

#pragma mark Interface Extensions -

@interface PDGesturedTableViewCellAction ()

@property (strong, nonatomic) UIImage * icon;
@property (strong, nonatomic) UIColor * color;
@property (nonatomic) CGFloat fraction;

@end

@interface PDGesturedTableViewCell () {
    CGFloat originalHorizontalCenterPoint;
    NSArray * currentActions;
    PDGesturedTableViewCellAction * currentAction;
    
    NSIndexPath * originIndexPath;
    CGFloat previousPoint;
    NSIndexPath * previousIndexPath;
    NSIndexPath * nextIndexPath;
    PDGesturedTableViewCell * nextCell;
    PDGesturedTableViewCell * previousCell;
    PDGesturedTableViewCell * copiedCell;
}

@property (weak, nonatomic) PDGesturedTableView * gesturedTableView;

@property (strong, nonatomic) UIView * leftSideView;
@property (strong, nonatomic) UIView * rightSideView;

@property (strong, nonatomic) NSMutableArray * leftActions;
@property (strong, nonatomic) NSMutableArray * rightActions;

@end

@interface PDGesturedTableView ()

@property (nonatomic) BOOL updating;
@property (nonatomic) BOOL moving;

@end

#pragma mark - Implementations -

@implementation PDGesturedTableViewCellAction

+ (id)actionForFraction:(CGFloat)fraction icon:(UIImage *)icon color:(UIColor *)color {
    PDGesturedTableViewCellAction * action = [PDGesturedTableViewCellAction new];
    
    [action setIcon:icon];
    [action setColor:color];
    [action setFraction:fraction];
    
    return action;
}

@end

@implementation PDGesturedTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.leftSideView = [UIView new];
        [self.leftSideView.layer setMasksToBounds:YES];
        self.rightSideView = [UIView new];
        [self.rightSideView.layer setMasksToBounds:YES];
        
        self.leftActions = [NSMutableArray new];
        self.rightActions = [NSMutableArray new];
        
        UIPanGestureRecognizer * panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(slideCell:)];
        [panGestureRecognizer setDelegate:self];
        [self addGestureRecognizer:panGestureRecognizer];
        
        UILongPressGestureRecognizer * longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(moveCell:)];
        [longPressGestureRecognizer setDelegate:self];
        [longPressGestureRecognizer setMinimumPressDuration:0.175];
        [self addGestureRecognizer:longPressGestureRecognizer];
    }
    
    return self;
}

- (void)didMoveToSuperview {
    [self setGesturedTableView:(PDGesturedTableView *)self.superview.superview];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:NSClassFromString(@"UIPanGestureRecognizer")]) {
        CGFloat horizontalLocation = [(UIPanGestureRecognizer *)gestureRecognizer locationInView:self].x;
        CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self];
         
        if (horizontalLocation > self.gesturedTableView.edgeSlidingMargin && horizontalLocation < self.frame.size.width - self.gesturedTableView.edgeSlidingMargin && fabsf(translation.x) >= fabsf(translation.y) && self.gesturedTableView.enabled) {
            return YES;
        }
        
        return NO;
    } else if ([gestureRecognizer isKindOfClass:NSClassFromString(@"UILongPressGestureRecognizer")]) {
        if (!self.gesturedTableView.moving && self.gesturedTableView.didMoveCellFromIndexPathToIndexPathBlock) {
            return YES;
        }
        
        return NO;
    }
    
    return YES;
}

- (void)addAction:(PDGesturedTableViewCellAction *)action {
    if (action.fraction > 0) {
        [self.leftActions addObject:action];
        [self.leftActions sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"fraction" ascending:YES]]];
    } else {
        [self.rightActions addObject:action];
        [self.rightActions sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"fraction" ascending:NO]]];
    }
}

- (void)addActionForFraction:(CGFloat)fraction icon:(UIImage *)icon color:(UIColor *)color activationBlock:(void (^)(PDGesturedTableView *, PDGesturedTableViewCell *))activationBlock highlightBlock:(void (^)(PDGesturedTableView *, PDGesturedTableViewCell *))highlightBlock unhighlightBlock:(void (^)(PDGesturedTableView *, PDGesturedTableViewCell *))unhighlightBlock {
    PDGesturedTableViewCellAction * action = [PDGesturedTableViewCellAction actionForFraction:fraction icon:icon color:color];
    
    [action setDidActivateBlock:activationBlock];
    [action setDidHighlightBlock:highlightBlock];
    [action setDidUnhighlightBlock:unhighlightBlock];
    
    [self addAction:action];
}

- (void)slideCell:(UIPanGestureRecognizer *)panGestureRecognizer {
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        originalHorizontalCenterPoint = self.center.x;
        
        UIImageView * leftSideViewIconView = [UIImageView new];
        [leftSideViewIconView setFrame:CGRectMake(20, 0, 50, self.frame.size.height)];
        [leftSideViewIconView setContentMode:UIViewContentModeLeft];
        [leftSideViewIconView.layer setMasksToBounds:NO];
        [leftSideViewIconView setTag:1];
        [self.leftSideView addSubview:leftSideViewIconView];
        [self.superview insertSubview:self.leftSideView belowSubview:self];
        
        UIImageView * rightSideViewIconView = [UIImageView new];
        [rightSideViewIconView setFrame:CGRectMake(20, 0, 50, self.frame.size.height)];
        [rightSideViewIconView setContentMode:UIViewContentModeRight];
        [rightSideViewIconView.layer setMasksToBounds:NO];
        [rightSideViewIconView setTag:1];
        [self.rightSideView addSubview:rightSideViewIconView];
        [self.superview insertSubview:self.rightSideView belowSubview:self];
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat horizontalTranslation = [panGestureRecognizer translationInView:self].x;
        
        if ([self.leftActions count] == 0 && self.frame.origin.x+horizontalTranslation > 0) horizontalTranslation = 0;
        else if ([self.rightActions count] == 0 && self.frame.origin.x+horizontalTranslation < 0) horizontalTranslation = 0;
        
        [self setFrame:CGRectMake(horizontalTranslation, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
        
        PDGesturedTableViewCellAction * oldAction = currentAction;
        
        if (self.frame.origin.x > 0) {
            currentAction = [self currentActionForArray:self.leftActions];
            [self setSideView:self.leftSideView withCurrentActionAndActionsArray:self.leftActions];
        } else if (self.frame.origin.x < 0) {
            currentAction = [self currentActionForArray:self.rightActions];
            [self setSideView:self.rightSideView withCurrentActionAndActionsArray:self.rightActions];
        }
        
        if (![oldAction isEqual:currentAction]) {
            if (oldAction.didUnhighlightBlock) oldAction.didUnhighlightBlock(self.gesturedTableView, self);
            if (currentAction.didHighlightBlock) currentAction.didHighlightBlock(self.gesturedTableView, self);
        }
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (!currentAction && self.frame.origin.x != 0) {
            [UIView animateWithDuration:0.1 animations:^{
                [self setFrame:CGRectMake((self.frame.origin.x > 0 ? -7 : 7), self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
                [self.leftSideView setAlpha:0];
                [self.rightSideView setAlpha:0];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.1 animations:^{
                    [self setFrame:CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
                } completion:^(BOOL finished) {
                    [self.leftSideView removeFromSuperview];
                    [self.rightSideView removeFromSuperview];
                }];
            }];
        } else if (currentAction.didActivateBlock) currentAction.didActivateBlock(self.gesturedTableView, self);
        
        currentAction = nil;
    }
}

- (PDGesturedTableViewCellAction *)currentActionForArray:(NSArray *)array {
    for (NSInteger i = [array count]-1; i >= 0; i--) {
        PDGesturedTableViewCellAction * action = array[i];
        
        if (fabsf(self.frame.origin.x/self.frame.size.width) >= fabsf(action.fraction)) {
            return action;
        }
    }
    
    return nil;
}

- (void)setSideView:(UIView *)sideView withCurrentActionAndActionsArray:(NSArray *)array {
    if (currentAction) {
        [sideView setBackgroundColor:currentAction.color];
        [(UIImageView *)[sideView viewWithTag:1] setImage:currentAction.icon];
        [sideView setAlpha:1];
    } else {
        PDGesturedTableViewCellAction * firstAction = [array firstObject];
        
        [sideView setBackgroundColor:[UIColor clearColor]];
        [(UIImageView *)[sideView viewWithTag:1] setImage:firstAction.icon];
        [sideView setAlpha:self.frame.origin.x/(firstAction.fraction*self.frame.size.width)];
    }
}

- (void)animateShadowWithRadius:(CGFloat)radius opacity:(CGFloat)opacity duration:(CFTimeInterval)duration {
    CABasicAnimation * shadowRadiusAnimation = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
    [shadowRadiusAnimation setFromValue:[NSNumber numberWithFloat:self.layer.shadowRadius]];
    [shadowRadiusAnimation setToValue:[NSNumber numberWithFloat:radius]];
    
    CABasicAnimation * shadowOpacityAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    [shadowOpacityAnimation setFromValue:[NSNumber numberWithFloat:self.layer.shadowOpacity]];
    [shadowOpacityAnimation setToValue:[NSNumber numberWithFloat:opacity]];
    
    CAAnimationGroup * shadowAnimations = [CAAnimationGroup new];
    [shadowAnimations setAnimations:@[shadowRadiusAnimation, shadowOpacityAnimation]];
    [shadowAnimations setRemovedOnCompletion:YES];
    [shadowAnimations setDuration:duration];
    
    [self.layer addAnimation:shadowAnimations forKey:@"shadowAnimations"];
    
    [self.layer setShadowRadius:radius];
    [self.layer setShadowOpacity:opacity];
}

- (void)moveCell:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self.gesturedTableView setMoving:YES];
        
        copiedCell = [[PDGesturedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.reuseIdentifier];
        [copiedCell setFrame:self.frame];
        [copiedCell setBackgroundColor:self.backgroundColor];
        
        for (UIView * view in self.contentView.subviews) {
            [copiedCell.contentView addSubview:view];
        }
        
        originIndexPath = [self.gesturedTableView indexPathForCell:self];
        [self setHidden:YES];
        [self.gesturedTableView addSubview:copiedCell];
        
        [copiedCell.layer setShadowOffset:CGSizeZero];
        [copiedCell animateShadowWithRadius:2 opacity:0.6 duration:0.2];
        
        [UIView animateWithDuration:0.2 animations:^{
            [copiedCell setTransform:CGAffineTransformMakeScale(1.1, 1.1)];
        }];
        
        previousPoint = [longPressGestureRecognizer locationInView:self.gesturedTableView].y;
        
        [self resetPreviousAndNextCellAndIndexPath];
        
        // Pretty hard thing to implement. Maybe someday :|
        
        /* autoscrollTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(autoscrollIfNeeded:)];
        [autoscrollTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode]; */
    } else if (longPressGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat currentPoint = [longPressGestureRecognizer locationInView:self.gesturedTableView].y;
        CGFloat verticalTranslation = currentPoint-previousPoint;
        previousPoint = currentPoint;
        
        [copiedCell setCenter:CGPointMake(copiedCell.center.x, copiedCell.center.y+verticalTranslation)];
        
        if (nextCell && verticalTranslation > 0 && copiedCell.center.y > nextCell.frame.origin.y) {
            self.gesturedTableView.didMoveCellFromIndexPathToIndexPathBlock([self.gesturedTableView indexPathForCell:self], nextIndexPath);
            
            [UIView animateWithDuration:0.2 animations:^{
                [self.gesturedTableView moveRowAtIndexPath:[self.gesturedTableView indexPathForCell:self] toIndexPath:nextIndexPath];
            } completion:^(BOOL finished) {
                if (finished) [self resetPreviousAndNextCellAndIndexPath];
            }];
        } else if (previousCell && verticalTranslation < 0 && copiedCell.frame.origin.y < previousCell.center.y) {
            self.gesturedTableView.didMoveCellFromIndexPathToIndexPathBlock([self.gesturedTableView indexPathForCell:self], previousIndexPath);
            
            [UIView animateWithDuration:0.2 animations:^{
                [self.gesturedTableView moveRowAtIndexPath:[self.gesturedTableView indexPathForCell:self] toIndexPath:previousIndexPath];
            } completion:^(BOOL finished) {
                if (finished) [self resetPreviousAndNextCellAndIndexPath];
            }];
        }
    } else if (longPressGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        // [autoscrollTimer invalidate];
        [self.gesturedTableView setMoving:NO];
        
        [copiedCell animateShadowWithRadius:0.5 opacity:0.4 duration:0.3];
        
        NSIndexPath * finalIndexPath = [self.gesturedTableView indexPathForCell:self];
        
        [UIView animateWithDuration:0.3 animations:^{
            [copiedCell setCenter:self.center];
            [copiedCell setTransform:CGAffineTransformMakeScale(1, 1)];
        } completion:^(BOOL finished) {
            for (UIView * view in copiedCell.contentView.subviews) {
                [self.contentView addSubview:view];
            }
            
            [copiedCell removeFromSuperview];
            [self setHidden:NO];
        }];
        
        if (self.gesturedTableView.didFinishMovingCellBlock) self.gesturedTableView.didFinishMovingCellBlock(originIndexPath, finalIndexPath);
    }
}

- (void)resetPreviousAndNextCellAndIndexPath {
    NSArray * indexPaths = [self.gesturedTableView indexPathsForVisibleRows];
    
    for (NSInteger i = 0; i < [indexPaths count]; i++) {
        NSIndexPath * indexPath = indexPaths[i];
        
        if ([indexPath isEqual:[self.gesturedTableView indexPathForCell:self]]) {
            if (i-1 < [indexPaths count]) {
                previousIndexPath = indexPaths[i-1];
                previousCell = (PDGesturedTableViewCell *)[self.gesturedTableView cellForRowAtIndexPath:previousIndexPath];
            }
            
            if (i+1 < [indexPaths count]) {
                nextIndexPath = indexPaths[i+1];
                nextCell = (PDGesturedTableViewCell *)[self.gesturedTableView cellForRowAtIndexPath:nextIndexPath];
            }
        }
    }
}

- (void)updateSideViews {
    [self.leftSideView setFrame:CGRectMake(0, self.frame.origin.y, self.frame.origin.x, self.frame.size.height)];
    [self.rightSideView setFrame:CGRectMake(self.frame.size.width, self.frame.origin.y, self.frame.origin.x, self.frame.size.height)];
    UIImageView * rightSideIconView = (UIImageView *)[self.rightSideView viewWithTag:1];
    [rightSideIconView setFrame:CGRectMake(0, 0, self.rightSideView.frame.size.width-20, self.rightSideView.frame.size.height)];
}

- (void)setCenter:(CGPoint)center {
    [super setCenter:CGPointMake(center.x, center.y)];
    [self updateSideViews];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:(self.gesturedTableView.updating ? CGRectMake(self.frame.origin.x, frame.origin.y, frame.size.width, frame.size.height) : frame)];
    [self updateSideViews];
}

@end

@implementation PDGesturedTableView

- (id)init {
    if (self = [super init]) {
        [self setAllowsSelection:NO];
        [self setBackgroundView:[UIView new]];
        [self setTableFooterView:[UIView new]];
        [self setSeparatorInset:UIEdgeInsetsZero];
        
        [self setEnabled:YES];
        [self setEdgeSlidingMargin:0];
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (self.superview != newSuperview) justMovedToNewSuperview = YES;
}

- (void)updateAnimatedly:(BOOL)animatedly {
    [UIView setAnimationsEnabled:animatedly];
    [self beginUpdates];
    [self endUpdates];
    [UIView setAnimationsEnabled:YES];
}

- (void)moveCell:(PDGesturedTableViewCell *)cell toHorizontalPosition:(CGFloat)horizontalPosition duration:(NSTimeInterval)duration completion:(void (^)(void))completion {
    [UIView animateWithDuration:duration animations:^{
        [cell setFrame:CGRectMake(horizontalPosition, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
    } completion:^(BOOL finished) {
        if (completion) completion();
    }];
}

- (void)removeCell:(PDGesturedTableViewCell *)cell completion:(void (^)(void))completion {
    [self moveCell:cell toHorizontalPosition:(cell.frame.origin.x > 0 ? cell.frame.size.width : -cell.frame.size.width) duration:0.35 completion:^{
        [UIView animateWithDuration:0.3 animations:^{
            [cell.leftSideView setAlpha:0];
            [cell.rightSideView setAlpha:0];
        } completion:^(BOOL finished) {
            NSIndexPath * indexPath = [self indexPathForCell:cell];
            if (completion) completion();
            [self setUpdating:YES];
            [self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self setUpdating:NO];
            [cell removeFromSuperview];
            [cell setFrame:CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
            [cell.leftSideView removeFromSuperview];
            [cell.rightSideView removeFromSuperview];
        }];
    }];
}

- (void)replaceCell:(PDGesturedTableViewCell *)cell completion:(void (^)(void))completion {
    [self moveCell:cell toHorizontalPosition:0 duration:0.25 completion:^{
        [cell.leftSideView removeFromSuperview];
        [cell.rightSideView removeFromSuperview];
        if (completion) completion();
    }];
}

#pragma mark Background View Methods

- (void)setWrapperViewAlpha:(CGFloat)alpha {
    for (UIView * subview in self.subviews) {
        if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewWrapperView"]) {
            [subview setAlpha:alpha];
        }
    }
}

- (void)showOrHideBackgroundViewAnimatedly:(BOOL)animatedly {
    if (justMovedToNewSuperview) justMovedToNewSuperview = NO;
    [self setWrapperViewAlpha:([self isEmpty] ? 0 : 1)];
    
    [UIView animateWithDuration:(animatedly ? 0.3 : 0) animations:^{
        [self.backgroundView setAlpha:([self isEmpty] ? 1 : 0)];
    }];
}

- (BOOL)isEmpty {
    BOOL isEmpty = YES;
    
    for (NSInteger i = 0; i < [self numberOfSections]; i++) {
        if ([self numberOfRowsInSection:i] > 0) {
            isEmpty = NO;
        }
    }
    
    return isEmpty;
}

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [super insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self showOrHideBackgroundViewAnimatedly:!justMovedToNewSuperview];
}

- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [super insertSections:sections withRowAnimation:animation];
    [self showOrHideBackgroundViewAnimatedly:!justMovedToNewSuperview];
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [super deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self showOrHideBackgroundViewAnimatedly:!justMovedToNewSuperview];
}

- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [super deleteSections:sections withRowAnimation:animation];
    [self showOrHideBackgroundViewAnimatedly:!justMovedToNewSuperview];
}

- (void)reloadData {
    [super reloadData];
    [self showOrHideBackgroundViewAnimatedly:!justMovedToNewSuperview];
}

@end