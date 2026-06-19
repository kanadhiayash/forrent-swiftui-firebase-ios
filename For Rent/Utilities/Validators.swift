//
//  Validators.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import Foundation

struct Validators {
    
    static func validateSignup(
        email: String,
        password: String,
        confirmPassword: String,
        firstName: String,
        lastName: String
    ) throws {
        
        guard !email.isEmpty,
              !password.isEmpty,
              !confirmPassword.isEmpty,
              !firstName.isEmpty,
              !lastName.isEmpty else {
            throw AppError.emptyFields
        }
        
        guard email.contains("@") else {
            throw AppError.invalidEmail
        }
        
        guard password.count >= 6 else {
            throw AppError.weakPassword
        }
        
        guard password == confirmPassword else {
            throw AppError.passwordMismatch
        }
    }
}
