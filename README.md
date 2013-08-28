PDGesturedTableView
===================

This UITableView subclass provides some great functions, as Clear or Mailbox do.

## Features

- Edit cell titles just by tapping them.
- Cells autoresize automatically as user types text.
- A left and right margin can be set to let the user swipe between different table views.
- Let the user slide cells to perform different actions.
- And many more to come :)

## How to use

### Delegate

Instead of implementing `UITableViewDelegate`, you must implement `PDGesturedTableViewSecondaryDelegate`.

#### Required methods

	- (NSString *)gesturedTableView:(PDGesturedTableView *)gesturedTableView stringForTitleTextViewForRowAtIndexPath:(NSIndexPath *)indexPath {
    	return @"This is the text that will be shown in the cell at that given index path";
	}

### Instantiation



## Wish list

- Be able to move cells with a long press and pan gesture.

## LICENSE

You can use it for whatever you want, however you want. I just would love to know if you're using it in any project of yours.