//
//  RequestConvertible.swift
//  Ascents
//
//  Created by Theophile on 25.01.17.
//  Copyright © 2017 Theophile. All rights reserved.
//

import Foundation
import Alamofire

// localization check:disable

extension UIDevice {
    
    var deviceName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        return identifier
    }
}

extension UIApplication {
    
    var userAgent: String {
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] ?? "?"
        let appCode    = Bundle.main.infoDictionary!["CFBundleVersion"] ?? "?"
        return
            "iOS: (version: \(UIDevice.current.systemVersion)) | " +
            "App: (version: \(appVersion) - " + "code: \(appCode)) | " +
            "Device: (model: \(UIDevice.current.deviceName))"
    }
}

public enum AuthenticationLevel: Int, Comparable {
    case none = 0
    case levelOne
    case levelTwo
    
    public static func < (lhs: AuthenticationLevel, rhs: AuthenticationLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}


/// The protocol for handling authentication level
///
public protocol Endpoint: CustomStringConvertible {
    
    var category: ServiceCategory {get}
    var path: String { get }
    var query: APIQuery { get }
    var requiredLevel: AuthenticationLevel { get }
    var method: Alamofire.HTTPMethod { get }
    var baseHost: String { get }
    var port: Int? { get }
}

extension Endpoint {
    var requiredLevel: AuthenticationLevel {return .none}
}

extension Endpoint {
    
    ///  This function work as the same as the == operator. It will returns true if two APIRequestConvertible are equivalent
    ///
    ///  - parameter otherRequest: The other request convertible to test the equality
    ///
    ///  - returns: True if otherRequest is equivalent to the receiver
    public func isEqualTo(_ otherRequest: Endpoint) -> Bool {
        
        let endpointsAreEqual      = self.path == otherRequest.path
        let queriesAreEqual        = self.query == otherRequest.query
        let requiredLevelsAreEqual = self.requiredLevel == otherRequest.requiredLevel
        let methodsAreEqual        = self.method == otherRequest.method
        let baseHostsAreEqual      = self.baseHost == otherRequest.baseHost
        
        return endpointsAreEqual && queriesAreEqual && requiredLevelsAreEqual && methodsAreEqual && baseHostsAreEqual
    }
}


/// A type representing the path for a query
public struct APIQuery {
    
    fileprivate var internalPath: String
    var path: String {
        get {
            var path = self.internalPath
            if path.characters.first != "/" { path = "/" + path }
            
            if let pathParameters = pathParameters, pathParameters.count > 0 {
                return String(format: path, arguments: pathParameters)
                
            } else { return path }
        }
        set {
            self.internalPath = path
        }
    }
    let urlParameters: [String : String]?
    let bodyParameters: Alamofire.Parameters?
    let pathParameters: [String]?
    let headerParameters: HTTPHeaders?
    let encoding: Alamofire.ParameterEncoding
    let attachedImages: [UIImage]?
    
    init(_ path: String, bodyParameters: Alamofire.Parameters? = nil, urlParameters: [String : String]? = nil,
         pathParameters: [String]? = nil, headerParameters: HTTPHeaders? = nil,
         encoding: Alamofire.ParameterEncoding = JSONEncoding.default, attachedImages: [UIImage]? = nil) {
        self.internalPath     = path
        self.urlParameters    = urlParameters
        self.bodyParameters   = bodyParameters
        self.pathParameters   = pathParameters
        self.headerParameters = headerParameters
        self.encoding         = encoding
        self.attachedImages   = attachedImages
    }
}


extension APIQuery : Equatable {
    
    static public func == (lhs: APIQuery, rhs: APIQuery) -> Bool {
        
        let pathAreEqual = lhs.path == rhs.path
        
        let pathParametersAreEqual = lhs.pathParameters == rhs.pathParameters
        
        let urlParametersAreEqual = lhs.urlParameters == rhs.urlParameters
        
        let bodyParametersAreEqual = lhs.bodyParameters == rhs.bodyParameters
        
        let headerParametersAreEqual = lhs.headerParameters == rhs.headerParameters
        
        return pathAreEqual && pathParametersAreEqual && urlParametersAreEqual && bodyParametersAreEqual && headerParametersAreEqual
    }
}

public func == (lhs: Alamofire.Parameters?, rhs: Alamofire.Parameters?) -> Bool {
    
    var bodyParametersAreEqual = true
    
    if case .none = lhs, case .none = rhs { return true }
    guard let lhs = lhs, let rhs = rhs else { return false }
    
    for lhsParameter in lhs {
        
        if !bodyParametersAreEqual { break }
        
        guard let rhsvalue = rhs[lhsParameter.key] else {
            bodyParametersAreEqual = false
            break
        }
        
        let lhsQuery = URLEncoding.httpBody.queryComponents(fromKey: lhsParameter.key, value: lhsParameter.value)
        let rhsQuery = URLEncoding.httpBody.queryComponents(fromKey: lhsParameter.key, value: rhsvalue)
        
        guard lhsQuery.count == rhsQuery.count else {
            bodyParametersAreEqual = false
            break
        }
        
        for (index, element) in lhsQuery.enumerated() where element != rhsQuery[index] {
            bodyParametersAreEqual = false
            break
        }
    }
    
    return bodyParametersAreEqual
}

public func == <Object: Equatable> (lhs: [Object]?, rhs: [Object]?) -> Bool {
    
    switch (lhs, rhs) {
    case (.some(let lhs), .some(let rhs)) : return lhs == rhs
    case (.none, .none): return true
    default : return false
    }
}
