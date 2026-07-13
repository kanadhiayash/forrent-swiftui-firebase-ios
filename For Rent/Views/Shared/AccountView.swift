import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @EnvironmentObject private var feedbackCenter: FeedbackCenter

    @State private var confirmation: Confirmation?
    @State private var personalDetailsUser: AppUser?

    var body: some View {
        List {
            if let user = authVM.user {
                Section {
                    AccountIdentityHeader(user: user, isDemoMode: authVM.isDemoMode)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }

                Section("Personal Information") {
                    Button {
                        personalDetailsUser = user
                    } label: {
                        AccountNavigationRow(
                            icon: "person.text.rectangle",
                            title: "Personal details",
                            value: personalDetailsValue(for: user),
                            supportingText: nil
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("account.personalDetails")
                }

                Section("Account") {
                    AccountInformationRow(
                        icon: "envelope",
                        title: "Email",
                        value: user.email,
                        supportingText: authVM.isDemoMode
                            ? "Demo account. Managed by your sign-in account."
                            : "Managed by your sign-in account."
                    )
                    .accessibilityIdentifier("account.email")
                }

                Section("Market") {
                    NavigationLink {
                        MarketQualificationView()
                    } label: {
                        AccountNavigationRow(
                            icon: "checkmark.seal",
                            title: "Market qualification",
                            value: nil,
                            supportingText: "Track release evidence before owner review"
                        )
                    }
                    .accessibilityIdentifier("account.marketQualification")
                }
            }

            if authVM.isDemoMode {
                Section("Demo") {
                    Button {
                        confirmation = .resetDemo
                    } label: {
                        Label {
                            VStack(alignment: .leading, spacing: ForRentTheme.Spacing.xxs) {
                                Text("Reset demo data")
                                Text("Restore profiles, listings, saved homes, and requests")
                                    .font(ForRentTheme.Typography.supporting)
                                    .foregroundStyle(ForRentTheme.Colors.textSecondary)
                            }
                        } icon: {
                            Image(systemName: "arrow.counterclockwise")
                        }
                    }
                    .accessibilityIdentifier("account.resetDemo")
                }
            }

            Section("Session") {
                Button("Sign Out", role: .destructive) {
                    confirmation = .signOut
                }
                .accessibilityIdentifier("account.signOut")
            }
        }
        .scrollContentBackground(.hidden)
        .background(ForRentTheme.Colors.canvas)
        .navigationTitle("Account")
        .accessibilityIdentifier("account.screen")
        .fullScreenCover(item: $personalDetailsUser) { user in
            NavigationStack {
                PersonalDetailsView(user: user)
            }
        }
        .alert(
            confirmation?.title ?? "",
            isPresented: confirmationBinding,
            presenting: confirmation
        ) { value in
            switch value {
            case .resetDemo:
                Button("Cancel", role: .cancel) {}
                Button("Reset Demo", role: .destructive) {
                    resetDemo()
                }
                .accessibilityIdentifier("account.confirmReset")
            case .signOut:
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    authVM.logout()
                }
                .accessibilityIdentifier("account.confirmSignOut")
            }
        } message: { value in
            Text(value.message)
        }
    }

    private var confirmationBinding: Binding<Bool> {
        Binding {
            confirmation != nil
        } set: { isPresented in
            if !isPresented {
                confirmation = nil
            }
        }
    }

    private func personalDetailsValue(for user: AppUser) -> String {
        [user.displayName, user.formattedPhoneForDisplay]
            .compactMap { $0 }
            .joined(separator: " · ")
    }

    private func resetDemo() {
        authVM.resetDemo()
        authVM.successMessage = nil
        feedbackCenter.show(.success("Demo data restored."))
    }
}

private extension AccountView {
    enum Confirmation: String, Identifiable {
        case resetDemo
        case signOut

        var id: String { rawValue }

        var title: String {
            switch self {
            case .resetDemo: "Reset demo data?"
            case .signOut: "Sign out of For Rent?"
            }
        }

        var message: String {
            switch self {
            case .resetDemo:
                "This restores demo profiles, properties, saved homes, and requests to their starting state. You will stay signed in as the current demo role."
            case .signOut:
                ""
            }
        }
    }
}
