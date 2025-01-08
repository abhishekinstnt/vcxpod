//
//  Error+.swift
//  InstntSDK
//
//  Created by Nate Eckerson on 5/25/21.
//

import Foundation

enum InputError: Error {
    case empty
    case invalidEmail
}

extension InputError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .empty:
            return "Please fill out this field"
        case .invalidEmail:
            return "Please fill out with valid email"
        }
    }
}
