import SwiftUI

struct JourneyView: View {
    @EnvironmentObject private var requestVM: RequestViewModel
    @EnvironmentObject private var propertyVM: PropertyViewModel
    @EnvironmentObject private var authVM: AuthViewModel

    var body: some View {
        Group {
            if requestVM.isLoading {
                LoadingView()
            } else if snapshots.isEmpty {
                ContentUnavailableView {
                    Label("No active journeys", systemImage: "map")
                } description: {
                    Text("Message a listing or request a viewing to start a property journey.")
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: ForRentTheme.Spacing.md) {
                        ForEach(snapshots) { snapshot in
                            JourneyCard(snapshot: snapshot)
                        }
                    }
                    .padding(ForRentTheme.Spacing.screenHorizontal)
                }
                .background(ForRentTheme.Colors.canvas)
            }
        }
        .navigationTitle("Journey")
        .task {
            requestVM.startListening(for: authVM.user)
            await propertyVM.fetchProperties(for: authVM.user)
        }
        .showError($requestVM.errorMessage)
    }

    private var snapshots: [JourneyTimelineSnapshot] {
        guard let user = authVM.user else { return [] }
        return requestVM.requests
            .filter { $0.tenantId == user.id }
            .map { request in
                JourneyTimelineSnapshot(
                    request: request,
                    property: propertyVM.properties.first { $0.id == request.propertyId }
                )
            }
    }
}

private struct JourneyCard: View {
    let snapshot: JourneyTimelineSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: ForRentTheme.Spacing.md) {
            VStack(alignment: .leading, spacing: ForRentTheme.Spacing.xs) {
                HStack(alignment: .top, spacing: ForRentTheme.Spacing.sm) {
                    VStack(alignment: .leading, spacing: ForRentTheme.Spacing.xxs) {
                        Text(snapshot.propertyTitle)
                            .font(ForRentTheme.Typography.sectionTitle)
                            .foregroundStyle(ForRentTheme.Colors.textPrimary)

                        Text(snapshot.propertyLocation)
                            .font(ForRentTheme.Typography.supporting)
                            .foregroundStyle(ForRentTheme.Colors.textSecondary)
                    }

                    Spacer(minLength: ForRentTheme.Spacing.sm)

                    StatusChip(
                        title: snapshot.statusTitle,
                        systemImage: statusIcon,
                        tone: statusTone
                    )
                }

                Text(snapshot.currentStage == .ended
                     ? "This listing journey has ended. The conversation remains available as read-only history."
                     : "From first question to mutual yes, every step stays attached to this property.")
                    .font(ForRentTheme.Typography.supporting)
                    .foregroundStyle(ForRentTheme.Colors.textSecondary)
            }

            NavigationLink {
                RequestsView()
                    .navigationTitle("Journey details")
            } label: {
                Label(snapshot.primaryActionTitle, systemImage: primaryActionIcon)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(ForRentPrimaryButtonStyle())

            VStack(alignment: .leading, spacing: ForRentTheme.Spacing.sm) {
                ForEach(snapshot.steps) { step in
                    JourneyStepRow(step: step)
                }
            }
        }
        .padding(ForRentTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: ForRentTheme.Radius.card, style: .continuous)
                .fill(ForRentTheme.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: ForRentTheme.Radius.card, style: .continuous)
                        .stroke(ForRentTheme.Colors.border, lineWidth: 1)
                )
        )
        .accessibilityElement(children: .contain)
    }

    private var statusIcon: String {
        switch snapshot.currentStage {
        case .listing: "house.fill"
        case .conversation: "bubble.left.and.bubble.right.fill"
        case .viewing: "calendar.badge.clock"
        case .postViewingDecision: "checklist"
        case .offer: "doc.text.fill"
        case .mutualApproval: "checkmark.seal.fill"
        case .ended: "archivebox.fill"
        }
    }

    private var primaryActionIcon: String {
        switch snapshot.currentStage {
        case .conversation: "message.fill"
        case .viewing: "calendar"
        case .offer: "square.and.pencil"
        case .ended: "doc.plaintext"
        default: "arrow.right.circle.fill"
        }
    }

    private var statusTone: StatusChipTone {
        switch snapshot.currentStage {
        case .ended: .neutral
        case .mutualApproval: .success
        case .offer, .viewing, .conversation: .info
        case .listing, .postViewingDecision: .neutral
        }
    }
}

private struct JourneyStepRow: View {
    let step: JourneyTimelineStep

    var body: some View {
        HStack(alignment: .top, spacing: ForRentTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(iconColor)
                .frame(width: ForRentTheme.Control.minimumTarget, height: ForRentTheme.Control.minimumTarget)
                .background(
                    Circle()
                        .fill(backgroundColor)
                )

            VStack(alignment: .leading, spacing: ForRentTheme.Spacing.xxs) {
                Text(step.title)
                    .font(ForRentTheme.Typography.rowTitle)
                    .foregroundStyle(ForRentTheme.Colors.textPrimary)

                Text(step.detail)
                    .font(ForRentTheme.Typography.caption)
                    .foregroundStyle(ForRentTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var icon: String {
        switch step.state {
        case .complete: "checkmark"
        case .active: "arrow.right"
        case .locked: "lock.fill"
        case .ended: "minus"
        }
    }

    private var iconColor: Color {
        switch step.state {
        case .complete: ForRentTheme.Colors.success
        case .active: ForRentTheme.Colors.actionPrimary
        case .locked: ForRentTheme.Colors.textMuted
        case .ended: ForRentTheme.Colors.textSecondary
        }
    }

    private var backgroundColor: Color {
        switch step.state {
        case .complete: ForRentTheme.Colors.successSurface
        case .active: ForRentTheme.Colors.surfaceSelected
        case .locked: ForRentTheme.Colors.surfaceSubtle
        case .ended: ForRentTheme.Colors.surfaceSubtle
        }
    }
}
