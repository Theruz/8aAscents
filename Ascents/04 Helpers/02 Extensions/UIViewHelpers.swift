//
//  UIViewHelpers.swift
//  Ascents
//
//  Created by Theophile on 22.02.17.
//  Copyright © 2017 Theophile. All rights reserved.
//

import Foundation
import UIKit


extension UIView {
	
	private struct AssociatedKeys {
		static var actionClosureKey = "UIView.ActionClosureKey"
	}
	
	private class ClosureWrapper {
		var closure: (() -> Void)?
		
		init(_ closure: (() -> Void)?) {
			self.closure = closure
		}
	}
	
	private var actionClosure: (() -> Void)? {
		
		get {
			if let cl = objc_getAssociatedObject(self, &AssociatedKeys.actionClosureKey) as? ClosureWrapper {
				return cl.closure
			}
			return nil
		}
		set {
			objc_setAssociatedObject(self, &AssociatedKeys.actionClosureKey, ClosureWrapper(newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
		
	}
	
	@objc private func triggerActionClosure() {
		self.actionClosure?()
	}
	
	/// Add an action closure with the view.
	///
	/// - parameter controlEvent: A bitmask specifying the control-specific events for which the action method is called. Always specify at least one constant. For a list of possible constants, see UIControlEvents. Can be ommited, touchUpInside is used by default. Will only be taken into account if the receiver is a UIControl
	/// - parameter action:       A closure containing the actions to be executed.
	public func addAction(for controlEvent: UIControlEvents = .touchUpInside, action: @escaping () -> Void) {
		
		self.actionClosure = action
		
		if let strongSelf = self as? UIControl {
			strongSelf.addTarget(self, action: #selector(triggerActionClosure), for: controlEvent)
		} else {
			self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(triggerActionClosure)))
			self.isUserInteractionEnabled = true
		}
	}
}
