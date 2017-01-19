//
//  AsyncBlockOperation.swift
//
//  Created by Or Elmaliah on 03/01/2016.
//  Copyright © 2016 Or Elmaliah. All rights reserved.
//

import Foundation

private let NSOperationIsExecutingKey = "isExecuting"
private let NSOperationIsFinishedKey = "isFinished"

public typealias OperationBlock = (Void) -> Void

public class AsyncBlockOperation: Operation {
    
    public var operationBlock: OperationBlock? = nil
    public var cancelBlock: OperationBlock? = nil
    public var identifier: String? = nil

    private var _isFinished = false {
        willSet {
            self.willChangeValue(forKey: NSOperationIsFinishedKey)
        }
        didSet {
            self.didChangeValue(forKey: NSOperationIsFinishedKey)
        }
    }
    
    private var _isExecuting = false {
        willSet {
            self.willChangeValue(forKey: NSOperationIsExecutingKey)
        }
        didSet {
            self.didChangeValue(forKey: NSOperationIsExecutingKey)
        }
    }
    
    override public func cancel() {
        super.cancel()
        self.cancelBlock?()
    }
    
    public class func operation(withIdentifier identifier: String, queue: OperationQueue) -> AsyncBlockOperation {
        let operation = AsyncBlockOperation()
        operation.identifier = identifier
        
        if !identifier.isEmpty {
            for enqueuedOperation in queue.operations {
                if let enqueuedOperation = enqueuedOperation as? AsyncBlockOperation, enqueuedOperation.identifier == identifier {
                    operation.addDependency(enqueuedOperation)
                }
            }
        }
        
        return operation
    }
    
    public class func cancelAllAsyncBlockOperation(onQueue queue: OperationQueue, withIdentifier identifier: String) {
        if !identifier.isEmpty {
            for operation in queue.operations {
                if let operation = operation as? AsyncBlockOperation, operation.identifier == identifier {
                    operation.cancel()
                    operation.complete()
                }
            }
        }
    }
    
    public class func cancelAllAsyncBlockOperation(onQueue queue: OperationQueue) {
        for operation in queue.operations {
            if let operation = operation as? AsyncBlockOperation {
                operation.cancel()
                operation.complete()
            }
        }
    }
    
    override public func start() {
        if self.isCancelled {
            self._isFinished = true
        }
        else if !self.isFinished && !self.isExecuting {
            self._isExecuting = true
            self.main()
        }
    }
    
    override public func main() {
        if let operationBlock = self.operationBlock {
            operationBlock()
        }
        else {
            self.complete()
        }
    }
    
    override public var isExecuting: Bool {
        return self._isExecuting
    }
    
    override public var isFinished: Bool {
        return self._isFinished
    }
    
    public func complete() {
        self._isExecuting = false
        self._isFinished = true
    }
}
