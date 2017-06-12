//
//  KeychainHelpers.swift
//  Ascents
//
//  Created by Theophile on 08.05.17.
//  Copyright © 2017 Theophile. All rights reserved.
//

import Foundation
import KeychainAccess

// localization check:disable

extension Keychain {
    
    public enum Key: String {
        case userEmail
        case rememberMe
        case deviceUUID
    }
    
    private static var mainKeychainIdentifier = "Bundle.main.bundleIdentifier"
    
    public static var main  = Keychain(service: Keychain.mainKeychainIdentifier)
    
    public subscript(key: Key) -> String? {
        get {
        return self[key.rawValue]
        } set {
            self[key.rawValue] = newValue
        }
    }
    public subscript(string key: Key) -> String? {
        get {
            return self[key.rawValue]
        } set {
            self[key.rawValue] = newValue
        }
    }
    public subscript(key: Key) -> Data? {
        get {
            return self[data: key.rawValue]
        } set {
            self[data: key.rawValue] = newValue
        }
    }
    public subscript(attributes key: Key) -> Attributes? {
        get {
            return self[attributes: key.rawValue]
        }
    }
    public subscript(key: Key) -> Bool? {
        get {
            switch self[key.rawValue] {
            case .some("YES"): return true
            case .some("NO"): return false
            default: return nil
            }
        } set {
            switch newValue {
            case .some(true): self[key.rawValue] = "YES"
            case .some(false): self[key.rawValue] = "NO"
            case .none: do { try remove(key.rawValue) } catch {}
            }
        }
    }
    public subscript(bool key: Key) -> Bool? {
        get {
            return self[key]
        } set {
            self[key] = newValue
        }
    }
}
