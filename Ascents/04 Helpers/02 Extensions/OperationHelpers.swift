//
//  OperationHelpers.swift
//  Ascents
//
//  Created by Theophile on 27.01.17.
//  Copyright © 2017 Theophile. All rights reserved.
//

import Foundation


/// Asynchronous Operation base class
///
/// This class performs all of the necessary KVN of `isFinished` and
/// `isExecuting` for a concurrent `NSOperation` subclass. So, to developer
/// a concurrent NSOperation subclass, you instead subclass this class which:
///
/// - must override `main()` with the tasks that initiate the asynchronous task;
///
/// - must call `completeOperation()` function when the asynchronous task is done;
///
/// - optionally, periodically check `self.cancelled` status, performing any clean-up
///   necessary and then ensuring that `completeOperation()` is called; or
///   override `cancel` method, calling `super.cancel()` and then cleaning-up
///   and ensuring `completeOperation()` is called.

public class AsynchronousOperation: Operation {
	
	override public var isAsynchronous: Bool { return true }
	
	private let stateLock = NSLock()
	
	private var _executing: Bool = false
    
    private var isExecutingKey = "isExecuting"
    private var isFinishedKey = "isFinished"
    
	override private(set) public var isExecuting: Bool {
		get {
			return stateLock.withCriticalScope { _executing }
		}
		set {
			willChangeValue(forKey: isExecutingKey)
			stateLock.withCriticalScope { _executing = newValue }
			didChangeValue(forKey: isExecutingKey)
		}
	}
	
	private var _finished: Bool = false
	override private(set) public var isFinished: Bool {
		get {
			return stateLock.withCriticalScope { _finished }
		}
		set {
			willChangeValue(forKey: isFinishedKey)
			stateLock.withCriticalScope { _finished = newValue }
			didChangeValue(forKey: isFinishedKey)
		}
	}
	
	/// Complete the operation
	///
	/// This will result in the appropriate KVN of isFinished and isExecuting
	
	public func completeOperation() {
		if isExecuting {
			isExecuting = false
		}
		
		if !isFinished {
			isFinished = true
		}
	}
	
	override public func start() {
		if isCancelled {
			isFinished = true
			return
		}
		
		isExecuting = true
		
		main()
	}
	
	override public func main() {
		fatalError("subclasses must override `main`") // localization check:this:disable
	}
}

extension OperationQueue {
	
	/// Execute block after all operations from the array.
	func onFinish(completionHandler: @escaping () -> Void) {
		
		let doneOperation = BlockOperation(block: completionHandler)
		operations.forEach { [unowned doneOperation] in doneOperation.addDependency($0) }
		addOperation(doneOperation)
	}
}
