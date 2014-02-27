//
//  PDGestureTableView.m
//  Proday
//
//  Created by David Román Aguirre on 24/08/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import "PDGestureTableView.h"

#pragma mark Private Classes -

@interface PDGestureTableViewCellSideView : UIView

@property (strong, nonatomic) UIImageView *iconImageView;

@end

@implementation PDGestureTableViewCellSideView

- (id)init {
    if (self = [super init]) {
        self.iconImageView = [UIImageView new];
        
        [self addSubview:self.iconImageView];
    }
    
    return self;
}

@end

#pragma mark - Interface Extensions -

@interface PDGestureTableViewCell () {
    PDGestureTableViewCellAction *currentAction;
    
    NSIndexPath *originIndexPath;
    CGFloat previousPoint;
    NSIndexPath *previousIndexPath;
    NSIndexPath *nextIndexPath;
    PDGestureTableViewCell *nextCell;
    PDGestureTableViewCell *previousCell;
    PDGestureTableViewCell *copiedCell;
    CADisplayLink *autoscrollTimer;
}

@property (weak, nonatomic) PDGestureTableView *gestureTableView;

@property (strong, nonatomic) PDGestureTableViewCellSideView *leftSideView;
@property (strong, nonatomic) PDGestureTableViewCellSideView *rightSideView;

@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;

@end

@interface PDGestureTableView ()

@property (nonatomic, getter = isUpdating) BOOL updating;

@end

#pragma mark - Implementations -

@implementation PDGestureTableViewCellAction

+ (id)actionWithIcon:(UIImage *)icon color:(UIColor *)color fraction:(CGFloat)fraction didTriggerBlock:(void (^)(PDGestureTableView *, NSIndexPath *))didTriggerBlock {
    PDGestureTableViewCellAction *action = [PDGestureTableViewCellAction new];
    
    [action setIcon:icon];
    [action setColor:color];
    [action setFraction:fraction];
    [action setDidTriggerBlock:didTriggerBlock];
    
    return action;
}

@end

@implementation PDGestureTableViewCell

- (id)init {
    if (self = [super init]) {
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    
    return self;
}

- (void)setup {
    [self setActionIconsFollowSliding:YES];
    [self setActionIconsMargin:20];
    
    self.leftSideView = [PDGestureTableViewCellSideView new];
    self.rightSideView = [PDGestureTableViewCellSideView new];
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(slideCell:)];
    [self.panGestureRecognizer setDelegate:self];
    [self addGestureRecognizer:self.panGestureRecognizer];
    
    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(moveCell:)];
    [self.longPressGestureRecognizer setDelegate:self];
    [self.longPressGestureRecognizer setMinimumPressDuration:0.175];
    [self addGestureRecognizer:self.longPressGestureRecognizer];
}

- (void)didMoveToSuperview {
    [self setGestureTableView:(PDGestureTableView *)self.superview.superview];
}

#pragma mark -

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer class] == [UIPanGestureRecognizer class]) {
        CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:self];
        
        if (fabsf(velocity.x) > fabsf(velocity.y) && self.gestureTableView.isEnabled) {
            return YES;
        }
    } else if ([gestureRecognizer class] == [UILongPressGestureRecognizer class]) {
        if (self.gestureTableView.isEnabled && self.gestureTableView.didMoveCellFromIndexPathToIndexPathBlock) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark -

- (void)slideCell:(UIPanGestureRecognizer *)panGestureRecognizer {
    if (![self hasAnyLeftAction] && ![self hasAnyRightAction]) return;
    
    CGFloat horizontalTranslation = [panGestureRecognizer translationInView:self].x;
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self setupSideViews];
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        /*if (self.frame.origin.x + horizontalTranslation > margin) {
         coeficient = (elastic-((self.frame.origin.x+horizontalTranslation/(-(1/6)*margin+elastic/1.45))-margin))/elastic;
         } */
        
        if ((![self hasAnyLeftAction] && self.frame.size.width/2+horizontalTranslation > self.frame.size.width/2) || (![self hasAnyRightAction] && self.frame.size.width/2+horizontalTranslation < self.frame.size.width/2)) {
            horizontalTranslation = 0;
        }
        
        [self performChanges];
        [self setCenter:CGPointMake(self.frame.size.width/2+horizontalTranslation, self.center.y)];
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if ((!currentAction && self.frame.origin.x != 0) || !self.gestureTableView.isEnabled) {
            [self.gestureTableView replaceCellForIndexPath:[self.gestureTableView indexPathForCell:self] completion:nil];
        } else if (currentAction.didTriggerBlock) currentAction.didTriggerBlock(self.gestureTableView, [self.gestureTableView indexPathForCell:self]);
        
        currentAction = nil;
    }
}

- (BOOL)hasAnyLeftAction {
    return self.firstLeftAction || self.secondLeftAction;
}

- (BOOL)hasAnyRightAction {
    return self.firstRightAction || self.secondRightAction;
}

- (void)setupSideViews {
    UIViewContentMode leftSideViewContentMode = self.actionIconsFollowSliding ? UIViewContentModeRight : UIViewContentModeLeft;
    
    [self.leftSideView.iconImageView setContentMode:leftSideViewContentMode];
    [self.superview insertSubview:self.leftSideView atIndex:0];
    
    UIViewContentMode rightSideViewContentMode = self.actionIconsFollowSliding ? UIViewContentModeLeft : UIViewContentModeRight;
    
    [self.rightSideView.iconImageView setContentMode:rightSideViewContentMode];
    [self.superview insertSubview:self.rightSideView atIndex:0];
}

- (void)performChanges {
    PDGestureTableViewCellAction *actionForCurrentPosition = [self actionForCurrentPosition];
    
    if (actionForCurrentPosition) {
        if (self.frame.origin.x > 0) {
            [self.leftSideView setBackgroundColor:actionForCurrentPosition.color];
            [self.leftSideView.iconImageView setImage:actionForCurrentPosition.icon];
        } else if (self.frame.origin.x < 0) {
            [self.rightSideView setBackgroundColor:actionForCurrentPosition.color];
            [self.rightSideView.iconImageView setImage:actionForCurrentPosition.icon];
        }
    } else {
        if (self.frame.origin.x > 0) {
            [self.leftSideView setBackgroundColor:[UIColor clearColor]];
            [self.leftSideView.iconImageView setImage:self.firstLeftAction.icon];
        } else if (self.frame.origin.x < 0) {
            [self.rightSideView setBackgroundColor:[UIColor clearColor]];
            [self.rightSideView.iconImageView setImage:self.firstRightAction.icon];
        }
    }
    
    [self.leftSideView.iconImageView setAlpha:self.frame.origin.x/(self.actionIconsMargin*2+self.leftSideView.iconImageView.image.size.width)];
    [self.rightSideView.iconImageView setAlpha:-(self.frame.origin.x/(self.actionIconsMargin*2+self.rightSideView.iconImageView.image.size.width))];
    
    if (currentAction != actionForCurrentPosition) {
        if (actionForCurrentPosition.didHighlightBlock) actionForCurrentPosition.didHighlightBlock(self.gestureTableView, self);
        if (currentAction.didUnhighlightBlock) currentAction.didUnhighlightBlock(self.gestureTableView, self);
        currentAction = actionForCurrentPosition;
    }
}

- (PDGestureTableViewCellAction *)actionForCurrentPosition {
    CGFloat fraction = fabsf(self.frame.origin.x/self.frame.size.width);
    
    if (self.frame.origin.x > 0) {
        if (self.secondLeftAction && fraction > self.secondLeftAction.fraction) {
            return self.secondLeftAction;
        } else if (self.firstLeftAction && fraction > self.firstLeftAction.fraction) {
            return self.firstLeftAction;
        }
    } else if (self.frame.origin.x < 0) {
        if (self.secondRightAction && fraction > self.secondRightAction.fraction) {
            return self.secondRightAction;
        } else if (self.firstRightAction && fraction > self.firstRightAction.fraction) {
            return self.firstRightAction;
        }
    }
    
    return nil;
}

#pragma mark -

- (void)animateShadowWithRadius:(CGFloat)radius opacity:(CGFloat)opacity duration:(CFTimeInterval)duration {
    CABasicAnimation *shadowRadiusAnimation = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
    [shadowRadiusAnimation setFromValue:[NSNumber numberWithFloat:self.layer.shadowRadius]];
    [shadowRadiusAnimation setToValue:[NSNumber numberWithFloat:radius]];
    
    CABasicAnimation *shadowOpacityAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    [shadowOpacityAnimation setFromValue:[NSNumber numberWithFloat:self.layer.shadowOpacity]];
    [shadowOpacityAnimation setToValue:[NSNumber numberWithFloat:opacity]];
    
    CAAnimationGroup *shadowAnimations = [CAAnimationGroup new];
    [shadowAnimations setAnimations:@[shadowRadiusAnimation, shadowOpacityAnimation]];
    [shadowAnimations setRemovedOnCompletion:YES];
    [shadowAnimations setDuration:duration];
    
    [self.layer addAnimation:shadowAnimations forKey:@"shadowAnimations"];
    
    [self.layer setShadowRadius:radius];
    [self.layer setShadowOpacity:opacity];
}

// Sorry, this part is so messy as cell movement with autoscroll is in the works.

- (CGFloat)copiedCellY {
    return copiedCell.frame.origin.y-self.gestureTableView.frame.origin.y-self.gestureTableView.contentInset.top;
}

- (CGFloat)copiedCellCenterY {
    return copiedCell.center.y-self.gestureTableView.frame.origin.y-self.gestureTableView.contentInset.top;
}

- (void)moveCell:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self.gestureTableView setEnabled:NO];
        
        copiedCell = [[PDGestureTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.reuseIdentifier];
        [copiedCell setFrame:self.frame];
        [copiedCell setBackgroundColor:self.backgroundColor];
        
        for (UIView *view in self.contentView.subviews) {
            [copiedCell.contentView addSubview:view];
        }
        
        originIndexPath = [self.gestureTableView indexPathForCell:self];
        [self setHidden:YES];
        [copiedCell setCenter:CGPointMake(copiedCell.center.x, copiedCell.center.y+self.gestureTableView.frame.origin.y+self.gestureTableView.contentInset.top)];
        [self.gestureTableView.superview addSubview:copiedCell];
        
        [copiedCell.layer setShadowOffset:CGSizeZero];
        [copiedCell animateShadowWithRadius:2 opacity:0.6 duration:0.2];
        
        [UIView animateWithDuration:0.2 animations:^{
            [copiedCell setTransform:CGAffineTransformMakeScale(1.1, 1.1)];
        }];
        
        previousPoint = [longPressGestureRecognizer locationInView:self.gestureTableView].y;
        
        [self resetPreviousAndNextCellAndIndexPath];
        
        autoscrollTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(autoscrollIfNeeded:)];
        [autoscrollTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    } else if (longPressGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat currentPoint = [longPressGestureRecognizer locationInView:self.gestureTableView].y;
        CGFloat verticalTranslation = currentPoint-previousPoint;
        previousPoint = currentPoint;
        
        [copiedCell setCenter:CGPointMake(copiedCell.center.x, copiedCell.center.y+verticalTranslation)];
        
        if (nextCell && verticalTranslation > 0 && [self copiedCellCenterY] > nextCell.frame.origin.y) {
            self.gestureTableView.didMoveCellFromIndexPathToIndexPathBlock([self.gestureTableView indexPathForCell:self], nextIndexPath);
            
            [UIView animateWithDuration:0.2 animations:^{
                [self.gestureTableView moveRowAtIndexPath:[self.gestureTableView indexPathForCell:self] toIndexPath:nextIndexPath];
            } completion:^(BOOL finished) {
                if (finished) [self resetPreviousAndNextCellAndIndexPath];
            }];
        } else if (previousCell && verticalTranslation < 0 && [self copiedCellY] < previousCell.center.y) {
            self.gestureTableView.didMoveCellFromIndexPathToIndexPathBlock([self.gestureTableView indexPathForCell:self], previousIndexPath);
            
            [UIView animateWithDuration:0.2 animations:^{
                [self.gestureTableView moveRowAtIndexPath:[self.gestureTableView indexPathForCell:self] toIndexPath:previousIndexPath];
            } completion:^(BOOL finished) {
                if (finished) [self resetPreviousAndNextCellAndIndexPath];
            }];
        }
    } else if (longPressGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [autoscrollTimer invalidate];
        [self.gestureTableView setEnabled:YES];
        
        [copiedCell animateShadowWithRadius:0.5 opacity:0.4 duration:0.3];
        
        [UIView animateWithDuration:0.3 animations:^{
            [copiedCell setCenter:CGPointMake(self.center.x, self.center.y+self.gestureTableView.frame.origin.y+self.gestureTableView.contentInset.top)];
            [copiedCell setTransform:CGAffineTransformMakeScale(1, 1)];
        } completion:^(BOOL finished) {
            for (UIView *view in copiedCell.contentView.subviews) {
                [self.contentView addSubview:view];
            }
            
            [copiedCell removeFromSuperview];
            [self setHidden:NO];
        }];
    }
}

- (void)resetPreviousAndNextCellAndIndexPath {
    NSArray *indexPaths = [self.gestureTableView indexPathsForVisibleRows];
    
    for (NSInteger i = 0; i < [indexPaths count]; i++) {
        NSIndexPath *indexPath = indexPaths[i];
        
        if ([indexPath isEqual:[self.gestureTableView indexPathForCell:self]]) {
            if (i-1 < [indexPaths count]) {
                previousIndexPath = indexPaths[i-1];
                previousCell = (PDGestureTableViewCell *)[self.gestureTableView cellForRowAtIndexPath:previousIndexPath];
            }
            
            if (i+1 < [indexPaths count]) {
                nextIndexPath = indexPaths[i+1];
                nextCell = (PDGestureTableViewCell *)[self.gestureTableView cellForRowAtIndexPath:nextIndexPath];
            }
        }
    }
}

- (void)autoscrollIfNeeded:(CADisplayLink *)autoscrollTimer {
    
}

#pragma mark -

- (void)setFirstLeftAction:(PDGestureTableViewCellAction *)firstLeftAction {
    if (firstLeftAction.fraction == 0) [firstLeftAction setFraction:0.3];
    _firstLeftAction = firstLeftAction;
}

- (void)setSecondLeftAction:(PDGestureTableViewCellAction *)secondLeftAction {
    if (secondLeftAction.fraction == 0) [secondLeftAction setFraction:0.7];
    _secondLeftAction = secondLeftAction;
}

- (void)setFirstRightAction:(PDGestureTableViewCellAction *)firstRightAction {
    if (firstRightAction.fraction == 0) [firstRightAction setFraction:0.3];
    _firstRightAction = firstRightAction;
}

- (void)setSecondRightAction:(PDGestureTableViewCellAction *)secondRightAction {
    if (secondRightAction.fraction == 0) [secondRightAction setFraction:0.7];
    _secondRightAction = secondRightAction;
}

- (void)updateSideViews {
    [self.leftSideView setFrame:CGRectMake(0, self.frame.origin.y, self.frame.origin.x, self.frame.size.height)];
    [self.rightSideView setFrame:CGRectMake(self.frame.origin.x+self.frame.size.width, self.frame.origin.y, self.frame.size.width-(self.frame.origin.x+self.frame.size.width), self.frame.size.height)];
    
    [self.leftSideView.iconImageView setFrame:CGRectMake(self.actionIconsMargin, 0, MAX(self.leftSideView.iconImageView.image.size.width, self.leftSideView.frame.size.width-self.actionIconsMargin*2), self.leftSideView.frame.size.height)];
    [self.rightSideView.iconImageView setFrame:CGRectMake(self.rightSideView.frame.size.width-self.actionIconsMargin, 0, MIN(-self.rightSideView.iconImageView.image.size.width, self.actionIconsMargin*2-self.rightSideView.frame.size.width), self.rightSideView.frame.size.height)];
}

- (void)setCenter:(CGPoint)center {
    [super setCenter:center];
    [self updateSideViews];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:(self.gestureTableView.isUpdating ? CGRectMake(self.frame.origin.x, frame.origin.y, frame.size.width, frame.size.height) : frame)];
    [self updateSideViews];
}

@end

@implementation PDGestureTableView

- (id)init {
    if (self = [super init]) {
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        [self setup];
    }
    
    return self;
}

- (void)setup {
    [self setBackgroundView:[UIView new]];
    [self setTableFooterView:[UIView new]];
    [self setSeparatorInset:UIEdgeInsetsZero];
    
    [self setEnabled:YES];
    [self setAnimationsDuration:0.25];
    [self setCellBounceWhenReplaced:YES];
    // [self setEdgeAutoscrollMargin:40];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [self showOrHideBackgroundViewAnimatedly:NO];
}

#pragma mark -

- (void)setDataSource:(id<UITableViewDataSource>)dataSource {
    [super setDataSource:dataSource];
    [self showOrHideBackgroundViewAnimatedly:NO];
}

- (void)setBackgroundView:(UIView *)backgroundView {
    [backgroundView setAlpha:self.backgroundView.alpha];
    [super setBackgroundView:backgroundView];
}

- (void)setWrapperViewAlpha:(CGFloat)alpha {
    for (UIView *subview in self.subviews) {
        if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewWrapperView"]) {
            [subview setAlpha:alpha];
        }
    }
}

- (void)showOrHideBackgroundViewAnimatedly:(BOOL)animatedly {
    [self setWrapperViewAlpha:([self isEmpty] ? 0 : 1)];
    
    [UIView animateWithDuration:(animatedly ? 0.3 : 0) animations:^{
        [self.backgroundView setAlpha:([self isEmpty] ? 1 : 0)];
    }];
}

- (BOOL)isEmpty {
    if (self.dataSource) {
        NSInteger numberOfSections = [self.dataSource numberOfSectionsInTableView:self];
        
        for (int i = 0; i < numberOfSections; i++) {
            NSInteger numberOfRowsAtSection = [self.dataSource tableView:self numberOfRowsInSection:i];
            
            if (numberOfRowsAtSection > 0) return NO;
        }
    }
    
    return YES;
}

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [super insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self showOrHideBackgroundViewAnimatedly:YES];
}

- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [super insertSections:sections withRowAnimation:animation];
    [self showOrHideBackgroundViewAnimatedly:YES];
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [super deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self showOrHideBackgroundViewAnimatedly:YES];
}

- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [super deleteSections:sections withRowAnimation:animation];
    [self showOrHideBackgroundViewAnimatedly:YES];
}

- (void)reloadData {
    [super reloadData];
    [self showOrHideBackgroundViewAnimatedly:YES];
}

#pragma mark -

- (void)pushCellForIndexPath:(NSIndexPath *)indexPath completion:(void (^)(void))completion {
    PDGestureTableViewCell *cell = (PDGestureTableViewCell *)[self cellForRowAtIndexPath:indexPath];
    
    [self setEnabled:NO];
    
    CGFloat newHorizontalPosition = cell.frame.size.width/2+cell.frame.size.width*(cell.frame.origin.x >= 0 ? 1 : -1);
    
    [UIView animateWithDuration:self.animationsDuration animations:^{
        [cell setCenter:CGPointMake(newHorizontalPosition, cell.center.y)];
    } completion:^(BOOL finished) {
        [self setEnabled:YES];
        if (completion) completion();
    }];
}

- (void)deleteCellForIndexPath:(NSIndexPath *)indexPath animation:(UITableViewRowAnimation)animation completion:(void (^)(void))completion {
    PDGestureTableViewCell *cell = (PDGestureTableViewCell *)[self cellForRowAtIndexPath:indexPath];
    
    [self setEnabled:NO];
    
    if (cell.frame.origin.x != 0) {
        [self setUpdating:YES];
        animation = cell.frame.origin.x > 0 ? UITableViewRowAnimationRight : UITableViewRowAnimationLeft;
    }
    
    [CATransaction setCompletionBlock:^{
        [cell.leftSideView setAlpha:1];
        [cell.rightSideView setAlpha:1];
        [cell.leftSideView removeFromSuperview];
        [cell.rightSideView removeFromSuperview];
        [self setEnabled:YES];
        [self setUpdating:NO];
        if (completion) completion();
    }];
    
    [cell.leftSideView setAlpha:0];
    [cell.rightSideView setAlpha:0];
    [self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
}

- (void)beginUpdates {
    [super beginUpdates];
    
    [UIView beginAnimations:@"UITableView+AnimationControl Animations ID" context:nil];
    [UIView setAnimationDuration:self.animationsDuration];
    [CATransaction begin];
}

- (void)endUpdates {
    [super endUpdates];
    [CATransaction commit];
    [UIView commitAnimations];
}

- (void)pushAndDeleteCellForIndexPath:(NSIndexPath *)indexPath completion:(void (^)(void))completion {
    [self pushCellForIndexPath:indexPath completion:^{
        [self beginUpdates];
        
        [self deleteCellForIndexPath:indexPath animation:UITableViewRowAnimationNone completion:^{
            if (completion) completion();
        }];
        
        [self endUpdates];
    }];
}

- (void)replaceCellForIndexPath:(NSIndexPath *)indexPath completion:(void (^)(void))completion {
    PDGestureTableViewCell *cell = (PDGestureTableViewCell *)[self cellForRowAtIndexPath:indexPath];
    
    CGFloat bounce = self.cellBounceWhenReplaced ? MIN(7, fabsf(cell.frame.origin.x)/30) : 0;
    
    [UIView animateWithDuration:self.animationsDuration animations:^{
        [cell setCenter:CGPointMake(cell.frame.size.width/2 + (cell.frame.origin.x > 0 ? -bounce : bounce), cell.center.y)];
        [cell.leftSideView.iconImageView setAlpha:0];
        [cell.rightSideView.iconImageView setAlpha:0];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:self.animationsDuration/2 animations:^{
            [cell setCenter:CGPointMake(cell.frame.size.width/2, cell.center.y)];
        } completion:^(BOOL finished) {
            [cell.leftSideView removeFromSuperview];
            [cell.rightSideView removeFromSuperview];
            if (completion) completion();
        }];
    }];
}

@end