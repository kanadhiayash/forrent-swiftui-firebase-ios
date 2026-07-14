import SwiftUI

struct ViewingCalendarView: View {
    @EnvironmentObject private var propertyVM: PropertyViewModel
    @EnvironmentObject private var requestVM: RequestViewModel
    @EnvironmentObject private var authVM: AuthViewModel

    @State private var selectedDate = Date()

    var body: some View {
        Group {
            if let snapshot {
                ScrollView {
                    VStack(alignment: .leading, spacing: ForRentTheme.Spacing.lg) {
                        DatePicker(
                            "Calendar day",
                            selection: $selectedDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .tint(ForRentTheme.Colors.actionPrimary)
                        .padding(ForRentTheme.Spacing.md)
                        .background(ForRentTheme.Colors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: ForRentTheme.Radius.card, style: .continuous))

                        calendarSection(snapshot)
                        agendaSection(snapshot)
                    }
                    .padding(ForRentTheme.Spacing.screenHorizontal)
                }
                .background(ForRentTheme.Colors.canvas)
            } else {
                ContentUnavailableView {
                    Label("Calendar unavailable", systemImage: "calendar.badge.exclamationmark")
                } description: {
                    Text("Sign in as a property manager to manage viewing availability.")
                }
            }
        }
        .navigationTitle("Calendar")
        .task {
            requestVM.startListening(for: authVM.user)
            await propertyVM.fetchProperties(for: authVM.user)
        }
    }

    private var snapshot: ViewingScheduleSnapshot? {
        guard let user = authVM.user, user.role == .landlord else { return nil }

        return ViewingScheduleSnapshot.managerCalendar(
            managerId: user.id,
            properties: propertyVM.properties,
            requests: requestVM.requests,
            date: selectedDate
        )
    }

    private func calendarSection(_ snapshot: ViewingScheduleSnapshot) -> some View {
        VStack(alignment: .leading, spacing: ForRentTheme.Spacing.md) {
            Text("Availability")
                .font(ForRentTheme.Typography.sectionTitle)
                .foregroundStyle(ForRentTheme.Colors.textPrimary)

            ForEach(snapshot.availabilityDays) { day in
                VStack(alignment: .leading, spacing: ForRentTheme.Spacing.sm) {
                    HStack {
                        Text(day.propertyTitle)
                            .font(ForRentTheme.Typography.rowTitle)
                            .foregroundStyle(ForRentTheme.Colors.textPrimary)

                        Spacer()

                        StatusChip(
                            title: day.summary,
                            systemImage: day.slots.isEmpty ? "calendar.badge.exclamationmark" : "calendar.badge.clock",
                            tone: day.slots.isEmpty ? .neutral : .info
                        )
                    }

                    if !day.slots.isEmpty {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: ForRentTheme.Spacing.sm)], spacing: ForRentTheme.Spacing.sm) {
                            ForEach(day.slots.prefix(6)) { slot in
                                Text(slot.startsAt.formatted(date: .omitted, time: .shortened))
                                    .font(ForRentTheme.Typography.caption.weight(.semibold))
                                    .foregroundStyle(ForRentTheme.Colors.actionPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, ForRentTheme.Spacing.xs)
                                    .background(ForRentTheme.Colors.surfaceSelected)
                                    .clipShape(RoundedRectangle(cornerRadius: ForRentTheme.Radius.control, style: .continuous))
                            }
                        }
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
    }

    private func agendaSection(_ snapshot: ViewingScheduleSnapshot) -> some View {
        VStack(alignment: .leading, spacing: ForRentTheme.Spacing.md) {
            Text("Day Agenda")
                .font(ForRentTheme.Typography.sectionTitle)
                .foregroundStyle(ForRentTheme.Colors.textPrimary)

            if snapshot.agendaItems.isEmpty {
                Text("No scheduled viewings for this demo day.")
                    .font(ForRentTheme.Typography.supporting)
                    .foregroundStyle(ForRentTheme.Colors.textSecondary)
            } else {
                ForEach(snapshot.agendaItems) { item in
                    Label("\(item.renterName) - \(item.propertyTitle)", systemImage: "person.crop.circle.badge.clock")
                        .font(ForRentTheme.Typography.supporting)
                        .foregroundStyle(ForRentTheme.Colors.textPrimary)
                }
            }
        }
    }
}

struct ViewingBookingView: View {
    let requestId: String
    let propertyId: String

    @EnvironmentObject private var requestVM: RequestViewModel
    @EnvironmentObject private var propertyVM: PropertyViewModel
    @EnvironmentObject private var authVM: AuthViewModel

    @State private var selectedDate = Date()
    @State private var selectedSlotId: String?

    var body: some View {
        Group {
            if let request, let snapshot {
                ScrollView {
                    VStack(alignment: .leading, spacing: ForRentTheme.Spacing.lg) {
                        Text(snapshot.propertyTitle)
                            .font(ForRentTheme.Typography.sectionTitle)
                            .foregroundStyle(ForRentTheme.Colors.textPrimary)

                        DatePicker("Viewing date", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .tint(ForRentTheme.Colors.actionPrimary)

                        slotSection(snapshot)

                        Button {
                            Task {
                                await requestVM.scheduleViewing(request, currentUser: authVM.user)
                            }
                        } label: {
                            Label("Reserve selected viewing", systemImage: "calendar.badge.checkmark")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(ForRentPrimaryButtonStyle())
                        .disabled(selectedSlotId == nil)
                    }
                    .padding(ForRentTheme.Spacing.screenHorizontal)
                }
                .background(ForRentTheme.Colors.canvas)
            } else {
                ContentUnavailableView {
                    Label("Viewing unavailable", systemImage: "calendar.badge.exclamationmark")
                } description: {
                    Text("This conversation is not ready for viewing booking.")
                }
            }
        }
        .navigationTitle("Book Viewing")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var request: Request? {
        requestVM.requests.first { $0.id == requestId }
    }

    private var property: Property? {
        propertyVM.properties.first { $0.id == propertyId }
    }

    private var snapshot: ViewingBookingSnapshot? {
        guard let request else { return nil }
        return ViewingBookingSnapshot(request: request, property: property, date: selectedDate)
    }

    private func slotSection(_ snapshot: ViewingBookingSnapshot) -> some View {
        VStack(alignment: .leading, spacing: ForRentTheme.Spacing.md) {
            Text("Available Times")
                .font(ForRentTheme.Typography.rowTitle)
                .foregroundStyle(ForRentTheme.Colors.textPrimary)

            if snapshot.slots.isEmpty {
                Text("No instant-book slots are available for this date.")
                    .font(ForRentTheme.Typography.supporting)
                    .foregroundStyle(ForRentTheme.Colors.textSecondary)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: ForRentTheme.Spacing.sm)], spacing: ForRentTheme.Spacing.sm) {
                    ForEach(snapshot.slots) { slot in
                        Button {
                            selectedSlotId = slot.id
                        } label: {
                            Label(
                                slot.startsAt.formatted(date: .omitted, time: .shortened),
                                systemImage: selectedSlotId == slot.id ? "checkmark.circle.fill" : "circle"
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(ForRentTheme.Colors.actionPrimary)
                    }
                }
            }
        }
    }
}
