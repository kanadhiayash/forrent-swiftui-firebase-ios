//
//  AuthService.swift
//  FourRent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import FirebaseAuth

class AuthService {
    
    static let shared = AuthService()
    
    func register(email: String, password: String) async throws -> User {
        try await Auth.auth().createUser(withEmail: email, password: password).user
    }
    
    func login(email: String, password: String) async throws -> User {
        try await Auth.auth().signIn(withEmail: email, password: password).user
    }
    
    func logout() throws {
        try Auth.auth().signOut()
    }
    
    func updatePassword(newPassword: String) async throws {
        try await Auth.auth().currentUser?.updatePassword(to: newPassword)
    }
}
