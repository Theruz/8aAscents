/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
An extension to `NSLock` to simplify executing critical code.

From Advanced NSOperations sample code in WWDC 2015 https://developer.apple.com/videos/play/wwdc2015/226/
From https://developer.apple.com/sample-code/wwdc/2015/downloads/Advanced-NSOperations.zip
*/

import Foundation

extension NSLock {
	
	
	/// Perform closure within lock.
	///
	/// An extension to `NSLock` to simplify executing critical code.
	///
	/// - parameter block: The closure to be performed.
	
	func withCriticalScope<T>( block: (Void) -> T) -> T {
		lock()
		let value = block()
		unlock()
		return value
	}
}
