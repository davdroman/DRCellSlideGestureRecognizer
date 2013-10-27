//
//  PDGesturedTableView.m
//  Proday
//
//  Created by David Román Aguirre on 24/08/13.
//  Copyright (c) 2013 David Román Aguirre. All rights reserved.
//

#import "PDGesturedTableView.h"

#import <QuartzCore/QuartzCore.h>

#pragma mark Categories

@interface NSArray (ObjectExistance)

- (BOOL)objectExistsAtIndex:(NSInteger)index;

@end

@implementation NSArray (ObjectExistance)

- (BOOL)objectExistsAtIndex:(NSInteger)index {
    if (index < [self count]) {
        return YES;
    }
    
    return NO;
}

@end

#pragma mark Interface Extensions & Private Interfaces

@interface PDGesturedTableViewCellSlidingFraction ()

@property (strong, nonatomic) UIImage * icon;
@property (strong, nonatomic) UIColor * color;
@property (nonatomic) CGFloat activationFraction;

@end

@interface PDGesturedTableViewCellSlidingView : UIView

@property (strong, nonatomic) UIImageView * leftIconImageView;
@property (strong, nonatomic) UIImageView * rightIconImageView;

@end

@interface PDGesturedTableViewCell () {
    NSArray * currentSlidingFractions;
    PDGesturedTableViewCellSlidingFraction * currentSlidingFraction;
    CGFloat originalHorizontalCenter;
    
    NSIndexPath * originIndexPath;
    CGFloat previousPoint;
    NSIndexPath * previousIndexPath;
    NSIndexPath * nextIndexPath;
    PDGesturedTableViewCell * nextCell;
    PDGesturedTableViewCell * previousCell;
    PDGesturedTableViewCell * copiedCell;
}

@property (weak, nonatomic) PDGesturedTableView * gesturedTableView;
@property (strong, nonatomic) PDGesturedTableViewCellSlidingView * slidingView;

@property (strong, nonatomic) NSMutableArray * leftSlidingFractions;
@property (strong, nonatomic) NSMutableArray * rightSlidingFractions;

@end

@interface PDGesturedTableView ()

@property (nonatomic) BOOL updating;
@property (nonatomic) BOOL moving;
@property (nonatomic) BOOL scrolling;

@end

#pragma mark Implementations

@implementation PDGesturedTableViewCellSlidingFraction

+ (id)slidingFractionWithIcon:(UIImage *)icon color:(UIColor *)color activationFraction:(CGFloat)activationFraction {
    PDGesturedTableViewCellSlidingFraction * slidingFraction = [PDGesturedTableViewCellSlidingFraction new];
    
    [slidingFraction setIcon:icon];
    [slidingFraction setColor:color];
    [slidingFraction setActivationFraction:activationFraction];
    
    return slidingFraction;
}

@end

@implementation PDGesturedTableViewCellSlidingView

- (id)init {
    if (self = [super init]) {
        self.leftIconImageView = [UIImageView new];
        self.rightIconImageView = [UIImageView new];
        
        [self.leftIconImageView setContentMode:UIViewContentModeLeft];
        [self.rightIconImageView setContentMode:UIViewContentModeRight];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    CGFloat iconImageViewsMargin = 17;
    CGRect iconImageViewsFrame = CGRectMake(iconImageViewsMargin, 0, self.frame.size.width-iconImageViewsMargin*2, self.frame.size.height);
    
    [self.leftIconImageView setFrame:iconImageViewsFrame];
    [self.rightIconImageView setFrame:iconImageViewsFrame];
    
    [self addSubview:self.leftIconImageView];
    [self addSubview:self.rightIconImageView];
}

- (void)setIcon:(UIImage *)icon {
    [self.leftIconImageView setImage:icon];
    [self.rightIconImageView setImage:icon];
}

- (void)setIconsAlpha:(CGFloat)alpha {
    [self.leftIconImageView setAlpha:alpha];
    [self.rightIconImageView setAlpha:-alpha];
}

@end

@implementation PDGesturedTableViewCell

- (id)initForGesturedTableView:(PDGesturedTableView *)gesturedTableView style:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.gesturedTableView = gesturedTableView;
        self.slidingView = [PDGesturedTableViewCellSlidingView new];
        
        self.leftSlidingFractions = [NSMutableArray new];
        self.rightSlidingFractions = [NSMutableArray new];
        
        UIPanGestureRecognizer * panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(slideCell:)];
        [panGestureRecognizer setDelegate:self];
        [self addGestureRecognizer:panGestureRecognizer];
        
        UILongPressGestureRecognizer * longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(moveCell:)];
        [longPressGestureRecognizer setDelegate:self];
        [self addGestureRecognizer:longPressGestureRecognizer];
    }
    
    return self;
}

- (void)addSlidingFraction:(PDGesturedTableViewCellSlidingFraction *)slidingFraction {
    if (slidingFraction) [(slidingFraction.activationFraction > 0 ? self.leftSlidingFractions : self.rightSlidingFractions) addObject:slidingFraction];
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
        return !self.gesturedTableView.moving;
    }
    
    return YES;
}

- (PDGesturedTableViewCellSlidingFraction *)currentSlidingFractionForArray:(NSArray *)fractionsArray {
    for (NSInteger i = [fractionsArray count]-1; i >= 0; i--) {
        PDGesturedTableViewCellSlidingFraction * fraction = fractionsArray[i];
        
        if (fabsf(self.frame.origin.x/self.frame.size.width) >= fabsf(fraction.activationFraction)) {
            return fraction;
        }
    }
    
    return nil;
}

- (void)sortSlidingFractions {
    NSSortDescriptor * leftFractionsSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"activationFraction" ascending:YES];
    [self.leftSlidingFractions sortUsingDescriptors:@[leftFractionsSortDescriptor]];
    
    NSSortDescriptor * rightFractionsSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"activationFraction" ascending:NO];
    [self.rightSlidingFractions sortUsingDescriptors:@[rightFractionsSortDescriptor]];
}

- (void)slideCell:(UIPanGestureRecognizer *)panGestureRecognizer {
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        originalHorizontalCenter = self.center.x;
        
        [self sortSlidingFractions];
        
        [self.slidingView setFrame:CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
        [self.gesturedTableView insertSubview:self.slidingView atIndex:0];
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat horizontalTranslation = [panGestureRecognizer translationInView:self].x;
        
        if ([self.leftSlidingFractions count] == 0 && self.frame.origin.x+horizontalTranslation > 0) horizontalTranslation = 0;
        else if ([self.rightSlidingFractions count] == 0 && self.frame.origin.x+horizontalTranslation < 0) horizontalTranslation = 0;
        
        CGFloat retention = 0;
        
        if (self.bouncesAtLastSlidingFraction && [[currentSlidingFractions lastObject] isEqual:currentSlidingFraction]) {
            retention = (horizontalTranslation-currentSlidingFraction.activationFraction*self.frame.size.width)*0.75;
        }
        
        [self setCenter:CGPointMake(originalHorizontalCenter+horizontalTranslation-retention, self.center.y)];
        
        if (self.frame.origin.x > 0) currentSlidingFractions = self.leftSlidingFractions;
        else if (self.frame.origin.x < 0) currentSlidingFractions = self.rightSlidingFractions;
        
        PDGesturedTableViewCellSlidingFraction * oldSlidingFraction = currentSlidingFraction;
        
        currentSlidingFraction = [self currentSlidingFractionForArray:currentSlidingFractions];
        
        if (![oldSlidingFraction isEqual:currentSlidingFraction]) {
            if (oldSlidingFraction.didDeactivateBlock) oldSlidingFraction.didDeactivateBlock(self.gesturedTableView, self);
            if (currentSlidingFraction.didActivateBlock) currentSlidingFraction.didActivateBlock(self.gesturedTableView, self);
        }
        
        if (currentSlidingFraction) {
            [self.slidingView setBackgroundColor:currentSlidingFraction.color];
            [self.slidingView setIcon:currentSlidingFraction.icon];
            [self.slidingView setIconsAlpha:self.frame.origin.x > 0 ? 1 : -1];
        } else {
            PDGesturedTableViewCellSlidingFraction * firstSlidingFraction = [currentSlidingFractions firstObject];
            
            [self.slidingView setBackgroundColor:[UIColor clearColor]];
            [self.slidingView setIcon:[firstSlidingFraction icon]];
            [self.slidingView setIconsAlpha:fabsf(self.frame.origin.x)/(firstSlidingFraction.activationFraction*self.frame.size.width)];
        }
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (!currentSlidingFraction && self.frame.origin.x != 0) {
            [UIView animateWithDuration:0.1 animations:^{
                [self setFrame:CGRectMake((self.frame.origin.x > 0 ? -7 : 7), self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
                [self.slidingView setAlpha:0];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.1 animations:^{
                    [self setFrame:CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
                } completion:^(BOOL finished) {
                    [self.slidingView removeFromSuperview];
                    [self.slidingView setAlpha:1];
                }];
            }];
        } else {
            if (currentSlidingFraction.didReleaseBlock) currentSlidingFraction.didReleaseBlock(self.gesturedTableView, self);
        }
        
        currentSlidingFraction = nil;
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
    if (!self.gesturedTableView.didMoveCellFromIndexPathToIndexPathBlock) return;
    
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self.gesturedTableView setMoving:YES];
        
        copiedCell = [[PDGesturedTableViewCell alloc] initForGesturedTableView:self.gesturedTableView style:UITableViewCellStyleDefault reuseIdentifier:self.reuseIdentifier];
        [copiedCell setFrame:self.frame];
        [copiedCell setBackgroundColor:self.backgroundColor];
        
        for (UIView * view in self.contentView.subviews) {
            [copiedCell.contentView addSubview:view];
        }
        
        originIndexPath = [self.gesturedTableView indexPathForCell:self];
        [self setHidden:YES];
        [self.superview addSubview:copiedCell];
        
        [copiedCell.layer setShadowOffset:CGSizeZero];
        [copiedCell animateShadowWithRadius:2 opacity:0.6 duration:0.2];
        
        [UIView animateWithDuration:0.2 animations:^{
            [copiedCell setTransform:CGAffineTransformMakeScale(1.1, 1.1)];
        }];
        
        previousPoint = [longPressGestureRecognizer locationInView:self.gesturedTableView].y;
        
        [self resetPreviousAndNextCellAndIndexPath];
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
            if ([indexPaths objectExistsAtIndex:i-1]) {
                previousIndexPath = indexPaths[i-1];
                previousCell = (PDGesturedTableViewCell *)[self.gesturedTableView cellForRowAtIndexPath:previousIndexPath];
            }
            
            if ([indexPaths objectExistsAtIndex:i+1]) {
                nextIndexPath = indexPaths[i+1];
                nextCell = (PDGesturedTableViewCell *)[self.gesturedTableView cellForRowAtIndexPath:nextIndexPath];
            }
        }
    }
}

- (void)setFrame:(CGRect)frame {
    [self.slidingView setFrame:CGRectMake(self.slidingView.frame.origin.x, frame.origin.y, self.slidingView.frame.size.width, self.slidingView.frame.size.height)];
    [super setFrame:(self.gesturedTableView.updating ? CGRectMake(self.frame.origin.x, frame.origin.y, frame.size.width, frame.size.height) : frame)];
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
        [self setEdgeMovingMargin:80];
    }
    
    return self;
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
    [self moveCell:cell toHorizontalPosition:(cell.frame.origin.x > 0 ? cell.frame.size.width : -cell.frame.size.width) duration:0.4 completion:^{
        [UIView animateWithDuration:0.3 animations:^{
            [cell.slidingView setAlpha:0];
        } completion:^(BOOL finished) {
            NSIndexPath * indexPath = [self indexPathForCell:cell];
            if (completion) completion();
            [self setUpdating:YES];
            [self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self setUpdating:NO];
            [cell removeFromSuperview];
            [cell setFrame:CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
            [cell.slidingView removeFromSuperview];
            [cell.slidingView setAlpha:1];
        }];
    }];
}

- (void)replaceCell:(PDGesturedTableViewCell *)cell completion:(void (^)(void))completion {
    [self moveCell:cell toHorizontalPosition:0 duration:0.25 completion:^{
        [cell.slidingView removeFromSuperview];
        if (completion) completion();
    }];
}

- (void)showOrHideBackgroundView {
    [UIView animateWithDuration:0.3 animations:^{
        [self.backgroundView setAlpha:([self isEmpty] ? 1 : 0)];
    }];
}

- (BOOL)isEmpty {
    BOOL isEmpty = YES;
    
    for (NSInteger s = 0; s < [self numberOfSections]; s++) {
        if ([self numberOfRowsInSection:s] > 0) {
            isEmpty = NO;
        }
    }
    
    return isEmpty;
}

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [super insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self showOrHideBackgroundView];
}

- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [super insertSections:sections withRowAnimation:animation];
    [self showOrHideBackgroundView];
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [super deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self showOrHideBackgroundView];
}

- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [super deleteSections:sections withRowAnimation:animation];
    [self showOrHideBackgroundView];
}

- (void)reloadData {
    [super reloadData];
    [self showOrHideBackgroundView];
}

@end