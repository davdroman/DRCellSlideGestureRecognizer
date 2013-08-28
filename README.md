PDGesturedTableView
===================

This UITableView subclass provides some great **gesture-based functions** to ordinary UITableView, similar to Clear's or Mailbox's.

Check out the **example app**. You'll see it's not hard at all to implement this powerful control.

## Features

- **Cell titles edition** just by tapping on them.
- **Cell automatic autoresizing** as user types text.
- A **left and right margin** can be set to let the user swipe between different table views.
- Let the user **slide cells** to perform different actions.
- And **many more** to come :)

## Notes

- Instead of implementing `UITableViewDelegate`, you must implement `PDGesturedTableViewSecondaryDelegate`. If you don't do that, it won't work properly.

## Wish list

- Be able to **move cells** with a long press and pan gesture.
- Extract the **text views** editing part and implement it as a **complement**.

## LICENSE

You can use it for whatever you want, however you want. I just would love to know if you're using it in any project of yours.