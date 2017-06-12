//
//  Profile.swift
//  Ascents
//
//  Created by Theophile on 24.04.17.
//  Copyright © 2017 Theophile. All rights reserved.
//

import Foundation
import ObjectMapper
import RandomKit
import String_Extensions

// localization check:disable

public class Profile: Mappable, Mockable {
    
    var id: Int?
    var firstName: String?
    var lastName: String?
    var birthDate: Date?
    var address: String?
    var main: Bool?
    
    var nickname: String { return firstName?[0...1] ?? "" }
    
    public required init?(map: Map) {}
    public required init() {}
    
    open func mapping(map: Map) {
        id <- map["id"]
        firstName <- map["firstName"]
        lastName <- map["lastName"]
        birthDate <- (map["birthDate"], DateFormatter())
        address <- map["address"]
        main <- map["main"]
    }
    
    public static func mock() -> Self {
        
        let mock = self.init()
        
        //Initialize mock
        
        return mock
    }
}
