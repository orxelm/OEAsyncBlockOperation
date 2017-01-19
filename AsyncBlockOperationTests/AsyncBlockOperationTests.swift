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
        
        AsyncBlockOperation.cancelAllAsyncBlockOperation(onQueue: self.operationQueue)
    }
    
    /// Operations with the same identifier has dependency, they must execute by the order added to the operation queue
    func testAsyncBlockOperationWithDependency() {
        var operationOrderArray = [Int]()
        
        let operation = AsyncBlockOperation.operation(withIdentifier: kTestIdentifier, queue: self.operationQueue)
        
        weak var weakOperation = operation
        operation.operationBlock = {
            
            // wait 3 sec
            let loopUntil = Date(timeIntervalSinceNow: 3)
            while loopUntil.timeIntervalSinceNow > 0 {
                RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: loopUntil)
            }
            
            operationOrderArray.append(1)
            weakOperation?.completeOperation()
        }
        
        self.operationQueue.addOperation(operation)
        
        let operation2 = AsyncBlockOperation.operation(withIdentifier: kTestIdentifier, queue: self.operationQueue)
        
        weak var weakOperation2 = operation2
        operation2.operationBlock = {
            operationOrderArray.append(2)
            weakOperation2?.completeOperation()
        }
        
        self.operationQueue.addOperation(operation2)
        
        // wait 5 sec
        let loopUntil = Date(timeIntervalSinceNow: 5)
        while loopUntil.timeIntervalSinceNow > 0 {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: loopUntil)
        }
        
        XCTAssertEqual(operationOrderArray, [1, 2])
    }
    
    /// Operations without the same identifier doesn't has dependency, they can execute simultaneously
    func testAsyncBlockOperationWithoutDependency() {
        var operationOrderArray = [Int]()
        
        let operation = AsyncBlockOperation.operation(withIdentifier: "some_identifier_1", queue: self.operationQueue)
        
        weak var weakOperation = operation
        operation.operationBlock = {
            
            // wait 3 sec
            let loopUntil = Date(timeIntervalSinceNow: 3)
            while loopUntil.timeIntervalSinceNow > 0 {
                RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: loopUntil)
            }
            
            operationOrderArray.append(1)
            weakOperation?.completeOperation()
        }
        
        self.operationQueue.addOperation(operation)
        
        let operation2 = AsyncBlockOperation.operation(withIdentifier: "some_identifier_2", queue: self.operationQueue)
        
        weak var weakOperation2 = operation2
        operation2.operationBlock = {
            operationOrderArray.append(2)
            weakOperation2?.completeOperation()
        }
        
        self.operationQueue.addOperation(operation2)
        
        // wait 5 sec
        let loopUntil = Date(timeIntervalSinceNow: 5)
        while loopUntil.timeIntervalSinceNow > 0 {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: loopUntil)
        }
        
        XCTAssertEqual(operationOrderArray, [2, 1])
    }
    
    /// Operations that doesn't call Self.completeOperation() will never exit the queue
    func testCompleteOperation() {
        var didOperationComplete = false
    
        let operation = AsyncBlockOperation.operation(withIdentifier: kTestIdentifier, queue: self.operationQueue)
        operation.operationBlock = {
            // Doesn't call Self.Self.completeOperation() in purpose!
        }
        
        self.operationQueue.addOperation(operation)
        
        let operation2 = AsyncBlockOperation.operation(withIdentifier: kTestIdentifier, queue: self.operationQueue)
        operation2.operationBlock = {
            didOperationComplete = true
        }
        
        self.operationQueue.addOperation(operation2)
        
        // wait 5 sec
        let loopUntil = Date(timeIntervalSinceNow: 5)
        while loopUntil.timeIntervalSinceNow > 0 {
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: loopUntil)
        }
        
        XCTAssertFalse(didOperationComplete)
    }
    
    /// Test cancel block fired on operation cancel
    func testCancelBlockOperation() {
        var isCancelBlockFired = false
        let operation = AsyncBlockOperation.operation(withIdentifier: kTestIdentifier, queue: self.operationQueue)
        operation.operationBlock = {
            print("running!")
        }
        
        operation.cancelBlock = {
            isCancelBlockFired = true
        }
        
        self.operationQueue.addOperation(operation)
        AsyncBlockOperation.cancelAllAsyncBlockOperation(onQueue: self.operationQueue)
        
        XCTAssertTrue(isCancelBlockFired)
    }
    
    /// Test mass cancel block fired on operation cancel
    func testMassCancelBlockOperation() {
        var numOfCancelledOperations = 0
        
        let operation1 = AsyncBlockOperation.operation(withIdentifier: kTestIdentifier, queue: self.operationQueue)
        operation1.operationBlock = { print("running!") }
        operation1.cancelBlock = { numOfCancelledOperations += 1 }
        
        let operation2 = AsyncBlockOperation.operation(withIdentifier: "2", queue: self.operationQueue)
        operation2.cancelBlock = { numOfCancelledOperations += 1 }
        let operation3 = AsyncBlockOperation.operation(withIdentifier: "3", queue: self.operationQueue)
        operation3.cancelBlock = { numOfCancelledOperations += 1 }
        
        self.operationQueue.addOperations([operation1, operation2, operation3], waitUntilFinished: false)
        AsyncBlockOperation.cancelAllAsyncBlockOperation(onQueue: self.operationQueue)
        
        XCTAssertTrue(numOfCancelledOperations == 3)
    }
    
    /// Test the cancel all operation method
    func testCancelAllOperations() {
        let operation1 = AsyncBlockOperation.operation(withIdentifier: "1", queue: self.operationQueue)
        operation1.operationBlock = { }
        
        let operation2 = AsyncBlockOperation.operation(withIdentifier: "2", queue: self.operationQueue)
        let operation3 = AsyncBlockOperation.operation(withIdentifier: "3", queue: self.operationQueue)
        
        self.operationQueue.addOperations([operation1, operation2, operation3], waitUntilFinished: false)
        AsyncBlockOperation.cancelAllAsyncBlockOperation(onQueue: self.operationQueue)
        
        XCTAssertTrue(self.operationQueue.operationCount == 0)
    }
    
    /// Cancel all operations with identifier should cancel ONLY the relevant operations!
    func testCancelAllOperationsWithIdentifier() {
        let operation1 = AsyncBlockOperation.operation(withIdentifier: kTestIdentifier, queue: self.operationQueue)
        operation1.operationBlock = { }
        
        let operation2 = AsyncBlockOperation.operation(withIdentifier: kTestIdentifier, queue: self.operationQueue)
        let operation3 = AsyncBlockOperation.operation(withIdentifier: kTestIdentifier, queue: self.operationQueue)
        let operation4 = BlockOperation()
        operation4.addExecutionBlock {
            sleep(20)
        }
        
        let operation5 = BlockOperation()
        operation5.addExecutionBlock {
            sleep(20)
        }
        
        self.operationQueue.addOperations([operation1, operation2, operation3, operation4, operation5], waitUntilFinished: false)
        
        AsyncBlockOperation.cancelAllAsyncBlockOperation(onQueue: self.operationQueue, withIdentifier: kTestIdentifier)
        
        XCTAssertTrue(self.operationQueue.operationCount == 2)
    }
}
