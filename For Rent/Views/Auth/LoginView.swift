//
//  LoginView.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ForRentTheme.Spacing.lg) {
                    VStack(spacing: ForRentTheme.Spacing.sm) {
                        Image(systemName: "building.2.crop.circle.fill")
                            .font(.system(size: 52))
                            .foregroundStyle(ForRentTheme.Colors.yellow)

                        Text("For Rent")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)

                        Text("Find a place that fits your life.")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.86))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 42)
                    .padding(.horizontal, ForRentTheme.Spacing.lg)
                    .background(ForRentTheme.Colors.primary)

                    if authVM.isDemoMode {
                        demoChooser
                    } else {
                        firebaseLogin
                    }
                }
                .padding(.bottom, ForRentTheme.Spacing.xl)
            }
            .background(ForRentTheme.Colors.canvas)
            .overlay {
                if let error = authVM.errorMessage {
                    ErrorView(
                        message: error,
                        dismissAction: {
                            authVM.errorMessage = nil
                        }
                    )
                }
            }
            .overlay {
                if authVM.isLoading {
                    LoadingView()
                }
            }
        }
    }

    private var demoChooser: some View {
        VStack(alignment: .leading, spacing: ForRentTheme.Spacing.md) {
            Text("Explore the demo")
                .font(.title2.bold())

            Text("Choose a role. All changes stay on this device and reset when the app relaunches.")
                .font(.body)
                .foregroundStyle(ForRentTheme.Colors.body)

            ForEach(authVM.demoUsers) { demoUser in
                Button {
                    authVM.selectDemoUser(id: demoUser.id)
                } label: {
                    HStack(spacing: ForRentTheme.Spacing.md) {
                        Image(systemName: icon(for: demoUser.role))
                            .font(.title2)
                            .foregroundStyle(ForRentTheme.Colors.action)
                            .frame(width: 36)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(displayName(for: demoUser))
                                .font(.headline)
                                .foregroundStyle(ForRentTheme.Colors.ink)

                            Text(roleDescription(for: demoUser.role))
                                .font(.subheadline)
                                .foregroundStyle(ForRentTheme.Colors.body)
                        }

                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(ForRentTheme.Colors.muted)
                    }
                    .padding(ForRentTheme.Spacing.md)
                    .background(ForRentTheme.Colors.canvas)
                    .overlay(
                        RoundedRectangle(cornerRadius: ForRentTheme.Radius.control)
                            .stroke(ForRentTheme.Colors.hairline, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(displayName(for: demoUser))
                .accessibilityHint("Opens the \(demoUser.role.rawValue) demo")
            }
        }
        .padding(.horizontal, ForRentTheme.Spacing.md)
    }

    private var firebaseLogin: some View {
        VStack(spacing: ForRentTheme.Spacing.md) {
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .keyboardType(.emailAddress)
                .padding()
                .background(ForRentTheme.Colors.surfaceSoft)
                .clipShape(RoundedRectangle(cornerRadius: ForRentTheme.Radius.control))

            SecureField("Password", text: $password)
                .textContentType(.password)
                .padding()
                .background(ForRentTheme.Colors.surfaceSoft)
                .clipShape(RoundedRectangle(cornerRadius: ForRentTheme.Radius.control))

            Button("Log in") {
                Task {
                    await authVM.login(email: email, password: password)
                }
            }
            .primaryButtonStyle()
            .disabled(authVM.isLoading)

            NavigationLink("Create an account") {
                SignUpView()
            }
            .font(.headline)

            Button("Browse as guest") {
                authVM.continueAsGuest()
            }
            .foregroundStyle(ForRentTheme.Colors.link)
            .accessibilityHint("Browse available properties without an account.")
        }
        .padding(.horizontal, ForRentTheme.Spacing.md)
    }

    private func displayName(for user: AppUser) -> String {
        user.role == .guest
            ? "Browse as guest"
            : "\(user.firstName) \(user.lastName)"
    }

    private func icon(for role: UserRole) -> String {
        switch role {
        case .guest: "eye"
        case .tenant: "magnifyingglass"
        case .landlord: "building.2"
        }
    }

    private func roleDescription(for role: UserRole) -> String {
        switch role {
        case .guest: "Explore public rental listings"
        case .tenant: "Save homes and send inquiries"
        case .landlord: "Manage listings and renter inquiries"
        }
    }
}
