//
//  AsyncBlockOperation.swift
//
//  Created by Or Elmaliah on 03/01/2016.
//  Copyright © 2016 Or Elmaliah. All rights reserved.
//

import Foundation

private let NSOperationIsExecutingKey = "isExecuting"
private let NSOperationIsFinishedKey = "isFinished"

typealias OperationBlock = Void -> Void

class AsyncBlockOperation: NSOperation {
    
    var operationBlock: OperationBlock? = nil
    var identifier: String? = nil

    private var isFinished = false {
        willSet {
            self.willChangeValueForKey(NSOperationIsFinishedKey)
        }
        didSet {
            self.didChangeValueForKey(NSOperationIsFinishedKey)
        }
    }
    
    private var isExecuting = false {
        willSet {
            self.willChangeValueForKey(NSOperationIsExecutingKey)
        }
        didSet {
            self.didChangeValueForKey(NSOperationIsExecutingKey)
        }
    }
    
    class func operationWithIdentifier(identifier: String, queue: NSOperationQueue) -> AsyncBlockOperation {
        let operation = AsyncBlockOperation()
        operation.identifier = identifier
        
        if !identifier.isEmpty {
            for enqueuedOperation in queue.operations {
                if let enqueuedOperation = enqueuedOperation as? AsyncBlockOperation where enqueuedOperation.identifier == identifier {
                    operation.addDependency(enqueuedOperation)
                }
            }
        }
        
        return operation
    }
    
    class func cancelAllAsyncBlockOperationOnQueue(queue: NSOperationQueue, withIdentifier identifier: String) {
        if !identifier.isEmpty {
            for operation in queue.operations {
                if let operation = operation as? AsyncBlockOperation where operation.identifier == identifier {
                    operation.cancel()
                }
            }
        }
    }
    
    override func start() {
        if self.cancelled {
            self.isFinished = true
        }
        else if !self.finished && !self.isExecuting {
            self.isExecuting = true
            self.main()
        }
    }
    
    override func main() {
        if let operationBlock = self.operationBlock {
            operationBlock()
        }
        else {
            self.completeOperation()
        }
    }
    
    override var executing: Bool {
        return self.isExecuting
    }
    
    override var finished: Bool {
        return self.isFinished
    }
    
    func completeOperation() {
        self.isExecuting = false
        self.isFinished = true
    }
}
