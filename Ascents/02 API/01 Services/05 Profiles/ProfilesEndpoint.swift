//
//  ProfilesEndpoint.swift
//  Ascents
//
//  Created by Theophile on 19.05.17.
//  Copyright © 2017 Theophile. All rights reserved.
//

import Foundation
import Alamofire

// localization check:disable

public enum ProfilesEndpoint: Endpoint {
    
    case createProfile(birthDate: String, insuranceNumber: String)
    case getProfile(profileId: Int)
    
    public var category: ServiceCategory { return .profiles}
    
    public var description: String {
        switch self {
        case .createProfile: return "create profile"
        case .getProfile:    return "Get profile detail"
        }
    }

    public var path: String {
        switch self {
        case .createProfile: return "/v1/profiles"
        case .getProfile:    return "/v1/profiles/%@"
        }
    }

    public var requiredLevel: AuthenticationLevel {
        return .levelOne
    }

    public var method: HTTPMethod {
        switch self {
        case .createProfile: return .post
        case .getProfile:    return .get
        }
    }
    
    public var query: APIQuery {
        switch self {
        case .createProfile(let birthDate, let insuranceNumber):
            
            let params = ["birthDate": birthDate, "insuranceNumber": insuranceNumber]
            return APIQuery(path, bodyParameters: params)
            
        case .getProfile(let profileId):
            return APIQuery(path, pathParameters:[String(profileId)])
        }
    }
    
    public var baseHost: String {
        return Environment.host().baseHost
    }
    
    public var port: Int? {
        return Environment.host().port
    }
}
