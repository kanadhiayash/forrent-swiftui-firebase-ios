import SwiftUI

struct MarketQualificationView: View {
    private let snapshot: MarketQualificationPresentationSnapshot

    init(checklist: MarketQualificationChecklist = .defaultReleaseGate()) {
        snapshot = MarketQualificationPresentationSnapshot(checklist: checklist)
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: ForRentTheme.Spacing.sm) {
                    Text(snapshot.statusTitle)
                        .font(ForRentTheme.Typography.sectionTitle)
                        .foregroundStyle(ForRentTheme.Colors.textPrimary)

                    Text(snapshot.summary)
                        .font(ForRentTheme.Typography.body)
                        .foregroundStyle(ForRentTheme.Colors.textSecondary)

                    ProgressView(value: snapshot.progressValue)
                        .tint(ForRentTheme.Colors.actionPrimary)
                        .accessibilityLabel("Market qualification progress")
                        .accessibilityValue(snapshot.summary)

                    Text("This workspace tracks release evidence for localization, accessibility, performance, security, moderation, TestFlight, monitoring, and production Firebase approval.")
                        .font(ForRentTheme.Typography.supporting)
                        .foregroundStyle(ForRentTheme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, ForRentTheme.Spacing.xs)
            }

            Section("Required Gates") {
                ForEach(snapshot.items) { item in
                    MarketQualificationRow(item: item)
                }
            }

            Section {
                Button(snapshot.primaryActionTitle) {}
                    .buttonStyle(.borderedProminent)
                    .disabled(!snapshot.progressValue.isEqual(to: 1))
                    .accessibilityIdentifier("marketQualification.primaryAction")
            } footer: {
                Text("Evidence must come from real commands, manual QA, owner review, or approved production configuration. This screen does not mark unverified work as complete.")
            }
        }
        .scrollContentBackground(.hidden)
        .background(ForRentTheme.Colors.canvas)
        .navigationTitle(snapshot.title)
        .accessibilityIdentifier("marketQualification.screen")
    }
}

private struct MarketQualificationRow: View {
    let item: MarketQualificationPresentationItem

    var body: some View {
        HStack(alignment: .top, spacing: ForRentTheme.Spacing.sm) {
            Image(systemName: item.statusTitle == "Verified" ? "checkmark.seal.fill" : "exclamationmark.triangle")
                .foregroundStyle(item.statusTitle == "Verified" ? ForRentTheme.Colors.success : ForRentTheme.Colors.warning)
                .frame(width: 24)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: ForRentTheme.Spacing.xxs) {
                Text(item.title)
                    .font(ForRentTheme.Typography.rowTitle)
                    .foregroundStyle(ForRentTheme.Colors.textPrimary)

                Text(item.statusTitle)
                    .font(ForRentTheme.Typography.supporting)
                    .foregroundStyle(ForRentTheme.Colors.textSecondary)

                if let evidenceSummary = item.evidenceSummary {
                    Text(evidenceSummary)
                        .font(ForRentTheme.Typography.caption)
                        .foregroundStyle(ForRentTheme.Colors.textMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(minHeight: ForRentTheme.Control.minimumTarget)
        .accessibilityElement(children: .combine)
    }
}
