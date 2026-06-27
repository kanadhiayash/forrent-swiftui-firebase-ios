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
    private let environment: AppEnvironment
    
    @Published var user: AppUser? = nil
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var isLoading = false
    @Published var pendingProtectedProperty: Property?
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var isHandlingAuthMutation = false
    
    var isAuthenticated: Bool {
        user != nil
    }
    
    var userRole: UserRole {
        user?.role ?? .guest
    }
    
    var isDemoMode: Bool {
        environment.isDemo
    }

    var demoUsers: [AppUser] {
        environment.demoSession?.demoUsers ?? []
    }

    init(environment: AppEnvironment? = nil) {
        let resolvedEnvironment = environment ?? .firebase
        self.environment = resolvedEnvironment

        guard resolvedEnvironment.isFirebase else { return }
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

                guard !self.isHandlingAuthMutation else { return }
                
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

        if let demoSession = environment.demoSession {
            user = demoSession.continueAsGuest()
            return
        }

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

    func selectDemoUser(id: String) {
        guard let demoSession = environment.demoSession else { return }

        errorMessage = nil
        user = demoSession.selectUser(id: id)
    }

    func requireAuthentication(for property: Property) {
        pendingProtectedProperty = property
        logout()
    }

    func resetDemo() {
        guard let demoSession = environment.demoSession else { return }

        demoSession.reset()
        user = demoSession.currentUser
        errorMessage = nil
        successMessage = "Demo reset."
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
        guard environment.isFirebase else {
            errorMessage = "Demo mode is active. Choose a demo account to continue."
            return
        }
        
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
        isHandlingAuthMutation = true
        
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
            successMessage = "Account created."
            
        } catch {
            errorMessage = authErrorMessage(for: error)
        }
        
        isHandlingAuthMutation = false
        isLoading = false
    }
    
    // MARK: Login
    func login(email: String, password: String) async {
        guard environment.isFirebase else {
            errorMessage = "Demo mode is active. Choose a demo account to continue."
            return
        }
        
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        guard normalizedEmail.isValidEmail, !password.isEmpty else {
            errorMessage = "Enter a valid email and password."
            return
        }
        
        isLoading = true
        errorMessage = nil
        isHandlingAuthMutation = true
        
        do {
            let firebaseUser = try await AuthService.shared.login(
                email: normalizedEmail,
                password: password
            )
            
            let fetchedUser = try await FirestoreService.shared.fetchUser(uid: firebaseUser.uid)
            
            user = fetchedUser
            
        } catch {
            try? AuthService.shared.logout()
            errorMessage = authErrorMessage(for: error)
            user = nil
        }
        
        isHandlingAuthMutation = false
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

        if let demoSession = environment.demoSession {
            currentUser.firstName = cleanFirstName
            currentUser.lastName = cleanLastName
            currentUser.phone = cleanPhone

            user = demoSession.updateProfile(
                userId: currentUser.id,
                firstName: cleanFirstName,
                lastName: cleanLastName,
                phone: cleanPhone
            )
            successMessage = "Profile updated."
            errorMessage = nil
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
        if let demoSession = environment.demoSession {
            demoSession.clearSelectedUser()
            user = nil
            errorMessage = nil
            successMessage = nil
            return
        }

        do {
            try AuthService.shared.logout()
            user = nil
            errorMessage = nil
        } catch {
            errorMessage = "Unable to sign out. \(error.localizedDescription)"
        }
    }

    private func authErrorMessage(for error: Error) -> String {
        let nsError = error as NSError

        guard nsError.domain == AuthErrorDomain,
              let authCode = AuthErrorCode(rawValue: nsError.code) else {
            return error.localizedDescription
        }

        switch authCode {
        case .emailAlreadyInUse:
            return "An account already exists for this email."
        case .invalidCredential, .wrongPassword, .userNotFound:
            return "The email or password is incorrect."
        case .weakPassword:
            return "Use a password with at least 6 characters."
        case .invalidEmail:
            return "Enter a valid email address."
        case .operationNotAllowed:
            return "Email/password sign-in is not enabled for this Firebase project."
        case .networkError:
            return "Unable to reach Firebase. Check your internet connection and try again."
        case .tooManyRequests:
            return "Too many attempts. Wait a moment and try again."
        case .userDisabled:
            return "This account has been disabled."
        default:
            return error.localizedDescription
        }
    }
}
