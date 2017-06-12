//
//  Service.swift
//  Ascents
//
//  Created by Theophile on 25.01.17.
//  Copyright © 2017 Theophile. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import HTTPStatusCodes

// localization check:disable

public class Service: Alamofire.SessionDelegate {
    
    public typealias ResponseHeaders = [AnyHashable:Any]
    
    static fileprivate let networkQueue: OperationQueue = {
        $0.name = "Network queue"
        return $0
    } (OperationQueue())
    
    private static let shared = Service()
    
    private static var rememberMeCookie: HTTPCookie? {
        return Service.networkManager.session.configuration.httpCookieStorage?.cookies?.first(where: { $0.name == "remember-me"})
    }
    
    static var hasValidRememberMeCookie: Bool { return (rememberMeCookie?.expiresDate ?? Date()) > Date() }
    
    /// Responsible for creating and managing `Request` objects, as well as their underlying `NSURLSession`.
    static let networkManager: Alamofire.SessionManager = {
        
        var allowsArbitraryLoads: Bool = true
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
            let transportSecurity = NSDictionary(contentsOfFile: path)?["NSAppTransportSecurity"] as? [String : Any],
            let arbitraryLoads = transportSecurity["NSAllowsArbitraryLoads"] as? Bool {
            allowsArbitraryLoads = arbitraryLoads
        }
        
        var trustPolicyManager: ServerTrustPolicyManager?
        
        // If we have a certificate and the APS does not allows arbitrary loads, then we enable the certificate pinning using the trustPolicyManager
        if let certificateBundle = Environment.Certificates.bundle, !allowsArbitraryLoads {
            let serverTrustPolicies: [String: ServerTrustPolicy] = [
                Environment.host().baseHost: .pinPublicKeys(
                    publicKeys: ServerTrustPolicy.publicKeys(in: certificateBundle),
                    validateCertificateChain: true,
                    validateHost: true
                )
            ]
            trustPolicyManager = ServerTrustPolicyManager(policies: serverTrustPolicies)
        }
        
        let configuration = URLSessionConfiguration.`default`
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 30
        configuration.httpAdditionalHeaders = ["User-Agent": UIApplication.shared.userAgent]
        
        let manager = Alamofire.SessionManager(configuration: configuration, delegate: Service.shared, serverTrustPolicyManager:trustPolicyManager)
        
        manager.startRequestsImmediately = true
        
        return manager
    }()
    
    class NullObject: Mappable, Mockable {
        required init?(map: Map) {}
        required init() {}
        func mapping(map: Map) {}
        static func mock() -> Self {
            return self.init()
        }
    }
    
    static let requestDidCompleteNotification = Notification.Name("requestDidCompleteNotification")
    
    public static func discardRememberMeCookie() {
        guard let cookie = rememberMeCookie else { return }
        Service.networkManager.session.configuration.httpCookieStorage?.deleteCookie(cookie)
    }
    
    ///  Send a request to the server when we expect the server to return an object
    ///
    ///  - parameter request:           An object conform to the APIRequestConvertible protocol used to create the resquest
    ///  - parameter completionHandler: A closure called once the request finished executing
    public static func call <T: Mappable & Mockable>(_ request: Endpoint, completionHandler: @escaping (T?, _ headers: ResponseHeaders?, _ statusCode: HTTPStatusCode?, _ error: APIError?) -> Void) {
        
        // Testing if the call is not already in the operation queue
        guard !addObserverForRequestCompletion(request, completionHandler: completionHandler) else {return}
        
        let requestOperation = RequestOperation(apiCall: request) { (responseObject: T?, headers, statusCode, error) in
            completeCall(for: request, with: statusCode, error: error)
            completionHandler(responseObject, headers, statusCode, error)
        }
        networkQueue.addOperation(requestOperation)
    }
    
    ///  Send a request to the server when we expect the server to return an array of object
    ///
    ///  - parameter request:           An object conform to the APIRequestConvertible protocol used to create the resquest
    ///  - parameter completionHandler: A closure called once the request finished executing
    public static func call <T: Mappable & Mockable>(_ request: Endpoint, completionHandler: @escaping ([T]?, _ headers: ResponseHeaders?, _ statusCode: HTTPStatusCode?, _ error: APIError?) -> Void) {
        
        // Testing if the call is not already in the operation queue
        guard !addObserverForRequestCompletion(request, completionHandler: completionHandler) else {return}
        
        let requestOperation = RequestOperation(apiCall: request) { (responseObject: [T]?, headers, statusCode, error) in
            completeCall(for: request, with: statusCode, error: error)
            completionHandler(responseObject, headers, statusCode, error)
        }
        networkQueue.addOperation(requestOperation)
    }
    
    ///  Send a request to the server when we expect the server to return a JSON dictionnary
    ///
    ///  - parameter request:           An object conform to the APIRequestConvertible protocol used to create the resquest
    ///  - parameter completionHandler: A closure called once the request finished executing
    public static func call (_ request: Endpoint, completionHandler: @escaping (_ jsonDictionary: [String: Any]?, _ headers: ResponseHeaders?, _ statusCode: HTTPStatusCode?, _ error: APIError?) -> Void) {
        
        // Testing if the call is not already in the operation queue
        guard !addObserverForRequestCompletion(request, completionHandler: completionHandler) else {return}
        
        let requestOperation = RequestOperation(apiCall: request, returnedObject:NullObject()) { responseObject, headers, statusCode, error in
            completeCall(for: request, with: statusCode, error: error)
            completionHandler(responseObject, headers, statusCode, error)
        }
        networkQueue.addOperation(requestOperation)
    }
    
    ///  Send a request to the server when we do not expect the server to return any object
    ///
    ///  - parameter request:           An object conform to the APIRequestConvertible protocol used to create the resquest
    ///  - parameter completionHandler: A closure called once the request finished executing
    public static func call (_ request: Endpoint, completionHandler: @escaping (_ headers: ResponseHeaders?, _ statusCode: HTTPStatusCode?, _ error: APIError?) -> Void) {
        
        let completion: ((NullObject?, _ headers: ResponseHeaders?, _ statusCode: HTTPStatusCode?, _ error: APIError?) -> Void) = {
            object, headers, statusCode, error in
            completionHandler(headers, statusCode, error)
        }
        call(request, completionHandler: completion)
    }
    
    private static func addObserverForRequestCompletion<ReturnedObject>(_ request: Endpoint, completionHandler: @escaping (ReturnedObject?, _ headers: ResponseHeaders?, _ statusCode: HTTPStatusCode?, _ error: APIError?) -> Void) -> Bool {
        
        // Testing if the call is not already in the operation queue
        if let operation = networkQueue.operations
            .filter({ ($0 as? RequestOperation<NullObject>)?.endpoint.isEqualTo(request) ?? false })
            .first as? RequestOperation<NullObject> {
            
            _ = NotificationCenter.default.addObserver(forName: requestDidCompleteNotification, object: operation, queue: networkQueue) { notification in
                
                guard notification.object as? Operation == operation else { return }
                
                let value =  notification.userInfo?["value"] as? ReturnedObject
                let headers = notification.userInfo?["headers"] as? ResponseHeaders
                let statusCode = notification.userInfo?["statusCode"] as? HTTPStatusCode
                let error =  notification.userInfo?["error"] as? APIError
                
                completionHandler(value, headers, statusCode, error)
            }
            return true
            
        } else { return false }
    }
    
    private static func completeCall(for request: Endpoint, with statusCode: HTTPStatusCode?, error: Error?) {
        if request.requiredLevel == .levelOne { AppSessionManager.shared.resetBackendInactivityTimer() }
        
        switch statusCode {
        case .some(.unauthorized):
            if AppSessionManager.shared.authenticationLevel > .none { AppSessionManager.shared.logout(preserveInfo: true) }
        case .some(.forbidden): break // TODO: Need to do something for Forbidden ?
        default: break
        }
    }
}
