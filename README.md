# OEAsyncBlockOperation
[![CocoaPods](https://img.shields.io/cocoapods/v/OEAsyncBlockOperation.svg?maxAge=2592000)]()
[![Swift 2.2](https://img.shields.io/badge/Swift-2.2-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Twitter](https://img.shields.io/badge/Twitter-@orelm-blue.svg?style=flat)](http://twitter.com/OrElm)

A simple NSOperation subclass to perform asynchronous operations on NSOperationQueue. In which operation isn't finished until you invoke 'completeOperation()'.
Mostly common for autocomplete requests when you want to perform only one async request at a time, wait for the async operation to end before exiting the queue.
## Requirements
Swift 2+

## Installation
### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate OEAsyncBlockOperation into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

pod 'OEAsyncBlockOperation'
```

Then, run the following command:

```bash
$ pod install
```

### Manually
Just drag AsyncBlockOperation.swift file to your xcode project

## Usage
### Create Operation
```swift
self.operationQueue = NSOperationQueue()
self.operationQueue.maxConcurrentOperationCount = 1
...

let operation = AsyncBlockOperation.operation(withIdentifier: kBlockOperationIdentifer, queue: self.operationQueue)
weak var weakOperation = operation
operation.operationBlock = {
  RequestsManager.defaultManager.performAsyncRequestWithCompletionHandler {
    weakOperation?.completeOperation()
  }
}

self.operationQueue.addOperation(operation)
...
```
### Cancel All Operations
```swift
AsyncBlockOperation.cancelAllAsyncBlockOperation(onQueue: self.operationQueue, withIdentifier: kBlockOperationIdentifer)
```

## TO-DO
- [x] Support Cocoapods
- [x] Support Swift3
- [ ] Add tests
