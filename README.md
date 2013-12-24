PDGesturedTableView
===================

Great Mailbox-like UITableView subclass.

<p align="center">
	<img src="https://raw.github.com/Dromaguirre/PDGesturedTableView/master/Images/1.gif" alt="PDGesturedTableView GIF" title="PDGesturedTableView GIF" width="320px" />
</p>

## Features

- **Multiple actions** in a single slide depending on the lenght the user slided.
- **Tap and hold** to move cells.
- A **UIView** can be set to be shown **when there's no content** on the table view.
- Super easy **customization**.
- A **left and right margin** can be set to let the user swipe between different table views.
- **Block-driven**. No silly delegates :)

## CocoaPods

You can install PDGesturedTableView through CocoaPods adding the following to your Podfile:

	pod 'PDGesturedTableView'

## How to use

PDGesturedTableView basic setup is exactly the same as an usual UITableView.

### Adding actions to cells

This implementation should go in your `tableView:cellForRowAtIndexPath:` method call as follows:

	- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
		[...]
		
		[cell addActionForFraction:0.25 icon:actionIcon color:actionColor activationBlock:^(PDGesturedTableView *gesturedTableView, PDGesturedTableViewCell *cell) {
            // Action for user release.
        } highlightBlock:^(PDGesturedTableView *gesturedTableView, PDGesturedTableViewCell *cell) {
            // Optional action for when the action highlights.
        } unhighlightBlock:^(PDGesturedTableView *gesturedTableView, PDGesturedTableViewCell *cell) {
            // Optional action for when the action unhighlights.
        }];
	}

As you can see, we only use one (long) method to add an action to the cell. Let's analyze it:

- **`fraction`** specifies the fraction of the entire cell width where the action will be highlighted. For instance, if you specify 0.5 the action will highlight when the cell gets to the center of the table. Also, if you specify a negative value, say -0.5, the action will highlight when the cell gets to the center, too, but on its right side.
- **`icon`** is the icon for that action.
- **`color`** is the color for the action highlight.
- **`activationBlock`** is the block that will execute when the user releases the cell.
- **`highlightBlock`** is the block that will execute when the action highlights.
- **`unhighlightBlock`** is the block that will execute when the action unhighlights.

#### Main actions for `activationBlock`.

`activationBlock` can contain any action you want, but I highly recommended to use one of the following methods in addition to the ones you use:

- PDGesturedTableView's `removeCell:completion:`, which removes the specified cell from the table view animatedly. In the `completion` block you **MUST** delete the object that cell is representing from the table view data source.
- PDGesturedTableView's `replaceCell:completion`, which returns the cell to the place it was before the user dragged it.

## Wish List

- ~~**Multiple actions** in a single slide depending on the lenght the user slided (Mailbox feature).~~
- ~~A **UIView** can be set to be shown **when there's no content** on the table view (Mailbox feature).~~
- ~~**CocoaPods** support.~~
- ~~**Move cells** with a long press and pan gesture.~~
- **Autoscroll** when the current moving cell is near the edge of the screen. **I'll need some help with this**.

## Requirements

- iOS 7 or higher.
- Automatic Reference Counting (ARC).

## License

You can use it for whatever you want, however you want. I just **[would love to know](mailto:dromaguirre@gmail.com)** if you're using it in any project of yours.