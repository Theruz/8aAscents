//
//  AppMessage.swift
//  Ascents
//
//  Created by Theophile on 22.05.17.
//  Copyright © 2017 Theophile. All rights reserved.
//

import Foundation

// swiftlint:disable line_length

// TODO : remove this line and correct the messages once with will have all error messages
// localization check:disable

protocol AppMessage: Error {
    
    var info: (title: String, description: String) { get }
}

public enum GeneralMessage: AppMessage {
    case general
    case custom(title:String, message:String)
    
    var info: (title: String, description: String) {
        switch self {
        case .general: return ("Application Error", "An unexpected error has occurred")
        case .custom(let title, let message): return (title, message)
        }
    }
}
