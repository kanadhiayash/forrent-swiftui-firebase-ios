import SwiftUI

struct ConversationInboxView: View {
    @EnvironmentObject private var requestVM: RequestViewModel
    @EnvironmentObject private var propertyVM: PropertyViewModel
    @EnvironmentObject private var authVM: AuthViewModel

    var body: some View {
        Group {
            if requestVM.isLoading {
                LoadingView()
            } else if items.isEmpty {
                ContentUnavailableView {
                    Label("No conversations yet", systemImage: "bubble.left.and.bubble.right")
                } description: {
                    Text(emptyDescription)
                }
            } else {
                List(items) { item in
                    NavigationLink {
                        ConversationThreadView(requestId: item.requestId, propertyId: item.propertyId)
                    } label: {
                        ConversationInboxRow(item: item)
                    }
                    .accessibilityIdentifier("conversation.row.\(item.requestId)")
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Inbox")
        .task {
            requestVM.startListening(for: authVM.user)
            await propertyVM.fetchProperties(for: authVM.user)
        }
        .showError($requestVM.errorMessage)
    }

    private var items: [ConversationInboxItem] {
        guard let user = authVM.user else { return [] }

        return requestVM.requests
            .filter { request in
                user.role == .landlord ? request.landlordId == user.id : request.tenantId == user.id
            }
            .map { request in
                ConversationInboxItem(
                    request: request,
                    property: propertyVM.properties.first { $0.id == request.propertyId },
                    viewerRole: user.role
                )
            }
            .sorted { $0.propertyTitle.localizedCaseInsensitiveCompare($1.propertyTitle) == .orderedAscending }
    }

    private var emptyDescription: String {
        authVM.user?.role == .landlord
            ? "Renter conversations will appear here with listing context and workflow cards."
            : "Message a listing or request a viewing to start a property conversation."
    }
}

private struct ConversationInboxRow: View {
    let item: ConversationInboxItem

    var body: some View {
        VStack(alignment: .leading, spacing: ForRentTheme.Spacing.sm) {
            HStack(alignment: .top, spacing: ForRentTheme.Spacing.sm) {
                VStack(alignment: .leading, spacing: ForRentTheme.Spacing.xxs) {
                    Text(item.propertyTitle)
                        .font(ForRentTheme.Typography.rowTitle)
                        .foregroundStyle(ForRentTheme.Colors.textPrimary)

                    Text(item.participantTitle)
                        .font(ForRentTheme.Typography.caption)
                        .foregroundStyle(ForRentTheme.Colors.textSecondary)
                }

                Spacer(minLength: ForRentTheme.Spacing.sm)

                StatusChip(
                    title: item.statusTitle,
                    systemImage: item.isReadOnly ? "archivebox.fill" : "bubble.left.fill",
                    tone: item.isReadOnly ? .neutral : .info
                )
            }

            Text(item.latestPreview)
                .font(ForRentTheme.Typography.supporting)
                .foregroundStyle(ForRentTheme.Colors.textSecondary)
                .lineLimit(2)

            Label(item.nextActionTitle, systemImage: item.isReadOnly ? "doc.plaintext" : "arrow.right.circle.fill")
                .font(ForRentTheme.Typography.caption.weight(.semibold))
                .foregroundStyle(ForRentTheme.Colors.actionPrimary)
        }
        .padding(.vertical, ForRentTheme.Spacing.xs)
    }
}
