import SwiftUI

struct PersonalDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authVM: AuthViewModel
    @EnvironmentObject private var feedbackCenter: FeedbackCenter

    @State private var editor: ProfileEditor
    @State private var showsDiscardConfirmation = false
    @FocusState private var focusedField: Field?

    private let user: AppUser

    init(user: AppUser) {
        self.user = user
        _editor = State(initialValue: ProfileEditor(user: user))
    }

    var body: some View {
        @Bindable var editor = editor

        Form {
            if case let .failed(message) = editor.submissionState {
                submissionError(message)
            }

            Section("Name") {
                field(
                    title: "First name",
                    text: $editor.draft.firstName,
                    error: editor.errors.firstName,
                    field: .firstName,
                    errorIdentifier: "personalDetails.firstNameError"
                )
                .textContentType(.givenName)
                .textInputAutocapitalization(.words)
                .submitLabel(.next)
                .onSubmit { focusedField = .lastName }
                .accessibilityIdentifier("personalDetails.firstName")

                field(
                    title: "Last name",
                    text: $editor.draft.lastName,
                    error: editor.errors.lastName,
                    field: .lastName,
                    errorIdentifier: "personalDetails.lastNameError"
                )
                .textContentType(.familyName)
                .textInputAutocapitalization(.words)
                .submitLabel(.next)
                .onSubmit { focusedField = .phone }
                .accessibilityIdentifier("personalDetails.lastName")
            }

            Section {
                field(
                    title: "Phone number",
                    text: $editor.draft.phone,
                    error: editor.errors.phone,
                    field: .phone,
                    errorIdentifier: "personalDetails.phoneError"
                )
                .textContentType(.telephoneNumber)
                .keyboardType(.phonePad)
                .submitLabel(.done)
                .accessibilityIdentifier("personalDetails.phone")
            } header: {
                Text("Contact")
            } footer: {
                Text("Used for account and inquiry communication.")
            }

            Section {
                VStack(alignment: .leading, spacing: ForRentTheme.Spacing.xxs) {
                    Text("Email")
                        .font(ForRentTheme.Typography.caption)
                        .foregroundStyle(ForRentTheme.Colors.textSecondary)

                    Text(user.email)
                        .font(ForRentTheme.Typography.body)
                        .foregroundStyle(ForRentTheme.Colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Email, \(user.email), read only")
                .accessibilityIdentifier("personalDetails.email")
            } header: {
                Text("Account Email")
            } footer: {
                Text(emailSupportingText)
            }
        }
        .disabled(editor.isSaving)
        .scrollContentBackground(.hidden)
        .background(ForRentTheme.Colors.canvas)
        .navigationTitle("Personal Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    attemptDismiss()
                }
                .accessibilityIdentifier("personalDetails.cancel")
            }

            ToolbarItem(placement: .confirmationAction) {
                Button {
                    save()
                } label: {
                    if editor.isSaving {
                        ProgressView()
                            .controlSize(.small)
                            .accessibilityLabel("Saving")
                    } else {
                        Text("Save")
                    }
                }
                .disabled(!editor.canSave)
                .accessibilityIdentifier("personalDetails.save")
            }
        }
        .interactiveDismissDisabled(editor.hasChanges)
        .accessibilityIdentifier("personalDetails.screen")
        .alert("Discard changes?", isPresented: $showsDiscardConfirmation) {
            Button("Keep Editing", role: .cancel) {}
            Button("Discard Changes", role: .destructive) {
                dismiss()
            }
            .accessibilityIdentifier("personalDetails.discardConfirmation")
        } message: {
            Text("Your profile updates have not been saved.")
        }
    }

    private var emailSupportingText: String {
        if authVM.isDemoMode {
            "Email changes are not supported here. This is demo account data."
        } else {
            "Email changes are not supported here."
        }
    }

    private func field(
        title: String,
        text: Binding<String>,
        error: String?,
        field: Field,
        errorIdentifier: String
    ) -> some View {
        VStack(alignment: .leading, spacing: ForRentTheme.Spacing.xs) {
            Text(title)
                .font(ForRentTheme.Typography.caption)
                .foregroundStyle(ForRentTheme.Colors.textSecondary)

            TextField("", text: text)
                .focused($focusedField, equals: field)
                .accessibilityLabel(title)

            if let error {
                Label(error, systemImage: "exclamationmark.circle.fill")
                    .font(ForRentTheme.Typography.supporting)
                    .foregroundStyle(ForRentTheme.Colors.destructive)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isStaticText)
                    .accessibilityIdentifier(errorIdentifier)
            }
        }
    }

    private func submissionError(_ message: String) -> some View {
        Section {
            HStack(alignment: .top, spacing: ForRentTheme.Spacing.sm) {
                Image(systemName: "exclamationmark.octagon.fill")
                    .foregroundStyle(ForRentTheme.Colors.destructive)
                    .accessibilityHidden(true)

                Text(message)
                    .font(ForRentTheme.Typography.supporting)
                    .foregroundStyle(ForRentTheme.Colors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    editor.clearSubmissionError()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }
                .buttonStyle(.plain)
                .foregroundStyle(ForRentTheme.Colors.textSecondary)
                .accessibilityLabel("Dismiss save error")
            }
            .accessibilityElement(children: .contain)
        }
    }

    private func save() {
        guard editor.validate() else { return }

        editor.beginSaving()

        Task {
            do {
                let updatedUser = try await authVM.updateProfile(
                    firstName: editor.draft.firstName,
                    lastName: editor.draft.lastName,
                    phone: editor.draft.phone
                )
                editor.finishSaving(user: updatedUser)
                feedbackCenter.show(.success("Profile updated."))
                dismiss()
            } catch {
                editor.fail(error)
            }
        }
    }

    private func attemptDismiss() {
        if editor.hasChanges {
            showsDiscardConfirmation = true
        } else {
            dismiss()
        }
    }
}

private extension PersonalDetailsView {
    enum Field: Hashable {
        case firstName
        case lastName
        case phone
    }
}
