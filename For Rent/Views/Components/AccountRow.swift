import SwiftUI

struct AccountNavigationRow: View {
    let icon: String
    let title: String
    let value: String?
    let supportingText: String?

    var body: some View {
        HStack(spacing: ForRentTheme.Spacing.sm) {
            accountIcon

            VStack(alignment: .leading, spacing: ForRentTheme.Spacing.xxs) {
                Text(title)
                    .font(ForRentTheme.Typography.rowTitle)
                    .foregroundStyle(ForRentTheme.Colors.textPrimary)

                if let supportingText {
                    Text(supportingText)
                        .font(ForRentTheme.Typography.supporting)
                        .foregroundStyle(ForRentTheme.Colors.textSecondary)
                }
            }

            Spacer(minLength: ForRentTheme.Spacing.xs)

            if let value {
                Text(value)
                    .font(ForRentTheme.Typography.supporting)
                    .foregroundStyle(ForRentTheme.Colors.textSecondary)
                    .multilineTextAlignment(.trailing)
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(ForRentTheme.Colors.textMuted)
                .accessibilityHidden(true)
        }
        .frame(minHeight: ForRentTheme.Control.minimumTarget)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySummary)
        .accessibilityAddTraits(.isButton)
    }

    private var accountIcon: some View {
        Image(systemName: icon)
            .foregroundStyle(ForRentTheme.Brand.royalBlue)
            .frame(width: 24)
            .accessibilityHidden(true)
    }

    private var accessibilitySummary: String {
        [title, value, supportingText]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}

struct AccountInformationRow: View {
    let icon: String
    let title: String
    let value: String
    let supportingText: String?

    var body: some View {
        HStack(alignment: .top, spacing: ForRentTheme.Spacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(ForRentTheme.Brand.royalBlue)
                .frame(width: 24)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: ForRentTheme.Spacing.xxs) {
                Text(title)
                    .font(ForRentTheme.Typography.rowTitle)
                    .foregroundStyle(ForRentTheme.Colors.textPrimary)

                Text(value)
                    .font(ForRentTheme.Typography.body)
                    .foregroundStyle(ForRentTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                if let supportingText {
                    Text(supportingText)
                        .font(ForRentTheme.Typography.supporting)
                        .foregroundStyle(ForRentTheme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}
