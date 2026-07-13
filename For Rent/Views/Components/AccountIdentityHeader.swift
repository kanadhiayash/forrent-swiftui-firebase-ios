import SwiftUI

struct AccountIdentityHeader: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let user: AppUser
    let isDemoMode: Bool

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: ForRentTheme.Spacing.md) {
                    avatar
                    identity
                }
            } else {
                HStack(spacing: ForRentTheme.Spacing.md) {
                    avatar
                    identity
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(ForRentTheme.Spacing.md)
        .background(ForRentTheme.Colors.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: ForRentTheme.Radius.card))
        .overlay {
            RoundedRectangle(cornerRadius: ForRentTheme.Radius.card)
                .stroke(ForRentTheme.Colors.border, lineWidth: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySummary)
        .accessibilityIdentifier("account.identity")
    }

    private var avatar: some View {
        Text(user.initials)
            .font(.title3.weight(.bold))
            .foregroundStyle(ForRentTheme.Brand.white)
            .frame(width: 60, height: 60)
            .background(ForRentTheme.Brand.royalBlue, in: Circle())
            .accessibilityHidden(true)
    }

    private var identity: some View {
        VStack(alignment: .leading, spacing: ForRentTheme.Spacing.xxs) {
            Text(user.displayName)
                .font(ForRentTheme.Typography.rowTitle)
                .foregroundStyle(ForRentTheme.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: ForRentTheme.Spacing.xs) {
                Text(user.roleDisplayName)

                if isDemoMode {
                    Text("Demo account")
                        .font(ForRentTheme.Typography.caption.weight(.semibold))
                        .padding(.horizontal, ForRentTheme.Spacing.xs)
                        .padding(.vertical, ForRentTheme.Spacing.xxs)
                        .background(ForRentTheme.Colors.surfaceSelected, in: Capsule())
                }
            }
            .font(ForRentTheme.Typography.supporting)
            .foregroundStyle(ForRentTheme.Colors.textSecondary)

            Text(user.email)
                .font(ForRentTheme.Typography.supporting)
                .foregroundStyle(ForRentTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel("Email, \(user.email)")
        }
    }

    private var accessibilitySummary: String {
        [
            user.displayName,
            user.roleDisplayName,
            isDemoMode ? "Demo account" : nil,
            user.email
        ]
        .compactMap { $0 }
        .joined(separator: ", ")
    }
}
