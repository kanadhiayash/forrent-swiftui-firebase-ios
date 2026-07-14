import Foundation

enum ViewingBookingMode: String, Codable, Equatable {
    case instant
    case approvalRequired = "approval_required"
}

enum AvailabilityExceptionKind: String, Codable, Equatable {
    case blackout
}

enum ViewingStatus: String, Codable, Equatable {
    case available
    case reserved
    case confirmed
    case rescheduled
    case cancelled
    case missed
    case completed
}

enum ViewingTransitionError: LocalizedError, Equatable {
    case invalidTransition(from: ViewingStatus, to: ViewingStatus)
    case viewingHasNotEnded

    var errorDescription: String? {
        switch self {
        case let .invalidTransition(from, to):
            return "Cannot move viewing from \(from.rawValue) to \(to.rawValue)."
        case .viewingHasNotEnded:
            return "Viewing cannot be completed before its scheduled end time."
        }
    }
}

struct AvailabilityRule: Identifiable, Codable, Equatable {
    let id: String
    let weekday: Int
    let startMinuteOfDay: Int
    let endMinuteOfDay: Int

    init(
        id: String = UUID().uuidString,
        weekday: Int,
        startMinuteOfDay: Int,
        endMinuteOfDay: Int
    ) {
        self.id = id
        self.weekday = weekday
        self.startMinuteOfDay = startMinuteOfDay
        self.endMinuteOfDay = endMinuteOfDay
    }
}

struct AvailabilityException: Identifiable, Codable, Equatable {
    let id: String
    let startsAt: Date
    let endsAt: Date
    let kind: AvailabilityExceptionKind
}

struct AvailabilityProfile: Identifiable, Codable, Equatable {
    let schemaVersion: Int
    let id: String
    let managerId: String
    let propertyId: String
    let timezoneIdentifier: String
    let slotDurationMinutes: Int
    let bufferMinutes: Int
    let minimumNoticeHours: Int
    let bookingHorizonDays: Int
    let maximumDailyViewings: Int
    let bookingMode: ViewingBookingMode
    let weeklyRules: [AvailabilityRule]
    let exceptions: [AvailabilityException]

    init(
        id: String,
        managerId: String,
        propertyId: String,
        timezoneIdentifier: String,
        slotDurationMinutes: Int,
        bufferMinutes: Int,
        minimumNoticeHours: Int,
        bookingHorizonDays: Int,
        maximumDailyViewings: Int,
        bookingMode: ViewingBookingMode,
        weeklyRules: [AvailabilityRule],
        exceptions: [AvailabilityException]
    ) {
        schemaVersion = 1
        self.id = id
        self.managerId = managerId
        self.propertyId = propertyId
        self.timezoneIdentifier = timezoneIdentifier
        self.slotDurationMinutes = slotDurationMinutes
        self.bufferMinutes = bufferMinutes
        self.minimumNoticeHours = minimumNoticeHours
        self.bookingHorizonDays = bookingHorizonDays
        self.maximumDailyViewings = maximumDailyViewings
        self.bookingMode = bookingMode
        self.weeklyRules = weeklyRules
        self.exceptions = exceptions
    }

    func availableSlots(on date: Date) -> [ViewingSlot] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: timezoneIdentifier) ?? .current

        let dayStart = calendar.startOfDay(for: date)
        guard !hasBlackout(on: dayStart, calendar: calendar) else { return [] }

        let weekday = calendar.component(.weekday, from: dayStart)
        let duration = max(1, slotDurationMinutes)
        let step = duration + max(0, bufferMinutes)
        guard step > 0 else { return [] }

        let slots = weeklyRules
            .filter { $0.weekday == weekday && $0.endMinuteOfDay > $0.startMinuteOfDay }
            .flatMap { rule in
                stride(from: rule.startMinuteOfDay, through: rule.endMinuteOfDay - duration, by: step)
                    .compactMap { minute -> ViewingSlot? in
                        guard let startsAt = calendar.date(byAdding: .minute, value: minute, to: dayStart),
                              let endsAt = calendar.date(byAdding: .minute, value: duration, to: startsAt) else {
                            return nil
                        }

                        return ViewingSlot(
                            id: "\(id)__\(Int(startsAt.timeIntervalSince1970))",
                            profileId: id,
                            propertyId: propertyId,
                            startsAt: startsAt,
                            endsAt: endsAt,
                            timezoneIdentifier: timezoneIdentifier,
                            capacity: 1,
                            reservedCount: 0,
                            bookingMode: bookingMode
                        )
                    }
            }

        guard maximumDailyViewings > 0 else { return slots }
        return Array(slots.prefix(maximumDailyViewings))
    }

    private func hasBlackout(on dayStart: Date, calendar: Calendar) -> Bool {
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
            return false
        }

        return exceptions.contains { exception in
            exception.kind == .blackout &&
                exception.startsAt < dayEnd &&
                exception.endsAt > dayStart
        }
    }
}

struct ViewingSlot: Identifiable, Codable, Equatable {
    let id: String
    let profileId: String
    let propertyId: String
    let startsAt: Date
    let endsAt: Date
    let timezoneIdentifier: String
    let capacity: Int
    let reservedCount: Int
    let bookingMode: ViewingBookingMode

    var startMinuteOfDay: Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: timezoneIdentifier) ?? .current
        let components = calendar.dateComponents([.hour, .minute], from: startsAt)
        return ((components.hour ?? 0) * 60) + (components.minute ?? 0)
    }

    var canReserve: Bool {
        reservedCount < capacity
    }

    var isInstantReservable: Bool {
        bookingMode == .instant && canReserve
    }

    func reservingOneMore() -> ViewingSlot {
        ViewingSlot(
            id: id,
            profileId: profileId,
            propertyId: propertyId,
            startsAt: startsAt,
            endsAt: endsAt,
            timezoneIdentifier: timezoneIdentifier,
            capacity: capacity,
            reservedCount: reservedCount + 1,
            bookingMode: bookingMode
        )
    }
}

struct Viewing: Identifiable, Codable, Equatable {
    let schemaVersion: Int
    let id: String
    let propertyId: String
    let conversationId: String
    let renterId: String
    let managerId: String
    let startAt: Date
    let endAt: Date
    let timezoneIdentifier: String
    var status: ViewingStatus

    init(
        id: String,
        propertyId: String,
        conversationId: String,
        renterId: String,
        managerId: String,
        startAt: Date,
        endAt: Date,
        timezoneIdentifier: String,
        status: ViewingStatus
    ) {
        schemaVersion = 1
        self.id = id
        self.propertyId = propertyId
        self.conversationId = conversationId
        self.renterId = renterId
        self.managerId = managerId
        self.startAt = startAt
        self.endAt = endAt
        self.timezoneIdentifier = timezoneIdentifier
        self.status = status
    }

    mutating func confirm() throws {
        guard status == .reserved || status == .rescheduled else {
            throw ViewingTransitionError.invalidTransition(from: status, to: .confirmed)
        }

        status = .confirmed
    }

    mutating func complete(at date: Date) throws {
        guard status == .confirmed else {
            throw ViewingTransitionError.invalidTransition(from: status, to: .completed)
        }
        guard date >= endAt else {
            throw ViewingTransitionError.viewingHasNotEnded
        }

        status = .completed
    }
}
