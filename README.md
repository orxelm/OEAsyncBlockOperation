# OEAsyncBlockOperation
A simple NSOperation subclass to perform asynchronous operations on NSOperationQueue. In which operation isn't finished until you invoke 'completeOperation()'.
Mostly common for autocomplete requests when you want to perform only one async request at a time, wait for the async operation to end before exiting the queue.
## Requirements
Swift 2+

## Installation
Just drag OEAsyncBlockOperation.swift file to your xcode project

## Usage
### Create Operation
```swift
self.operationQueue = NSOperationQueue()
self.operationQueue.maxConcurrentOperationCount = 1
...

let operation = OEAsyncBlockOperation.operationWithIdentifier(kBlockOperationIdentifer, queue: self.operationQueue)
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
OEAsyncBlockOperation.cancelAllAsyncBlockOperationOnQueue(self.operationQueue, withIdentifier: kBlockOperationIdentifer)
```
