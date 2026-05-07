//
//  Enums.swift
//  FourRent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import Foundation

enum UserRole: String, Codable {
    case guest
    case tenant
    case landlord
}

enum AppError: LocalizedError {
    case emptyFields
    case invalidEmail
    case passwordMismatch
    case weakPassword
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .emptyFields:
            return "Please fill all fields."
        case .invalidEmail:
            return "Invalid email format."
        case .passwordMismatch:
            return "Passwords do not match."
        case .weakPassword:
            return "Password must be at least 6 characters."
        case .unknown:
            return "Something went wrong."
        }
    }
}
