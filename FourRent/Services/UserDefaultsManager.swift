//
//  UserDefaultsManager.swift
//  FourRent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import Foundation

class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    
    private let userKey = "loggedInUser"
    
    // MARK: SAVE USER
    
    func saveUser(_ user: AppUser) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: userKey)
        }
    }
    
    // MARK: FETCH USER
    
    func getUser() -> AppUser? {
        guard let data = UserDefaults.standard.data(forKey: userKey),
              let user = try? JSONDecoder().decode(AppUser.self, from: data)
        else {
            return nil
        }
        
        return user
    }
    
    // MARK: CLEAR USER
    
    func clearUser() {
        UserDefaults.standard.removeObject(forKey: userKey)
    }
}
