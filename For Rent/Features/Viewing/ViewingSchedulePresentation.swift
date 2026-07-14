import Foundation

struct ViewingAvailabilityDay: Identifiable, Equatable {
    let propertyId: String
    let propertyTitle: String
    let slots: [ViewingSlot]

    var id: String { propertyId }

    var summary: String {
        if slots.isEmpty {
            return "No available viewing slots"
        }

        return "\(slots.count) instant-book slots"
    }
}

struct ViewingAgendaItem: Identifiable, Equatable {
    let requestId: String
    let propertyTitle: String
    let renterName: String
    let statusTitle: String

    var id: String { requestId }
}

struct ViewingScheduleSnapshot: Equatable {
    let managerId: String
    let date: Date
    let availabilityDays: [ViewingAvailabilityDay]
    let agendaItems: [ViewingAgendaItem]

    var hasConfiguredAvailability: Bool {
        availabilityDays.contains { !$0.slots.isEmpty }
    }

    static func managerCalendar(
        managerId: String,
        properties: [Property],
        requests: [Request],
        date: Date
    ) -> ViewingScheduleSnapshot {
        let managedProperties = properties
            .filter { $0.landlordId == managerId }
            .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }

        let availabilityDays = managedProperties.map { property in
            ViewingAvailabilityDay(
                propertyId: property.id,
                propertyTitle: property.title,
                slots: defaultProfile(for: property, managerId: managerId).availableSlots(on: date)
            )
        }

        let agendaItems = requests
            .filter { $0.landlordId == managerId && $0.status == .viewingScheduled }
            .compactMap { request -> ViewingAgendaItem? in
                let propertyTitle = properties.first { $0.id == request.propertyId }?.title
                return ViewingAgendaItem(
                    requestId: request.id,
                    propertyTitle: propertyTitle ?? "Rental inquiry",
                    renterName: request.tenantName,
                    statusTitle: request.status.title
                )
            }

        return ViewingScheduleSnapshot(
            managerId: managerId,
            date: date,
            availabilityDays: availabilityDays,
            agendaItems: agendaItems
        )
    }

    static func defaultProfile(for property: Property, managerId: String) -> AvailabilityProfile {
        AvailabilityProfile(
            id: "availability__\(property.id)",
            managerId: managerId,
            propertyId: property.id,
            timezoneIdentifier: "America/Toronto",
            slotDurationMinutes: 45,
            bufferMinutes: 15,
            minimumNoticeHours: 24,
            bookingHorizonDays: 21,
            maximumDailyViewings: 6,
            bookingMode: .instant,
            weeklyRules: [
                AvailabilityRule(id: "weekday-morning", weekday: 2, startMinuteOfDay: 9 * 60, endMinuteOfDay: 12 * 60),
                AvailabilityRule(id: "weekday-afternoon", weekday: 2, startMinuteOfDay: 13 * 60, endMinuteOfDay: 17 * 60),
                AvailabilityRule(id: "weekday-morning-2", weekday: 4, startMinuteOfDay: 9 * 60, endMinuteOfDay: 12 * 60),
                AvailabilityRule(id: "weekday-afternoon-2", weekday: 4, startMinuteOfDay: 13 * 60, endMinuteOfDay: 17 * 60)
            ],
            exceptions: []
        )
    }
}

struct ViewingBookingSnapshot: Equatable {
    let requestId: String
    let propertyTitle: String
    let slots: [ViewingSlot]

    var canBook: Bool {
        !slots.isEmpty
    }

    init(request: Request, property: Property?, date: Date) {
        requestId = request.id
        propertyTitle = property?.title ?? "Rental inquiry"

        if let property, request.status == .acknowledged {
            slots = ViewingScheduleSnapshot
                .defaultProfile(for: property, managerId: request.landlordId)
                .availableSlots(on: date)
                .filter(\.isInstantReservable)
        } else {
            slots = []
        }
    }
}
