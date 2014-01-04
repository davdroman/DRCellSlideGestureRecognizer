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

@property (strong, nonatomic) UIImageView * iconImageView;

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
    PDGestureTableViewCellAction * currentAction;
    
    NSIndexPath * originIndexPath;
    CGFloat previousPoint;
    NSIndexPath * previousIndexPath;
    NSIndexPath * nextIndexPath;
    PDGestureTableViewCell * nextCell;
    PDGestureTableViewCell * previousCell;
    PDGestureTableViewCell * copiedCell;
}

@property (weak, nonatomic) PDGestureTableView * gesturedTableView;

@property (strong, nonatomic) PDGestureTableViewCellSideView * leftSideView;
@property (strong, nonatomic) PDGestureTableViewCellSideView * rightSideView;

@property (strong, nonatomic) UIPanGestureRecognizer * panGestureRecognizer;
@property (strong, nonatomic) UILongPressGestureRecognizer * longPressGestureRecognizer;

@end

@interface PDGestureTableView () {
    BOOL justMovedToNewSuperview;
}

@property (nonatomic, getter = isUpdating) BOOL updating;
@property (nonatomic, getter = isMoving) BOOL moving;

@end

#pragma mark - Implementations -

@implementation PDGestureTableViewCellAction

+ (id)actionWithIcon:(UIImage *)icon color:(UIColor *)color {
    PDGestureTableViewCellAction * action = [PDGestureTableViewCellAction new];
    
    [action setIcon:icon];
    [action setColor:color];
    
    return action;
}

+ (id)actionWithIcon:(UIImage *)icon color:(UIColor *)color fraction:(CGFloat)fraction {
    PDGestureTableViewCellAction * action = [PDGestureTableViewCellAction actionWithIcon:icon color:color];
    [action setFraction:fraction];
    
    return action;
}

+ (id)actionWithIcon:(UIImage *)icon color:(UIColor *)color fraction:(CGFloat)fraction didTriggerBlock:(void (^)(PDGestureTableView *, PDGestureTableViewCell *))didTriggerBlock {
    PDGestureTableViewCellAction * action = [PDGestureTableViewCellAction actionWithIcon:icon color:color fraction:fraction];
    [action setDidTriggerBlock:didTriggerBlock];
    
    return action;
}

+ (id)actionWithIcon:(UIImage *)icon color:(UIColor *)color fraction:(CGFloat)fraction didTriggerBlock:(void (^)(PDGestureTableView *, PDGestureTableViewCell *))didTriggerBlock didHighlightBlock:(void (^)(PDGestureTableView *, PDGestureTableViewCell *))didHighlightBlock didUnhighlightBlock:(void (^)(PDGestureTableView *, PDGestureTableViewCell *))didUnhighlightBlock {
    PDGestureTableViewCellAction * action = [PDGestureTableViewCellAction actionWithIcon:icon color:color fraction:fraction didTriggerBlock:didTriggerBlock];
    [action setDidHighlightBlock:didHighlightBlock];
    [action setDidUnhighlightBlock:didUnhighlightBlock];
    
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
    [self setIconsFollowSliding:YES];
    [self setIconsMargin:20];
    [self setReplacementDuration:0.25];
    
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
    [self setGesturedTableView:(PDGestureTableView *)self.superview.superview];
}

#pragma mark -

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer class] == [UIPanGestureRecognizer class]) {
        CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:self];
        CGFloat horizontalLocation = [(UIPanGestureRecognizer *)gestureRecognizer locationInView:self].x;
        
        if (fabsf(velocity.x) > fabsf(velocity.y) && horizontalLocation > self.gesturedTableView.edgeSlidingMargin && horizontalLocation < self.frame.size.width - self.gesturedTableView.edgeSlidingMargin && self.gesturedTableView.isEnabled) {
            return YES;
        }
    } else if ([gestureRecognizer class] == [UILongPressGestureRecognizer class]) {
        if (!self.gesturedTableView.moving && self.gesturedTableView.didMoveCellFromIndexPathToIndexPathBlock) {
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
        /* if (self.frame.origin.x + horizontalTranslation > margin) {
            coeficient = (elastic-((self.frame.origin.x+horizontalTranslation/(-(1/6)*margin+elastic/1.45))-margin))/elastic;
        } */
        
        if ((![self hasAnyLeftAction] && self.frame.size.width/2+horizontalTranslation > self.frame.size.width/2) || (![self hasAnyRightAction] && self.frame.size.width/2+horizontalTranslation < self.frame.size.width/2)) {
            horizontalTranslation = 0;
        }
        
        [self performChanges];
        [self setCenter:CGPointMake(self.frame.size.width/2+horizontalTranslation, self.center.y)];
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (!currentAction && self.frame.origin.x != 0) {
            [self.gesturedTableView replaceCell:self bounce:8 completion:^{
                [self.leftSideView removeFromSuperview];
                [self.rightSideView removeFromSuperview];
            }];
        } else if (currentAction.didTriggerBlock) currentAction.didTriggerBlock(self.gesturedTableView, self);
        
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
    UIViewContentMode leftSideViewContentMode = self.iconsFollowSliding ? UIViewContentModeRight : UIViewContentModeLeft;
    
    [self.leftSideView.iconImageView setContentMode:leftSideViewContentMode];
    [self.superview insertSubview:self.leftSideView atIndex:0];
    
    UIViewContentMode rightSideViewContentMode = self.iconsFollowSliding ? UIViewContentModeLeft : UIViewContentModeRight;
    
    [self.rightSideView.iconImageView setContentMode:rightSideViewContentMode];
    [self.superview insertSubview:self.rightSideView atIndex:0];
}

- (void)performChanges {
    PDGestureTableViewCellAction * actionForCurrentPosition = [self actionForCurrentPosition];
    
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
            [self.leftSideView setBackgroundColor:self.normalColor];
            [self.leftSideView.iconImageView setImage:self.firstLeftAction.icon];
        } else if (self.frame.origin.x < 0) {
            [self.rightSideView setBackgroundColor:self.normalColor];
            [self.rightSideView.iconImageView setImage:self.firstRightAction.icon];
        }
    }
    
    [self.leftSideView.iconImageView setAlpha:self.frame.origin.x/(self.iconsMargin*2+self.leftSideView.iconImageView.image.size.width)];
    [self.rightSideView.iconImageView setAlpha:-(self.frame.origin.x/(self.iconsMargin*2+self.rightSideView.iconImageView.image.size.width))];
    
    if (currentAction != actionForCurrentPosition) {
        if (actionForCurrentPosition.didHighlightBlock) actionForCurrentPosition.didHighlightBlock(self.gesturedTableView, self);
        if (currentAction.didUnhighlightBlock) currentAction.didUnhighlightBlock(self.gesturedTableView, self);
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
        
        copiedCell = [[PDGestureTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.reuseIdentifier];
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
        
        // autoscrollTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(autoscrollIfNeeded:)];
        // [autoscrollTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
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
                previousCell = (PDGestureTableViewCell *)[self.gesturedTableView cellForRowAtIndexPath:previousIndexPath];
            }
            
            if (i+1 < [indexPaths count]) {
                nextIndexPath = indexPaths[i+1];
                nextCell = (PDGestureTableViewCell *)[self.gesturedTableView cellForRowAtIndexPath:nextIndexPath];
            }
        }
    }
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
    
    [self.leftSideView.iconImageView setFrame:CGRectMake(self.iconsMargin, 0, MAX(self.leftSideView.iconImageView.image.size.width, self.leftSideView.frame.size.width-self.iconsMargin*2), self.leftSideView.frame.size.height)];
    [self.rightSideView.iconImageView setFrame:CGRectMake(self.rightSideView.frame.size.width-self.iconsMargin, 0, MIN(-self.rightSideView.iconImageView.image.size.width, self.iconsMargin*2-self.rightSideView.frame.size.width), self.rightSideView.frame.size.height)];
}

- (void)setCenter:(CGPoint)center {
    [super setCenter:center];
    [self updateSideViews];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:(self.gesturedTableView.isUpdating ? CGRectMake(frame.origin.x, self.frame.origin.y, frame.size.width, frame.size.height) : frame)];
    [self updateSideViews];
}

- (void)setAlpha:(CGFloat)alpha {
    [super setAlpha:1];
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
    [self setAllowsSelection:NO];
    [self setBackgroundView:[UIView new]];
    [self setTableFooterView:[UIView new]];
    [self setSeparatorInset:UIEdgeInsetsZero];
    
    [self setEnabled:YES];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (self.superview != newSuperview) justMovedToNewSuperview = YES;
}

#pragma mark -

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

#pragma mark -

- (void)removeCell:(PDGestureTableViewCell *)cell completion:(void (^)(void))completion {
    [self setEnabled:NO];
    [self setUpdating:YES];
    
    UITableViewRowAnimation animation = cell.frame.origin.x > 0 ? UITableViewRowAnimationRight : UITableViewRowAnimationLeft;
    
    [self deleteRowsAtIndexPaths:@[[self indexPathForCell:cell]] withRowAnimation:animation duration:0.3 completion:^{
        [self setUpdating:NO];
        [UIView animateWithDuration:0.25 animations:^{
            [self beginUpdates];
            [self endUpdates];
            [cell.leftSideView setAlpha:0];
            [cell.rightSideView setAlpha:0];
        } completion:^(BOOL finished) {
            [cell.leftSideView setAlpha:1];
            [cell.rightSideView setAlpha:1];
            [cell.leftSideView removeFromSuperview];
            [cell.rightSideView removeFromSuperview];
            [self setEnabled:YES];
            if (completion) completion();
        }];
    }];
}

- (void)replaceCell:(PDGestureTableViewCell *)cell bounce:(CGFloat)bounce completion:(void (^)(void))completion {
    bounce = fabsf(bounce);
    
    [UIView animateWithDuration:cell.replacementDuration animations:^{
        [cell setCenter:CGPointMake(cell.frame.size.width/2 + (cell.frame.origin.x > 0 ? -bounce : bounce), cell.center.y)];
        [cell.leftSideView.iconImageView setAlpha:0];
        [cell.rightSideView.iconImageView setAlpha:0];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:cell.replacementDuration/2 animations:^{
            [cell setCenter:CGPointMake(cell.frame.size.width/2, cell.center.y)];
        } completion:^(BOOL finished) {
            [cell.leftSideView removeFromSuperview];
            [cell.rightSideView removeFromSuperview];
            if (completion) completion();
        }];
    }];
}

#pragma mark -

- (void)performDataSourceAction:(void (^)(void))action duration:(NSTimeInterval)duration completion:(void (^)(void))completion {
    [CATransaction begin];
    
    [CATransaction setCompletionBlock:completion];
    [UIView animateWithDuration:duration animations:action];
    
    [CATransaction commit];
}

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation duration:(NSTimeInterval)duration completion:(void (^)(void))completion {
    [self performDataSourceAction:^{
        [self insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    } duration:duration completion:completion];
}

- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation duration:(NSTimeInterval)duration completion:(void (^)(void))completion {
    [self performDataSourceAction:^{
        [self insertSections:sections withRowAnimation:animation];
    } duration:duration completion:completion];
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation duration:(NSTimeInterval)duration completion:(void (^)(void))completion {
    [self performDataSourceAction:^{
        [self deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    } duration:duration completion:completion];
}

- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation duration:(NSTimeInterval)duration completion:(void (^)(void))completion {
    [self performDataSourceAction:^{
        [self deleteSections:sections withRowAnimation:animation];
    } duration:duration completion:completion];
}

- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation duration:(NSTimeInterval)duration completion:(void (^)(void))completion {
    [self performDataSourceAction:^{
        [self reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    } duration:duration completion:completion];
}

- (void)reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation duration:(NSTimeInterval)duration completion:(void (^)(void))completion {
    [self performDataSourceAction:^{
        [self reloadSections:sections withRowAnimation:animation];
    } duration:duration completion:completion];
}

- (void)moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath duration:(NSTimeInterval)duration completion:(void (^)(void))completion {
    [self performDataSourceAction:^{
        [self moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
    } duration:duration completion:completion];
}

- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection duration:(NSTimeInterval)duration completion:(void (^)(void))completion {
    [self performDataSourceAction:^{
        [self moveSection:section toSection:newSection];
    } duration:duration completion:completion];
}

@end