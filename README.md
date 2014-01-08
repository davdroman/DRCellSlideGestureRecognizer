PDGestureTableView
===================

<br />

<p align="center">
	<img src="https://raw.github.com/Dromaguirre/PDGestureTableView/images/1.png" alt="PDGestureTableView" title="PDGestureTableView" width="470px" />
</p>

## Features

- **Swipe** the cells to perform multiple actions.
- **Tap and hold** to move cells.
- A **UIView** can be set to be shown **when there's no content** on the table view.
- A **left and right margin** can be set so if the table view is inside a scroll view the user can scroll it by swiping the edges.
- **Storyboards/Xibs** & **Autolayout** fully compatible.
- **Block-driven**. No silly delegates :)

## CocoaPods

You can install PDGestureTableView through CocoaPods adding the following to your Podfile:

	pod 'PDGestureTableView'

## At a glance

### Setting up actions for a cell

PDGestureTableViewCell has 4 possible actions:

- `firstLeftAction`
- `secondLeftAction`
- `firstRightAction`
- `secondRightAction`

Here's how actions should be set:

```objective-c
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [...]
    
    cell.firstLeftAction = [PDGestureTableViewCellAction
                            actionWithIcon:[UIImage imageNamed:@"icon"]
                            color:[UIColor greenColor]
                            fraction:0.25
                            didTriggerBlock:^(PDGestureTableView *gestureTableView, PDGestureTableViewCell *cell) {
                                // Action for first left action triggering.
                            }];
                            
    cell.secondLeftAction = [PDGestureTableViewCellAction
                            actionWithIcon:[UIImage imageNamed:@"icon"]
                            color:[UIColor redColor]
                            fraction:0.7
                            didTriggerBlock:^(PDGestureTableView *gestureTableView, PDGestureTableViewCell *cell) {
                                // Action for second left action triggering.
                            }];
    
    return cell;
}
```

- `icon` is the UIImage **icon** for that action.
- `color` is the UIColor for the action **highlight**.
- `fraction` specifies the fraction of the entire cell width where the action **will be highlighted**. For instance, if you specify 0.5 the action will highlight when the cell gets to the middle of the table width.
- `didTriggerBlock` is the block that will execute when the user **releases the cell**.

As you can see, there's a class method `actionWithIcon:color:fraction:didTriggerBlock` available for creating actions, but you can also use some others. These are all methods you can use to **create an action**:

- `actionWithIcon:color:`
- `actionWithIcon:color:fraction:`
- `actionWithIcon:color:fraction:didTriggerBlock:`
- `actionWithIcon:color:fraction:didTriggerBlock:didHighlightBlock:didUnhighlightBlock:`

#### Main actions for `didTriggerBlock`.

`didTriggerBlock` can contain any action you want, but I highly recommended to use one of the following methods in addition to the ones you want to use:

- PDGestureTableView's `removeCell:completion:`, which removes the specified cell from the table view animatedly. It works in a similar way to `deleteRowsAtIndexPaths:withRowAnimation` so before calling it you must remove any pertinent data from the data source.

	```objective-c
	[cell.firstLeftAction setDidTriggerBlock:^(PDGestureTableView * gestureTableView, PDGestureTableViewCell * cell) {
	    NSIndexPath * indexPath = [gestureTableView indexPathForCell:cell];
	    
	    [dataArray removeObjectAtIndex:indexPath.row];
	    
	    [gestureTableView removeCell:cell completion:^{
	        NSLog(@"Cell removed!");
	    }];
	}];
	```

- PDGestureTableView's `replaceCell:bounce:completion:`, which replaces the cell to its original position (bounce specifies how much bounce effect will it be replaced with).
	
	```objective-c
	[cell.firstLeftAction setDidTriggerBlock:^(PDGestureTableView * gestureTableView, PDGestureTableViewCell * cell) {
	    [gestureTableView replaceCell:cell bounce:10 completion:nil];
	}];
	```

## Wish List

- Autoscroll when the current moving cell is near the edge of the screen (currently working on this).
- Cell bouncing when reaching the last action.

## Requirements

- iOS 7 or higher.
- Automatic Reference Counting (ARC).

## License

You can use it with total freedom. I just would love to know if you're using it in any project of yours, so an [**email**](mailto:dromaguirre@gmail.com) or a [**tweet**](http://twitter.com/Dromaguirre) would be really appreciated :)
