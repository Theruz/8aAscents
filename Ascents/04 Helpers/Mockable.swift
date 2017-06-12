//
//  Mockable.swift
//  Ascents
//
//  Created by Theophile on 25.04.17.
//  Copyright © 2017 Theophile. All rights reserved.
//

import Foundation

public protocol Mockable {
    
    init()
    static func mock() -> Self
}
