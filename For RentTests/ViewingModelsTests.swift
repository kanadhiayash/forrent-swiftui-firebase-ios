import XCTest
@testable import For_Rent

final class ViewingModelsTests: XCTestCase {
    func test_weeklyAvailabilityCreatesInstantReservableSlotsWithBuffers() throws {
        let calendar = Calendar(identifier: .gregorian)
        let day = try XCTUnwrap(calendar.date(from: DateComponents(
            timeZone: .init(identifier: "America/Toronto"),
            year: 2026,
            month: 7,
            day: 15,
            hour: 0
        )))
        let profile = AvailabilityProfile(
            id: "availability-1",
            managerId: "manager-1",
            propertyId: "property-1",
            timezoneIdentifier: "America/Toronto",
            slotDurationMinutes: 30,
            bufferMinutes: 15,
            minimumNoticeHours: 12,
            bookingHorizonDays: 21,
            maximumDailyViewings: 4,
            bookingMode: .instant,
            weeklyRules: [
                AvailabilityRule(
                    weekday: 4,
                    startMinuteOfDay: 9 * 60,
                    endMinuteOfDay: 11 * 60
                )
            ],
            exceptions: []
        )

        let slots = profile.availableSlots(on: day)

        XCTAssertEqual(slots.map(\.startMinuteOfDay), [540, 585, 630])
        XCTAssertTrue(slots.allSatisfy(\.isInstantReservable))
    }

    func test_blackoutExceptionRemovesDaySlots() throws {
        let calendar = Calendar(identifier: .gregorian)
        let day = try XCTUnwrap(calendar.date(from: DateComponents(
            timeZone: .init(identifier: "America/Toronto"),
            year: 2026,
            month: 7,
            day: 15,
            hour: 0
        )))
        let profile = AvailabilityProfile(
            id: "availability-1",
            managerId: "manager-1",
            propertyId: "property-1",
            timezoneIdentifier: "America/Toronto",
            slotDurationMinutes: 30,
            bufferMinutes: 0,
            minimumNoticeHours: 12,
            bookingHorizonDays: 21,
            maximumDailyViewings: 4,
            bookingMode: .instant,
            weeklyRules: [
                AvailabilityRule(
                    weekday: 4,
                    startMinuteOfDay: 9 * 60,
                    endMinuteOfDay: 11 * 60
                )
            ],
            exceptions: [
                AvailabilityException(
                    id: "blackout-1",
                    startsAt: day,
                    endsAt: day.addingTimeInterval(24 * 60 * 60),
                    kind: .blackout
                )
            ]
        )

        XCTAssertTrue(profile.availableSlots(on: day).isEmpty)
    }

    func test_viewingStateMachineAllowsCompletionOnlyFromConfirmedAfterEnd() throws {
        var viewing = Viewing(
            id: "viewing-1",
            propertyId: "property-1",
            conversationId: "conversation-1",
            renterId: "renter-1",
            managerId: "manager-1",
            startAt: referenceDate,
            endAt: referenceDate.addingTimeInterval(30 * 60),
            timezoneIdentifier: "America/Toronto",
            status: .reserved
        )

        XCTAssertThrowsError(try viewing.complete(at: referenceDate.addingTimeInterval(31 * 60)))
        try viewing.confirm()
        XCTAssertThrowsError(try viewing.complete(at: referenceDate.addingTimeInterval(29 * 60)))
        try viewing.complete(at: referenceDate.addingTimeInterval(31 * 60))

        XCTAssertEqual(viewing.status, .completed)
    }

    func test_groupViewingCapacityControlsSlotReservation() {
        let slot = ViewingSlot(
            id: "slot-1",
            profileId: "availability-1",
            propertyId: "property-1",
            startsAt: referenceDate,
            endsAt: referenceDate.addingTimeInterval(30 * 60),
            timezoneIdentifier: "America/Toronto",
            capacity: 2,
            reservedCount: 1,
            bookingMode: .instant
        )

        XCTAssertTrue(slot.canReserve)
        XCTAssertTrue(slot.isInstantReservable)
        XCTAssertFalse(slot.reservingOneMore().canReserve)
    }
}

private extension ViewingModelsTests {
    var referenceDate: Date {
        Date(timeIntervalSince1970: 1_800_000_000)
    }
}
