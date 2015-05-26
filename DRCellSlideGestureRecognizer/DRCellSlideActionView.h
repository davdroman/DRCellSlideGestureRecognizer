//
//  DRCellSlideActionView.h
//  DRCellSlideGestureRecognizer
//
//  Created by David Román Aguirre on 17/5/15.
//
//

#import <UIKit/UIKit.h>

@class DRCellSlideAction;

@interface DRCellSlideActionView : UIView

@property (nonatomic, getter=isActive) BOOL active;
@property (nonatomic, weak) DRCellSlideAction *action;

- (void)cellDidUpdatePosition:(UITableViewCell *)cell;

@end
