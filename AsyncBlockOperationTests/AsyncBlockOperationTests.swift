//
//  AsyncBlockOperationTests.swift
//  AsyncBlockOperationTests
//
//  Created by Or Elmaliah on 31/10/2016.
//  Copyright © 2016 Or Elmaliah. All rights reserved.
//

import XCTest
import AsyncBlockOperation

private let kTestIdentifier = "TestIdentifier"

class AsyncBlockOperationTests: XCTestCase {
    
    private let operationQueue = OperationQueue()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testAsyncBlockOperation() {
        
        AsyncBlockOperation.cancelAllAsyncBlockOperation(onQueue: self.operationQueue, withIdentifier: kTestIdentifier)
        
        let operation = AsyncBlockOperation.operation(withIdentifier: kTestIdentifier, queue: self.operationQueue)
        
        weak var weakOperation = operation
        operation.operationBlock = {
            
            // wait 3 sec
            let loopUntil = Date.init(timeIntervalSinceNow: 3)
            while (loopUntil.timeIntervalSinceNow > 0) {
                RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: loopUntil)
            }
            print("1")
            weakOperation?.completeOperation()
        }
        
        self.operationQueue.addOperation(operation)
        
        let operation2 = AsyncBlockOperation.operation(withIdentifier: kTestIdentifier, queue: self.operationQueue)
        
        weak var weakOperation2 = operation2
        operation2.operationBlock = {
            print("2")
            weakOperation2?.completeOperation()
        }
        
        self.operationQueue.addOperation(operation2)
    }
}
