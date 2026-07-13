import SwiftUI

struct PostViewingCheckInView: View {
    let requestId: String
    let propertyId: String

    @EnvironmentObject private var requestVM: RequestViewModel
    @EnvironmentObject private var propertyVM: PropertyViewModel
    @EnvironmentObject private var authVM: AuthViewModel

    @State private var selectedChoice: PostViewingChoice?
    @State private var feedback = ""
    @State private var decision: PostViewingDecision?

    private let graceMinutes = 5

    var body: some View {
        Group {
            if let request, let snapshot {
                ScrollView {
                    VStack(alignment: .leading, spacing: ForRentTheme.Spacing.lg) {
                        header(snapshot)
                        optionSection(snapshot)

                        if snapshot.isPromptReady {
                            feedbackSection
                            submitButton(request: request, snapshot: snapshot)
                        }

                        if let decision {
                            outcomeCard(decision)
                        }
                    }
                    .padding(ForRentTheme.Spacing.screenHorizontal)
                }
                .background(ForRentTheme.Colors.canvas)
            } else {
                ContentUnavailableView {
                    Label("Check-in unavailable", systemImage: "checklist")
                } description: {
                    Text("This viewing could not be found.")
                }
            }
        }
        .navigationTitle("Post-Viewing")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            requestVM.startListening(for: authVM.user)
            await propertyVM.fetchProperties(for: authVM.user)
        }
    }

    private var request: Request? {
        requestVM.requests.first { $0.id == requestId }
    }

    private var property: Property? {
        propertyVM.properties.first { $0.id == propertyId }
    }

    private var snapshot: PostViewingDecisionSnapshot? {
        guard let request else { return nil }
        return PostViewingDecisionSnapshot(
            viewing: demoCompletedViewing(for: request),
            property: property,
            now: Date(),
            graceMinutes: graceMinutes
        )
    }

    private func header(_ snapshot: PostViewingDecisionSnapshot) -> some View {
        VStack(alignment: .leading, spacing: ForRentTheme.Spacing.sm) {
            Text(snapshot.propertyTitle)
                .font(ForRentTheme.Typography.sectionTitle)
                .foregroundStyle(ForRentTheme.Colors.textPrimary)

            Text(snapshot.propertyLocation)
                .font(ForRentTheme.Typography.supporting)
                .foregroundStyle(ForRentTheme.Colors.textSecondary)

            Text(snapshot.promptTitle)
                .font(ForRentTheme.Typography.rowTitle)
                .foregroundStyle(ForRentTheme.Colors.textPrimary)

            Text(snapshot.promptDetail)
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

    @ViewBuilder
    private func optionSection(_ snapshot: PostViewingDecisionSnapshot) -> some View {
        if snapshot.options.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: ForRentTheme.Spacing.md) {
                ForEach(snapshot.options) { option in
                    Button {
                        selectedChoice = option.choice
                    } label: {
                        HStack(alignment: .top, spacing: ForRentTheme.Spacing.sm) {
                            Image(systemName: selectedChoice == option.choice ? "largecircle.fill.circle" : option.systemImage)
                                .font(.title3)
                                .foregroundStyle(ForRentTheme.Colors.actionPrimary)
                                .frame(width: ForRentTheme.Control.minimumTarget, height: ForRentTheme.Control.minimumTarget)

                            VStack(alignment: .leading, spacing: ForRentTheme.Spacing.xxs) {
                                Text(option.title)
                                    .font(ForRentTheme.Typography.rowTitle)
                                    .foregroundStyle(ForRentTheme.Colors.textPrimary)

                                Text(option.detail)
                                    .font(ForRentTheme.Typography.caption)
                                    .foregroundStyle(ForRentTheme.Colors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Spacer(minLength: ForRentTheme.Spacing.sm)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(ForRentTheme.Spacing.md)
                    }
                    .buttonStyle(.plain)
                    .background(selectedChoice == option.choice ? ForRentTheme.Colors.surfaceSelected : ForRentTheme.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: ForRentTheme.Radius.card, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: ForRentTheme.Radius.card, style: .continuous)
                            .stroke(
                                selectedChoice == option.choice ? ForRentTheme.Colors.actionPrimary : ForRentTheme.Colors.border,
                                lineWidth: 1
                            )
                    )
                }
            }
        }
    }

    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: ForRentTheme.Spacing.sm) {
            Text("Viewing feedback")
                .font(ForRentTheme.Typography.rowTitle)
                .foregroundStyle(ForRentTheme.Colors.textPrimary)

            TextField("Optional note", text: $feedback, axis: .vertical)
                .lineLimit(3...5)
                .textFieldStyle(.roundedBorder)
        }
    }

    private func submitButton(request: Request, snapshot: PostViewingDecisionSnapshot) -> some View {
        Button {
            guard let selectedChoice else { return }
            decision = PostViewingDecision(
                id: "decision__\(request.id)",
                viewingId: snapshot.viewingId,
                conversationId: request.id,
                propertyId: request.propertyId,
                renterId: request.tenantId,
                choice: selectedChoice,
                feedback: feedback,
                createdAt: Date()
            )
        } label: {
            Label(selectedOption?.continuationTitle ?? "Choose a decision", systemImage: "arrow.right.circle.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(ForRentPrimaryButtonStyle())
        .disabled(selectedChoice == nil)
    }

    private var selectedOption: PostViewingDecisionOption? {
        guard let selectedChoice else { return nil }
        return PostViewingDecisionOption(choice: selectedChoice)
    }

    private func outcomeCard(_ decision: PostViewingDecision) -> some View {
        VStack(alignment: .leading, spacing: ForRentTheme.Spacing.sm) {
            StatusChip(
                title: selectedOption?.continuationTitle ?? "Decision recorded",
                systemImage: selectedOption?.systemImage ?? "checkmark.circle.fill",
                tone: decision.choice == .yes ? .success : .neutral
            )

            Text(outcomeDetail(for: decision))
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

    private func outcomeDetail(for decision: PostViewingDecision) -> String {
        switch decision.continuation {
        case .openOfferComposer:
            return "This listing is ready for a structured offer. Completion still requires both parties approving the same offer version."
        case .oneReminderWindow:
            return "This keeps the journey open for one reminder window without notifying the manager as a positive signal."
        case .archiveReadOnly:
            return "This listing journey ends here and the conversation becomes read-only history."
        }
    }

    private func demoCompletedViewing(for request: Request) -> Viewing {
        let endAt = Date().addingTimeInterval(-10 * 60)
        return Viewing(
            id: "viewing__\(request.id)",
            propertyId: request.propertyId,
            conversationId: request.id,
            renterId: request.tenantId,
            managerId: request.landlordId,
            startAt: endAt.addingTimeInterval(-45 * 60),
            endAt: endAt,
            timezoneIdentifier: "America/Toronto",
            status: request.status == .viewingScheduled ? .completed : .cancelled
        )
    }
}
