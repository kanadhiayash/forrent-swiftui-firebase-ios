import SwiftUI

struct ConversationThreadView: View {
    let requestId: String
    let propertyId: String

    @EnvironmentObject private var requestVM: RequestViewModel
    @EnvironmentObject private var propertyVM: PropertyViewModel
    @EnvironmentObject private var authVM: AuthViewModel

    var body: some View {
        Group {
            if let snapshot, let request {
                ScrollView {
                    VStack(alignment: .leading, spacing: ForRentTheme.Spacing.md) {
                        header(snapshot.inboxItem)

                        ForEach(snapshot.inboxItem.workflowCards) { card in
                            WorkflowCardView(card: card)
                        }

                        messageSection(snapshot)
                        actionSection(request: request, snapshot: snapshot)
                    }
                    .padding(ForRentTheme.Spacing.screenHorizontal)
                }
                .background(ForRentTheme.Colors.canvas)
            } else {
                ContentUnavailableView {
                    Label("Conversation unavailable", systemImage: "exclamationmark.bubble")
                } description: {
                    Text("This property conversation could not be found.")
                }
            }
        }
        .navigationTitle("Conversation")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            requestVM.startListening(for: authVM.user)
            await propertyVM.fetchProperties(for: authVM.user)
        }
        .showError($requestVM.errorMessage)
    }

    private var request: Request? {
        requestVM.requests.first { $0.id == requestId }
    }

    private var property: Property? {
        propertyVM.properties.first { $0.id == propertyId }
    }

    private var snapshot: ConversationThreadSnapshot? {
        guard let request, let role = authVM.user?.role else { return nil }
        return ConversationThreadSnapshot(request: request, property: property, viewerRole: role)
    }

    private func header(_ item: ConversationInboxItem) -> some View {
        VStack(alignment: .leading, spacing: ForRentTheme.Spacing.sm) {
            Text(item.propertyTitle)
                .font(ForRentTheme.Typography.sectionTitle)
                .foregroundStyle(ForRentTheme.Colors.textPrimary)

            Text(item.propertyLocation)
                .font(ForRentTheme.Typography.supporting)
                .foregroundStyle(ForRentTheme.Colors.textSecondary)

            StatusChip(
                title: item.statusTitle,
                systemImage: item.isReadOnly ? "archivebox.fill" : "bubble.left.and.bubble.right.fill",
                tone: item.isReadOnly ? .neutral : .info
            )
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

    private func messageSection(_ snapshot: ConversationThreadSnapshot) -> some View {
        VStack(alignment: .leading, spacing: ForRentTheme.Spacing.sm) {
            Text("Messages")
                .font(ForRentTheme.Typography.rowTitle)
                .foregroundStyle(ForRentTheme.Colors.textPrimary)

            ForEach(Array(snapshot.systemMessages.enumerated()), id: \.offset) { _, message in
                Text(message)
                    .font(ForRentTheme.Typography.supporting)
                    .foregroundStyle(ForRentTheme.Colors.textPrimary)
                    .padding(ForRentTheme.Spacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(ForRentTheme.Colors.surfaceRaised)
                    .clipShape(RoundedRectangle(cornerRadius: ForRentTheme.Radius.control, style: .continuous))
            }

            if snapshot.canSendMessage {
                VStack(alignment: .leading, spacing: ForRentTheme.Spacing.xs) {
                    Text("Suggested questions")
                        .font(ForRentTheme.Typography.caption.weight(.semibold))
                        .foregroundStyle(ForRentTheme.Colors.textSecondary)

                    ForEach(snapshot.suggestedQuestions, id: \.self) { question in
                        Text(question)
                            .font(ForRentTheme.Typography.caption)
                            .foregroundStyle(ForRentTheme.Colors.actionPrimary)
                            .padding(.horizontal, ForRentTheme.Spacing.sm)
                            .padding(.vertical, ForRentTheme.Spacing.xs)
                            .background(ForRentTheme.Colors.surfaceSelected)
                            .clipShape(Capsule())
                    }
                }
            } else {
                Label("Read-only history", systemImage: "lock.fill")
                    .font(ForRentTheme.Typography.caption)
                    .foregroundStyle(ForRentTheme.Colors.textSecondary)
            }
        }
    }

    @ViewBuilder
    private func actionSection(request: Request, snapshot: ConversationThreadSnapshot) -> some View {
        if authVM.user?.role == .landlord, !landlordNextStatuses(for: request).isEmpty {
            Menu {
                ForEach(landlordNextStatuses(for: request), id: \.self) { status in
                    Button(status.title) {
                        Task {
                            await requestVM.update(request, status: status, currentUser: authVM.user)
                            if status == .accepted {
                                await propertyVM.fetchProperties(for: authVM.user)
                            }
                        }
                    }
                }
            } label: {
                Label(snapshot.inboxItem.nextActionTitle, systemImage: "slider.horizontal.3")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(ForRentPrimaryButtonStyle())
        } else if authVM.user?.role == .tenant,
                  request.status.canTransition(to: .cancelled) {
            Button(role: .destructive) {
                Task {
                    await requestVM.cancel(request, currentUser: authVM.user)
                }
            } label: {
                Label("Cancel inquiry", systemImage: "xmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }

    private func landlordNextStatuses(for request: Request) -> [RequestStatus] {
        [.acknowledged, .viewingScheduled, .accepted, .rejected]
            .filter { request.status.canTransition(to: $0) }
    }
}

private struct WorkflowCardView: View {
    let card: ConversationWorkflowCard

    var body: some View {
        HStack(alignment: .top, spacing: ForRentTheme.Spacing.sm) {
            Image(systemName: card.systemImage)
                .font(.headline)
                .foregroundStyle(ForRentTheme.Colors.actionPrimary)
                .frame(width: ForRentTheme.Control.minimumTarget, height: ForRentTheme.Control.minimumTarget)
                .background(Circle().fill(ForRentTheme.Colors.surfaceSelected))

            VStack(alignment: .leading, spacing: ForRentTheme.Spacing.xxs) {
                Text(card.title)
                    .font(ForRentTheme.Typography.rowTitle)
                    .foregroundStyle(ForRentTheme.Colors.textPrimary)

                Text(card.detail)
                    .font(ForRentTheme.Typography.supporting)
                    .foregroundStyle(ForRentTheme.Colors.textSecondary)
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
