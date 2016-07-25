iMonitorMyFiles
===============
##### *Modern implementation of a file monitoring system for iOS*

[![Version](https://img.shields.io/cocoapods/v/iMonitorMyFiles.svg?style=flat)](http://cocoapods.org/pods/iMonitorMyFiles)
[![License](https://img.shields.io/cocoapods/l/iMonitorMyFiles.svg?style=flat)](http://cocoapods.org/pods/iMonitorMyFiles)
[![Platform](https://img.shields.io/cocoapods/p/iMonitorMyFiles.svg?style=flat)](http://cocoapods.org/pods/iMonitorMyFiles)

iMonitorMyFiles provides a simple Objective-C interface for responding to file system changes in iOS. If your users can create, modify, and/or delete files in your app's sandbox, this library provides a way to respond to those events. It also insulates you from a low-level C API (yikes!).

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

Your app must target iOS 7.0+.

## Installation

iMonitorMyFiles is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'iMonitorMyFiles', '~> 0.1.0'
```

and use the TABFileMonitor class for all your file monitoring needs:

```objc
#import <iMonitorMyFiles/TABFileMonitor.h>
```

### How it works

File monitoring is achieved by creating what GCD calls a "dispatch source" for whatever file or folder you want to monitor. When creating a dispatch source, you provide three interesting things:

1. A file descriptor that points to the file or folder
2. Flags to describe what kind of events you want to be notified about (file was modified, file was written to, etc.)
3. The queue on which to send these event notifications (the main queue, a background queue, etc.)

After creating a dispatch source, you then set blocks of code to be executed when an event occurs or when the source is canceled (destroyed). In the block you set for when an event occurs, you can determine which event occurred (if you registered for more than one type), and proceed accordingly with if...else...then or switch...case statements.

In order to continue monitoring a file after it has been deleted and recreated, my code destroys the dispatch source and file descriptor and subsequently recreates them. I did this because I noticed in testing that some applications invalidate the file descriptor we're using whenever they modify the file.

### Events to be notified about

* **DISPATCH_VNODE_ATTRIB** : The file's metadata changed.
    * This includes date modified, date last opened, etc.
* **DISPATCH_VNODE_DELETE** : The file was deleted.
* **DISPATCH_VNODE_EXTEND** : The file changed size.
* **DISPATCH_VNODE_LINK** : The file's object link count changed.
* **DISPATCH_VNODE_RENAME** : The file was renamed.
    * This is the notification that lets you know your file descriptor is now invalid.
* **DISPATCH_VNODE_REVOKE** : The file was revoked.
* **DISPATCH_VNODE_WRITE** : The file was modified.

### Thanks

* Cocoanetics' [Monitoring a Folder with GCD](http://www.cocoanetics.com/2013/08/monitoring-a-folder-with-gcd)
* David Hamrick's [Handling Filesysytem Events with GCD](http://www.davidhamrick.com/2011/10/10/handling-filesystem-events-with-gcd.html)

## Author

[Travis Blankenship](mailto:travis@sawtoothapps.com), [Sawtooth Apps LLC](http://www.sawtoothapps.com)

## License

iMonitorMyFiles is available under the MIT license. See the LICENSE file for more info.
