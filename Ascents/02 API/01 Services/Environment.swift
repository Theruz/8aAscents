//
//  Environment.swift
//  Ascents
//
//  Created by Theophile on 25.01.17.
//  Copyright © 2017 Theophile. All rights reserved.
//

import Foundation

// localization check:disable

public enum ServiceCategory {
    case configTool, accounts, appointments, attachments, notifications, profiles, sessions
}


/**
*  The Environment structure wrap all the different configuration parameters that are dependent of the server chosen
*/

public struct Environment {

    /**
    The different type of scheme that are used for build
    - STUBS:           The scheme pointing to the stubs server
    - PROD:            The scheme pointing to the production server
    */

    public enum Server {
        case mock, development, integration, uat, production
    }

    public static var server: Server {
        #if Mock
                return .mock
        #elseif Development
                return .development
        #elseif Integration
                return .integration
        #elseif UAT
                return .uat
        #elseif Production
                return .production
        #else
                return .development
        #endif
    }

    public static func urlScheme(_ serviceCategory: ServiceCategory? = nil) -> String? {
        switch (Environment.server, serviceCategory) {
        case (.mock, _): return nil
        case (.development, .some(.configTool)):
            return "https"
        case (.development, _):
            return "http"
        default: return "https"
        }
    }

    /**
    This function can be use to get the server host for a chosen build configuration and the port corresponding to a category

     - parameter endpointCategory: (Optional) When pointing to the stubs server, this parameter will add the right port for the chosen EndpointCategory
     
     - returns: A tuple containing a string for the host for the server and eventually a number for the port
     */
    public static func host(_ serviceCategory: ServiceCategory? = nil) -> (baseHost: String, port: Int?) {
        
        var port: Int?
        var host: String = ""
        
        if case .development = Environment.server {
            port = 8080
        }
        
        switch (Environment.server, serviceCategory) {
        case (.mock, _):
            host = ""
        case (.development, .some(.configTool)):
            host = "config-int.Toto.ch"
        case (.development, _):
            host = "193.246.34.72"
        case (.integration, .some(.configTool)):
            host = "config-int.Toto.ch"
        case (.integration, _):
            host = "backend-int.Toto.ch"
        case (.uat, .some(.configTool)):
            host = "config-test.Toto.ch"
        case (.uat, _):
            host = "backend-test.Toto.ch"
        case (.production, .some(.configTool)):
            host = ""
        case (.production, _):
            host = ""
        }
        
        return (host, port)
    }
    
    
    /**
    *  The Certificates structure wrap the information used for the certificates like the certificate bundle
    */

    public struct Certificates {

        fileprivate static var bundleName: String? {
            switch Environment.server {
            case .mock: return nil
            case .development: return nil
            case .integration: return "int_certificate"
            case .uat: return "uat_certificate"
            case .production: return "prod_certificate"
            }
        }

        /// The NSBundle that hold the certificate for the current build configuration
        public static var bundle: Foundation.Bundle? {

            let mainBundle = Foundation.Bundle.main

            if let bundleName = Certificates.bundleName {

                if let certBundlePath = mainBundle.path(forResource: bundleName, ofType: "bundle"),
                    let bundle = Foundation.Bundle(path: certBundlePath) {

                    return bundle

                } else {

                    fatalError("Could not load certificates")
                }
            } else { return nil }
        }
    }
}
