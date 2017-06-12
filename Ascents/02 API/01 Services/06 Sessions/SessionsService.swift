//
//  SessionsService.swift
//  Ascents
//
//  Created by Theophile on 25.01.17.
//  Copyright © 2017 Theophile. All rights reserved.
//

import Foundation
import KeychainAccess


public class SessionsService {

    /**
     Login to the app via account's email
     
     - parameter email:             account's email
     - parameter password:          password
     - parameter rememberMe:        rememberMe account's email than user have not to enter again in next time
     - parameter completionHandler: completion handler closure
     */
    public static func login(withEmail email: String, password: String, rememberMe: Bool = false, completionHandler: @escaping (_ error: APIError?) -> Void) {
		
        let loginEndpoint = SessionsEndpoint.login(email: email, password: password, rememberMe: rememberMe)
		
		Service.call(loginEndpoint) { (_, _, error) in
            
            completionHandler(error)
            
            if case .none = error {
                Keychain.main[.userEmail] = email
                AppSessionManager.shared.authenticationLevel = .levelTwo
            }
		}
	}

    /**
     Logout the app and back to login screen
     
     - parameter completionHandler: completion handler closure
     */
    public static func logout(completionHandler: @escaping (_ error: APIError?) -> Void) {

        let logoutEndpoint = SessionsEndpoint.logout

        Service.call(logoutEndpoint) { (_, _, error) in

            completionHandler(error)
            
            if case .none = error {
                AppSessionManager.shared.authenticationLevel = .none
            }
        }
    }
}
