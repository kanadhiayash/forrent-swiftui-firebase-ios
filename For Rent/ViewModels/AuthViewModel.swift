//
//  AuthViewModel.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

//
//  AuthViewModel.swift
//  For Rent
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    
    @Published var user: AppUser? = nil
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var isLoading = false
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    var isAuthenticated: Bool {
        user != nil
    }
    
    var userRole: UserRole {
        user?.role ?? .guest
    }
    
    init() {
        observeAuthState()
    }
    
    deinit {
        if let authStateHandle {
            Auth.auth().removeStateDidChangeListener(authStateHandle)
        }
    }
    
    private func observeAuthState() {
        isLoading = true
        
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            Task { @MainActor in
                guard let self else { return }
                
                guard let firebaseUser else {
                    self.user = nil
                    self.isLoading = false
                    return
                }
                
                do {
                    self.user = try await FirestoreService.shared.fetchUser(uid: firebaseUser.uid)
                } catch {
                    self.user = nil
                    self.errorMessage = "Unable to load your For Rent profile. \(error.localizedDescription)"
                }
                
                self.isLoading = false
            }
        }
    }
    
    // MARK: Guest
    func continueAsGuest() {
        errorMessage = nil
        user = AppUser(
            id: UUID().uuidString,
            email: "",
            role: .guest,
            firstName: "Guest",
            lastName: "",
            phone: "",
            shortlisted: []
        )
    }
    
    // MARK: Register
    func register(
        email: String,
        password: String,
        confirmPassword: String,
        firstName: String,
        lastName: String,
        phone: String,
        role: UserRole
    ) async {
        
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanLastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            try Validators.validateSignup(
                email: normalizedEmail,
                password: password,
                confirmPassword: confirmPassword,
                firstName: cleanFirstName,
                lastName: cleanLastName
            )
        } catch {
            errorMessage = error.localizedDescription
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let firebaseUser = try await AuthService.shared.register(
                email: normalizedEmail,
                password: password
            )
            
            let newUser = AppUser(
                id: firebaseUser.uid,
                email: normalizedEmail,
                role: role,
                firstName: cleanFirstName,
                lastName: cleanLastName,
                phone: cleanPhone,
                shortlisted: []
            )
            
            do {
                try await FirestoreService.shared.createUser(newUser)
            } catch {
                try? await firebaseUser.delete()
                try? AuthService.shared.logout()
                throw error
            }
            
            user = newUser
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: Login
    func login(email: String, password: String) async {
        
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        guard normalizedEmail.isValidEmail, !password.isEmpty else {
            errorMessage = "Enter a valid email and password."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let firebaseUser = try await AuthService.shared.login(
                email: normalizedEmail,
                password: password
            )
            
            let fetchedUser = try await FirestoreService.shared.fetchUser(uid: firebaseUser.uid)
            
            user = fetchedUser
            
        } catch {
            errorMessage = error.localizedDescription
            user = nil
        }
        
        isLoading = false
    }
    
    // MARK: Update Profile
    func updateProfile(firstName: String, lastName: String, phone: String) async {
        guard var currentUser = user else { return }
        
        let cleanFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanLastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanFirstName.isEmpty, !cleanLastName.isEmpty else {
            errorMessage = "First and last name are required."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        currentUser.firstName = cleanFirstName
        currentUser.lastName = cleanLastName
        currentUser.phone = cleanPhone
        
        do {
            try await FirestoreService.shared.updateProfile(
                userId: currentUser.id,
                firstName: cleanFirstName,
                lastName: cleanLastName,
                phone: cleanPhone
            )
            user = currentUser
            successMessage = "Profile updated."
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: Logout
    func logout() {
        do {
            try AuthService.shared.logout()
            user = nil
            errorMessage = nil
        } catch {
            errorMessage = "Unable to sign out. \(error.localizedDescription)"
        }
    }
}
