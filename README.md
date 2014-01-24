PDGestureTableView
===================

<br />

<p align="center">
	<img src="https://raw.github.com/Dromaguirre/PDGestureTableView/images/1.png" alt="PDGestureTableView" title="PDGestureTableView" width="470px" />
</p>

## Features

- **Swipe** cells to perform multiple actions.
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

#### Actions for `didTriggerBlock`.

`didTriggerBlock` can contain any action you want, but I highly recommended to use one of the following methods in addition to the ones you want to use:

- PDGestureTableView's `removeCell:completion:`, which removes the specified cell from the table view animatedly. It works in a similar way to `deleteRowsAtIndexPaths:withRowAnimation` so before calling it you must remove any pertinent data from the data source.

	```objective-c
	[...]
	
	didTriggerBlock:^(PDGestureTableView * gestureTableView, PDGestureTableViewCell * cell) {
	    NSIndexPath * indexPath = [gestureTableView indexPathForCell:cell];
	    
	    [dataArray removeObjectAtIndex:indexPath.row];
	    
	    [gestureTableView removeCell:cell duration:0.25 completion:^{
	        NSLog(@"Cell removed!");
	    }];
	}];
	```

- PDGestureTableView's `replaceCell:duration:bounce:completion:`, which replaces the cell to its original position (`bounce` specifies how much bounce effect will it be replaced with).
	
	```objective-c
	[...]
	
	didTriggerBlock:^(PDGestureTableView * gestureTableView, PDGestureTableViewCell * cell) {
	    [gestureTableView replaceCell:cell duration:0.25 bounce:10 completion:nil];
	}];
	```

**Note:** if you set animation durations to `0`, it'll use a default appropriate duration.

## Wish List

- Autoscroll when the current moving cell is near the edge of the table view.
- Cell bouncing when reaching the last action.

## Requirements

- iOS 7 or higher.
- Automatic Reference Counting (ARC).

## License

PDGestureTableView is available under the MIT license.

Also, I'd really love to know you're using it in any of your projects, so send me an [**email**](mailto:dromaguirre@gmail.com) or a [**tweet**](http://twitter.com/Dromaguirre) and make my day :)
