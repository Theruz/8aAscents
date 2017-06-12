//
//  AppSessionManager.swift
//  Ascents
//
//  Created by Theophile on 22.05.17.
//  Copyright © 2017 Theophile. All rights reserved.
//

import Foundation
import KeychainAccess
import Alamofire

class AppSessionManager {
    
    fileprivate let backendTimeout = TimeInterval(29 * 60)
    fileprivate let applicationTimeout = TimeInterval(30 * 60)
    
    fileprivate var applicationInactivityTimer: Timer?
    fileprivate var backendInvactivityTimer: Timer?
    
    var authenticationLevel: AuthenticationLevel = .none
    var rememberMe: Bool { return Keychain.main[bool: .rememberMe] ?? false }
    
    static var shared = AppSessionManager()
    
    private init() {}
    
    /// Function that display a popup to let the user relogin within a screen
//    func attemptToLogin() {
//        
//        let loginAction: (String) -> Void = { password in
//            SessionsService.login(withEmail: Keychain.main[.userEmail] ?? "", password: password) { error in
//                if case .some = error {
//                    MGAlertView.show(LoginMessage.invalidPassword) { self.attemptToLogin() }
//                }
//            }
//        }
//        
//        if false { // using TouchID
//            
//        } else {
//            
//            let textFieldInfo = MGAlertView.TextFieldOptions (
//                placeholder: String.Login.password,
//                isSecure: true,
//                validationButtonTitle: String.Button.`continue`, validationTextRule: {!$0.isEmpty},
//                buttonAction: loginAction,
//                cancelAction: { self.logout(preserveInfo: true) })
//            
//            MGAlertView.show(GeneralMessage.sessionExpired(relog: true), with: textFieldInfo)
//        }
//    }
    
    /// Function that log the user out of the application and redirect him to the login screen 
    ///
    /// - Parameters:
    ///   - preserveInfo: If true, keeps the rememberMe and userEmail in the keychain. Default false
    ///   - redirectToLogin: If true, redirect to the login screen. Else stays on the same screen. Default true
    func logout(preserveInfo: Bool = false, redirectToLogin: Bool = true) {
        
        if authenticationLevel >= .levelOne {
            SessionsService.logout { _ in }
        }
        if !preserveInfo {
            Service.discardRememberMeCookie()
            Keychain.main[bool: .rememberMe] = nil
            Keychain.main[string: .userEmail] = nil
        }
        authenticationLevel = .none
        if redirectToLogin {
//            do {
                //LanguageViewModel.setPhoneLanguage()
                
                //TODO: trigger login redirection
                //try appCoordinator?.goToLogin()
//            } catch let error as CoordinationError {
//                //FIRCrashMessage(error.description)
//                Log.error(error.description)
//            } catch {
//                Log.error(error)
//            }
        }
    }
}


/// MARK: Inactivity timer management
extension AppSessionManager {
    
    /// Function to be called everytime the user make a touch on the screen to prevent the application to timeout
    func resetInactivityTimer() {
        applicationInactivityTimer?.invalidate()
        applicationInactivityTimer = Timer.scheduledTimer(timeInterval: applicationTimeout, target: self,
                                                          selector: #selector(applicationDidTimeout), userInfo: nil, repeats: false)
    }
    
    /// Function to be called everytime a call to the backend is made to prevent backend to timeout
    func resetBackendInactivityTimer() {
        backendInvactivityTimer?.invalidate()
        backendInvactivityTimer = Timer.scheduledTimer(timeInterval: backendTimeout, target: self,
                                                       selector: #selector(backendWillTimeout), userInfo: nil, repeats: false)
    }
    
    /// Called when the application timed out due to inactivity
    @objc func applicationDidTimeout() {
        
//        if case .levelTwo = authenticationLevel, rememberMe {
//            attemptToLogin()
//            
//        } else if authenticationLevel > .none, !rememberMe {
//            MGAlertView.show(GeneralMessage.sessionExpired(relog: false)) { self.logout(preserveInfo: true) }
//        }
    }
    
    /// Called when the backend is about to timeout. A keep alive is send to prevent the backend to timeout.
    @objc func backendWillTimeout() {
//        if .levelOne <= authenticationLevel { AccountsService.getAccount { _, _ in} }
    }
}
