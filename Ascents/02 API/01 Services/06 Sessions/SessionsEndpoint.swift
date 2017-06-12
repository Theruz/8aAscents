//
//  SessionsEndpoint.swift
//  Ascents
//
//  Created by Theophile on 25.01.17.
//  Copyright © 2017 Theophile. All rights reserved.
//

import Foundation
import Alamofire

// localization check:disable

public enum SessionsEndpoint: Endpoint {

    case login(email: String, password: String, rememberMe: Bool)
    case logout
    
    public var category: ServiceCategory { return .sessions}
    
    public var description: String {
        switch self {
        case .login:        return "login with email and password"
        case .logout:       return "logout current user"
        }
    }

    public var path: String {
        switch self {
        case .login:        return "v1/sessions/login"
        case .logout:       return "v1/session/logout"
        }
    }

    public var requiredLevel: AuthenticationLevel {
        switch self {
        case .login:        return .none
        case .logout:       return .levelOne
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .login:        return .post
        case .logout:       return .post
        }
    }
    
    public var query: APIQuery {
        switch self {
        case .login(let email, let password, let rememberMe):
            return APIQuery(path, bodyParameters: ["email": email, "password": password, "rememberMe": rememberMe], encoding: URLEncoding.default)
            
        case .logout:
            return APIQuery(path)
        }
    }
    
    public var baseHost: String {
        return Environment.host().baseHost
    }

    public var port: Int? {
        return Environment.host().port
    }
}
