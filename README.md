# UIViewControllerTransitionCoordinatorBug
in iOS 11.0~

UIViewControllerTransitionCoordinator is not working at the first transition after launcing.

https://openradar.appspot.com/38135706

It should be bug in iOS 11.0~. If you use your custom transition instead of the default transition, the bug is resolved.
