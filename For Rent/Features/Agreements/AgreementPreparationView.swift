import SwiftUI

struct AgreementPreparationView: View {
    let offer: RentalOffer

    private var snapshot: AgreementPreparationSnapshot {
        if offer.status == .mutuallyAccepted,
           let prepared = try? AgreementPreparationSnapshot(offer: offer, jurisdiction: .ontario, now: Date()) {
            return prepared
        }

        return .blocked(offer: offer)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ForRentTheme.Spacing.lg) {
                header
                confirmedTerms
                requiredDocuments
                legalNotice
                primaryAction
            }
            .padding(ForRentTheme.Spacing.screenHorizontal)
        }
        .background(ForRentTheme.Colors.canvas)
        .navigationTitle("Next Steps")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: ForRentTheme.Spacing.sm) {
            StatusChip(title: snapshot.statusTitle, systemImage: "doc.text.fill", tone: .success)

            Text("Agreement preparation")
                .font(ForRentTheme.Typography.sectionTitle)
                .foregroundStyle(ForRentTheme.Colors.textPrimary)

            Text("\(snapshot.approvedVersionTitle) · \(snapshot.monthlyRentTitle)")
                .font(ForRentTheme.Typography.supporting)
                .foregroundStyle(ForRentTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .agreementPanel()
    }

    private var confirmedTerms: some View {
        VStack(alignment: .leading, spacing: ForRentTheme.Spacing.md) {
            Text("Confirmed Terms")
                .font(ForRentTheme.Typography.rowTitle)
                .foregroundStyle(ForRentTheme.Colors.textPrimary)

            ForEach(snapshot.confirmedTerms) { term in
                HStack(alignment: .top, spacing: ForRentTheme.Spacing.sm) {
                    Text(term.title)
                        .font(ForRentTheme.Typography.caption.weight(.semibold))
                        .foregroundStyle(ForRentTheme.Colors.textSecondary)
                        .frame(width: 84, alignment: .leading)

                    Text(term.value)
                        .font(ForRentTheme.Typography.supporting)
                        .foregroundStyle(ForRentTheme.Colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .agreementPanel()
    }

    private var requiredDocuments: some View {
        VStack(alignment: .leading, spacing: ForRentTheme.Spacing.md) {
            Text("Required Documents")
                .font(ForRentTheme.Typography.rowTitle)
                .foregroundStyle(ForRentTheme.Colors.textPrimary)

            ForEach(snapshot.requiredDocuments, id: \.self) { item in
                Label(item, systemImage: "checkmark.circle")
                    .font(ForRentTheme.Typography.supporting)
                    .foregroundStyle(ForRentTheme.Colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .agreementPanel()
    }

    private var legalNotice: some View {
        Label {
            Text(snapshot.legalNotice)
                .font(ForRentTheme.Typography.supporting)
                .foregroundStyle(ForRentTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        } icon: {
            Image(systemName: "exclamationmark.shield")
                .foregroundStyle(ForRentTheme.Colors.warning)
        }
        .agreementPanel()
    }

    private var primaryAction: some View {
        VStack(alignment: .leading, spacing: ForRentTheme.Spacing.sm) {
            Button {
            } label: {
                Label(snapshot.primaryActionTitle, systemImage: "square.and.arrow.down")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(ForRentPrimaryButtonStyle())
            .disabled(offer.status != .mutuallyAccepted)

            Text("Corrections, export, and signing status stay downstream of mutual approval.")
                .font(ForRentTheme.Typography.caption)
                .foregroundStyle(ForRentTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private extension View {
    func agreementPanel() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(ForRentTheme.Spacing.md)
            .background(ForRentTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: ForRentTheme.Radius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: ForRentTheme.Radius.card, style: .continuous)
                    .stroke(ForRentTheme.Colors.border, lineWidth: 1)
            )
    }
}
