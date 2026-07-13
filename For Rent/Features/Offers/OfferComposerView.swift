import SwiftUI

struct OfferComposerView: View {
    let requestId: String
    let propertyId: String

    @EnvironmentObject private var requestVM: RequestViewModel
    @EnvironmentObject private var propertyVM: PropertyViewModel
    @EnvironmentObject private var authVM: AuthViewModel

    @State private var draft = StructuredOfferDraft()
    @State private var submittedOffer: RentalOffer?
    @State private var validationMessage: String?
    @State private var didSeedRent = false

    var body: some View {
        Group {
            if let request {
                ScrollView {
                    VStack(alignment: .leading, spacing: ForRentTheme.Spacing.lg) {
                        header

                        if let submittedOffer {
                            OfferReviewCard(offer: submittedOffer)
                        } else {
                            termsForm
                            submitButton(request: request)
                        }
                    }
                    .padding(ForRentTheme.Spacing.screenHorizontal)
                }
                .background(ForRentTheme.Colors.canvas)
            } else {
                ContentUnavailableView {
                    Label("Offer unavailable", systemImage: "doc.text.magnifyingglass")
                } description: {
                    Text("This property conversation could not be found.")
                }
            }
        }
        .navigationTitle("Create Offer")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            requestVM.startListening(for: authVM.user)
            await propertyVM.fetchProperties(for: authVM.user)
            seedRentIfNeeded()
        }
    }

    private var request: Request? {
        requestVM.requests.first { $0.id == requestId }
    }

    private var property: Property? {
        propertyVM.properties.first { $0.id == propertyId }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: ForRentTheme.Spacing.sm) {
            Text(property?.title ?? "Rental inquiry")
                .font(ForRentTheme.Typography.sectionTitle)
                .foregroundStyle(ForRentTheme.Colors.textPrimary)

            Text("Submit structured terms. Chat messages can explain context, but only approved offer versions can complete the journey.")
                .font(ForRentTheme.Typography.supporting)
                .foregroundStyle(ForRentTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(ForRentTheme.Spacing.md)
        .background(ForRentTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: ForRentTheme.Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: ForRentTheme.Radius.card, style: .continuous)
                .stroke(ForRentTheme.Colors.border, lineWidth: 1)
        )
    }

    private var termsForm: some View {
        VStack(alignment: .leading, spacing: ForRentTheme.Spacing.md) {
            TextField("Monthly rent", text: $draft.monthlyRentText)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)

            DatePicker("Move-in date", selection: $draft.moveInDate, displayedComponents: .date)
                .tint(ForRentTheme.Colors.actionPrimary)

            Stepper("Lease length: \(draft.leaseLengthMonths) months", value: $draft.leaseLengthMonths, in: 1...36)
            Stepper("Occupants: \(draft.occupancyCount)", value: $draft.occupancyCount, in: 1...8)

            VStack(alignment: .leading, spacing: ForRentTheme.Spacing.sm) {
                Toggle("Parking included", isOn: $draft.includesParking)
                Toggle("Storage included", isOn: $draft.includesStorage)
                Toggle("Utilities included", isOn: $draft.includesUtilities)
                Toggle("Furnishings included", isOn: $draft.includesFurnishings)
            }
            .tint(ForRentTheme.Colors.actionPrimary)

            TextField("Conditions, separated by commas", text: $draft.conditionsText, axis: .vertical)
                .lineLimit(2...4)
                .textFieldStyle(.roundedBorder)

            TextField("Optional note", text: $draft.note, axis: .vertical)
                .lineLimit(2...4)
                .textFieldStyle(.roundedBorder)

            if let validationMessage {
                Label(validationMessage, systemImage: "exclamationmark.triangle.fill")
                    .font(ForRentTheme.Typography.caption)
                    .foregroundStyle(ForRentTheme.Colors.destructive)
            }
        }
        .padding(ForRentTheme.Spacing.md)
        .background(ForRentTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: ForRentTheme.Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: ForRentTheme.Radius.card, style: .continuous)
                .stroke(ForRentTheme.Colors.border, lineWidth: 1)
        )
    }

    private func submitButton(request: Request) -> some View {
        Button {
            do {
                let now = Date()
                let terms = try draft.makeTerms(now: now)
                validationMessage = nil
                submittedOffer = RentalOffer.submitted(
                    id: "offer__\(request.id)",
                    propertyId: request.propertyId,
                    conversationId: request.id,
                    renterId: request.tenantId,
                    managerId: request.landlordId,
                    proposer: .renter,
                    terms: terms,
                    createdAt: now
                )
            } catch {
                validationMessage = (error as? LocalizedError)?.errorDescription ?? "Review the offer terms."
            }
        } label: {
            Label("Review structured offer", systemImage: "doc.text.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(ForRentPrimaryButtonStyle())
    }

    private func seedRentIfNeeded() {
        guard !didSeedRent, let property else { return }
        draft.monthlyRentText = "\(Int(property.rent))"
        didSeedRent = true
    }
}

private struct OfferReviewCard: View {
    let offer: RentalOffer

    private var snapshot: OfferReviewSnapshot {
        OfferReviewSnapshot(offer: offer)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: ForRentTheme.Spacing.md) {
            HStack {
                StatusChip(title: snapshot.statusTitle, systemImage: "doc.text.fill", tone: .info)
                Spacer()
                Text(snapshot.versionTitle)
                    .font(ForRentTheme.Typography.caption.weight(.semibold))
                    .foregroundStyle(ForRentTheme.Colors.textSecondary)
            }

            VStack(alignment: .leading, spacing: ForRentTheme.Spacing.sm) {
                OfferTermRow(title: "Monthly rent", value: snapshot.monthlyRentTitle)
                OfferTermRow(title: "Move-in", value: snapshot.moveInTitle)
                OfferTermRow(title: "Lease", value: snapshot.leaseTitle)
                OfferTermRow(title: "Included", value: snapshot.includedTerms.isEmpty ? "None specified" : snapshot.includedTerms.joined(separator: ", "))
                OfferTermRow(title: "Conditions", value: snapshot.conditions.isEmpty ? "None" : snapshot.conditions.joined(separator: ", "))
            }

            Text(snapshot.approvalSummary)
                .font(ForRentTheme.Typography.supporting)
                .foregroundStyle(ForRentTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if offer.status == .mutuallyAccepted {
                NavigationLink {
                    AgreementPreparationView(offer: offer)
                } label: {
                    Label("Continue to agreement prep", systemImage: "doc.badge.gearshape")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(ForRentPrimaryButtonStyle())
            }
        }
        .padding(ForRentTheme.Spacing.md)
        .background(ForRentTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: ForRentTheme.Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: ForRentTheme.Radius.card, style: .continuous)
                .stroke(ForRentTheme.Colors.border, lineWidth: 1)
        )
    }
}

private struct OfferTermRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: ForRentTheme.Spacing.sm) {
            Text(title)
                .font(ForRentTheme.Typography.caption.weight(.semibold))
                .foregroundStyle(ForRentTheme.Colors.textSecondary)
                .frame(width: 88, alignment: .leading)

            Text(value)
                .font(ForRentTheme.Typography.supporting)
                .foregroundStyle(ForRentTheme.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
