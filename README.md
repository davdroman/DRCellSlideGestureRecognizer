PDGestureTableView
===================

<br />

<p align="center">
	<img src="https://raw.github.com/Dromaguirre/PDGestureTableView/images/1.png" alt="PDGestureTableView" title="PDGestureTableView" width="470px" />
</p>

## Features

- __Swipe__ cells to perform multiple actions.
- __Tap and hold__ to move cells.
- A __UIView__ can be set to be shown __when there's no content__ on the table view.
- __Storyboards/Xibs__ & __Autolayout__ fully compatible.
- __Block-driven__. No silly delegates :)

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

This is how actions should be set:

```objective-c
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [...]

    cell.firstLeftAction = [PDGestureTableViewCellAction
                            actionWithIcon:[UIImage imageNamed:@"icon"]
                            color:[UIColor greenColor]
                            fraction:0.25
                            didTriggerBlock:^(PDGestureTableView *gestureTableView, NSIndexPath*indexPath) {
                                // Action for first left action triggering.
                            }];

    cell.secondLeftAction = [PDGestureTableViewCellAction
                            actionWithIcon:[UIImage imageNamed:@"icon"]
                            color:[UIColor redColor]
                            fraction:0.7
                            didTriggerBlock:^(PDGestureTableView *gestureTableView, NSIndexPath*indexPath) {
                                // Action for second left action triggering.
                            }];

    return cell;
}
```

- `icon` is the UIImage __icon__ for that action.
- `color` is the UIColor for the action __highlight__.
- `fraction` specifies the fraction of the entire cell width where the action __will be highlighted__. For instance, if you specify 0.5 the action will highlight when the cell gets to the middle of the table width.
- `didTriggerBlock` is the block that will execute when the user __releases the cell__.

#### Actions for `didTriggerBlock`

`didTriggerBlock` can contain any action you want, but besides the ones you use, you must use one of the following:

##### `pushCellForIndexPath:completion` + `deleteCellForIndexPath:animation:completion`

Usually, you'll use these two methods to delete a cell in a table view whose data source is being managed by a `NSFetchedResultsController` object.

The first method will push it to the edge of the table view, and the second one will be called in the `NSFetchedResultsController` delegate method. It'll work great for non-gestural deletions as well.

```objective-c
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	[...]

	__unsafe_unretained typeof(self) weakSelf = self; // Get a weak reference of self so you can access it from didTriggerBlock without creating retain cycles.

	cell.firstLeftAction = [PDGestureTableViewCellAction
							actionWithIcon:[UIImage imageNamed:@"icon"]
							color:[UIColor greenColor]
							fraction:0.25
							didTriggerBlock:^(PDGestureTableView *gestureTableView, NSIndexPath *indexPath) {
								NSManagedObject *object = [weakSelf.fetchedResultsController objectAtIndexPath:indexPath];

								[weakSelf.fetchedResultsController deleteObject:object];
							}];

	return cell;
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	switch(type) {
		[...]

        case NSFetchedResultsChangeDelete:
            [self.gestureTableView deleteCellForIndexPath:indexPath animation:UITableViewRowAnimationRight completion:nil];
            break;

		[...]
    }
}
```

##### `pushAndDeleteCellForIndexPath:completion:`

This method is composed by the two above. You call it when you just want to delete a cell from a table view not being managed by a `NSFetchedResultsController`. Before calling it you must remove any pertinent data from the data source.

```objective-c
[...]

didTriggerBlock:^(PDGestureTableView *gestureTableView, NSIndexPath *indexPath) {
	[dataArray removeObjectAtIndex:indexPath.row];

	[gestureTableView beginUpdates];

    [gestureTableView pushAndDeleteCellForIndexPath:indexPath completion:^{
        // Cell deleted.
    }];

	[gestureTableView endUpdates];
}];
```

Notice you __must__ use `beginUpdates` and `endUpdates` methods before and after calling this method, respectively.

##### `replaceCellForIndexPath:completion:`

Replaces the cell to its original position.

```objective-c
[...]

didTriggerBlock:^(PDGestureTableView *gestureTableView, NSIndexPath *indexPath) {
    [gestureTableView replaceCellForIndexPath:indexPath completion:nil];
}];
```

If you don't want the cell to bounce when replacing, set `cellBouncesWhenReplacing` to `NO`.

Also, if you want to set the duration of all these animations, you can set `animationsDuration` to the amount of time you want.

## Wish List

- Autoscroll when the current moving cell is near the edge of the table view.
- Cell bouncing when reaching the last action.

## Requirements

- iOS 7 or higher.
- Automatic Reference Counting (ARC).

## License

PDGestureTableView is available under the MIT license.

Also, I'd really love to know you're using it in any of your projects, so send me an [__email__](mailto:dromaguirre@gmail.com) or a [__tweet__](http://twitter.com/Dromaguirre) and make my day :)
