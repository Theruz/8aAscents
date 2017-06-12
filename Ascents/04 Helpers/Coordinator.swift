//
//  Coordinator.swift
//  Ascents
//
//  Created by Theophile on 06.04.17.
//  Copyright © 2017 Theophile. All rights reserved.
//

import Foundation
import UIKit

enum CoordinationError: Error, CustomStringConvertible {
    case failedToPrepare(viewController:String)
    case failedToStart(viewController:String)
    
    var description: String {
        // localization check:disable
        switch self {
        case .failedToPrepare(let viewController): return "Error: Failed to prepare \(viewController)"
        case .failedToStart(let viewController): return "Error: Failed to start \(viewController)"
        }
        // localization check:enable
    }
}

class Coordinator {
    
    var window: UIWindow
    var viewControllers: [String: UIViewController] = [:]
    weak var navigationController: UINavigationController?
    
    init(_ window: UIWindow, navigationController: UINavigationController? = nil) {
        self.window = window
        self.navigationController = navigationController
        UIViewController.addCoordination()
    }
    
    func prepare<T: UIViewController>(with viewController: UIViewController? = nil) throws -> T where T: Coordinated {
        
        var initialViewController: T
        
        if let viewController = viewController as? T {
            initialViewController = viewController
            
        } else if let navigationController = viewController as? UINavigationController,
            let viewController = navigationController.topViewController as? T {
            self.navigationController = navigationController
            initialViewController = viewController
            
        } else if let viewController = viewControllers[T.coordinationIdentifier] as? T {
            initialViewController = viewController
            
        } else if let viewController = navigationController?.topViewController as? T {
            initialViewController = viewController
            
        } else if let storyBoardIdentifier = T.storyboardIdentifier,
            let viewController = UIStoryboard(name: storyBoardIdentifier, bundle: nil)
                .instantiateInitialViewController() as? T {
            initialViewController = viewController
            
        } else if let storyBoardIdentifier = T.storyboardIdentifier,
            let navigationController = UIStoryboard(name: storyBoardIdentifier, bundle: nil)
                .instantiateInitialViewController() as? UINavigationController,
            let viewController = navigationController.topViewController as? T {
            self.navigationController = navigationController
            initialViewController = viewController
            
        } else { throw CoordinationError.failedToPrepare(viewController: T.coordinationIdentifier) }
        
        viewControllers[T.coordinationIdentifier] = initialViewController
        
        return initialViewController
    }
    
    // Subclasses need to override this method
    func start(with viewController: UIViewController? = nil) throws {}
    
    func present(_ viewController: UIViewController) {
        UIView.transition(with: window, duration: 0.2, options: .transitionCrossDissolve,
                          animations: { self.window.rootViewController = viewController })
    }
}


/// Every coordinator should conform to this protocol. It's their responsability to handle the prepareForSegue event comming from a storyboard, or pass it further up to the application coordinator.
/// Optionnaly, the coordinator can implement the shouldPerformSegue if it wants to prevent the segue to be performed. If not implemented, default implementation returns true.
@objc protocol CoordinationDelegate: class {
    func prepareForSegue(segue: UIStoryboardSegue)
    @objc optional func shouldPerformSegue(with identifier: String) -> Bool
}

/// Every ViewController within the application should conform to this protocol as they will be coordinated by the Application Coordinator.
/// Their coordinationDelegate property must be set to their Coordinator as it will be in charge of responding to the prepare for segue event
protocol Coordinated: class {
    var coordinationDelegate: CoordinationDelegate? { get set }
    static var coordinationIdentifier: String { get }
    static var storyboardIdentifier: String? { get }
}
extension Coordinated {
    static var coordinationIdentifier: String { return NSStringFromClass(Self.self).split(".").last ?? "" } // localization check:disable:this
    static var storyboardIdentifier: String? { return nil }
}

extension UIViewController {
    
    class func addCoordination() {
        
        DispatchQueue.once(token: "addCoordination") { // localization check:disable:this
            let originalPerformSelector = #selector(UIViewController.prepare(for:sender:))
            let swizzledPerformSelector = #selector(swizzledPrepare(for:sender:))
            
            method_exchangeImplementations(class_getInstanceMethod(UIViewController.self, originalPerformSelector),
                                           class_getInstanceMethod(UIViewController.self, swizzledPerformSelector))
            
            let originalShouldPerformSelector = #selector(UIViewController.shouldPerformSegue(withIdentifier:sender:))
            let swizzledShouldPerformSelector = #selector(swizzledShouldPerform(withIdentifier:sender:))
            
            method_exchangeImplementations(class_getInstanceMethod(UIViewController.self, originalShouldPerformSelector),
                                           class_getInstanceMethod(UIViewController.self, swizzledShouldPerformSelector))
        }
    }
    
    func swizzledPrepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        defer {
            self.swizzledPrepare(for: segue, sender: self)
        }
        
        guard let sourceViewController = segue.source as? Coordinated else {
            return
        }
        
        sourceViewController.coordinationDelegate?.prepareForSegue(segue: segue)
        
    }
    
    func swizzledShouldPerform(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        defer {
            _ = self.swizzledShouldPerform(withIdentifier: identifier, sender: self)
        }
        
        guard let strongSelf = self as? Coordinated else {
            return true
        }
        
        return strongSelf.coordinationDelegate?.shouldPerformSegue?(with: identifier) ?? true
    }
}

public extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    public class func once(token: String, block: (Void) -> Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        block()
    }
}
