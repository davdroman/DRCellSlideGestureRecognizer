//
//  DRCellSlideGestureRecognizer.h
//  DRCellSlideGestureRecognizer
//
//  Created by David Román Aguirre on 12/5/15.
//
//

#import <UIKit/UIKit.h>

#import "DRCellSlideAction.h"

@interface DRCellSlideGestureRecognizer : UIPanGestureRecognizer <UIGestureRecognizerDelegate>

- (void)addActions:(id)actions;

@end
