//
//  AppUser.swift
//  FourRent
//
//  Created by Yash Kanadhia on 2026-03-21.
//

import Foundation

struct AppUser: Identifiable, Codable {
    
    var id: String
    var email: String
    var role: UserRole
    
    var firstName: String
    var lastName: String
    var phone: String
    
    var shortlisted: [String] = []
}
