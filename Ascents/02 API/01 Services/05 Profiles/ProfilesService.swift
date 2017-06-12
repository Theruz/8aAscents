//
//  ProfilesService.swift
//  Ascents
//
//  Created by Theophile on 19.05.17.
//  Copyright © 2017 Theophile. All rights reserved.
//

import Foundation
import UIKit


public class ProfilesService {
    
    /**
     create a new profile for an account
     
     - parameter birthDate:         profile's birth date
     - parameter insuranceNumber:   insurance's card number
     - parameter completionHandler: completion handling closure
     */
    public static func createProfile(withBirthDate birthDate: String, insuranceNumber: String, completionHandler: @escaping (_ error: APIError?) -> Void) {
        
        let createProfileEndpoint = ProfilesEndpoint.createProfile(birthDate: birthDate, insuranceNumber: insuranceNumber)
        
        Service.call(createProfileEndpoint) { (_, _, error) in
            completionHandler(error)
        }
    }
    
    /**
     get a profile info
     
     - parameter profileId:         profile's Id
     - parameter completionHandler: completion handler closure
     */
    public static func getProfile(withProfileId profileId: Int, completionHandler: @escaping ( _ profile: Profile?, _ error: APIError?) -> Void) {
        
        let getProfileEndpoint = ProfilesEndpoint.getProfile(profileId: profileId)
        
        Service.call(getProfileEndpoint) { (profile, _, _, error) in
            completionHandler(profile, error)
        }
    }
}
