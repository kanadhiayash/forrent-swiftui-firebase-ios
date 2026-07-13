import XCTest
@testable import For_Rent

final class ViewingSchedulePresentationTests: XCTestCase {
    func test_managerCalendarCreatesInstantAvailabilityPerManagedProperty() {
        let snapshot = ViewingScheduleSnapshot.managerCalendar(
            managerId: "landlord-1",
            properties: [property(id: "p1"), property(id: "p2"), property(id: "other", landlordId: "landlord-2")],
            requests: [],
            date: monday()
        )

        XCTAssertEqual(snapshot.availabilityDays.map(\.propertyId), ["p1", "p2"])
        XCTAssertTrue(snapshot.hasConfiguredAvailability)
        XCTAssertTrue(snapshot.availabilityDays.allSatisfy { $0.summary.contains("instant-book") })
    }

    func test_managerAgendaIncludesOnlyScheduledViewingsForManager() {
        let requests = [
            request(id: "scheduled", status: .viewingScheduled),
            request(id: "submitted", status: .submitted),
            request(id: "other", landlordId: "landlord-2", status: .viewingScheduled)
        ]

        let snapshot = ViewingScheduleSnapshot.managerCalendar(
            managerId: "landlord-1",
            properties: [property(id: "p1")],
            requests: requests,
            date: monday()
        )

        XCTAssertEqual(snapshot.agendaItems.map(\.requestId), ["scheduled"])
        XCTAssertEqual(snapshot.agendaItems[0].statusTitle, "Viewing scheduled")
    }

    func test_bookingSnapshotAllowsOnlyAcknowledgedInstantSlots() {
        let acknowledged = ViewingBookingSnapshot(
            request: request(id: "ack", status: .acknowledged),
            property: property(id: "p1"),
            date: monday()
        )
        let submitted = ViewingBookingSnapshot(
            request: request(id: "submitted", status: .submitted),
            property: property(id: "p1"),
            date: monday()
        )

        XCTAssertTrue(acknowledged.canBook)
        XCTAssertFalse(submitted.canBook)
    }

    private func monday() -> Date {
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = TimeZone(identifier: "America/Toronto")
        components.year = 2026
        components.month = 7
        components.day = 13
        return components.date!
    }

    private func property(id: String, landlordId: String = "landlord-1") -> Property {
        Property(
            id: id,
            title: "Listing \(id)",
            details: "Demo listing.",
            rent: 2400,
            bedrooms: 1,
            bathrooms: 1,
            latitude: 43.64,
            longitude: -79.38,
            imageNames: [],
            landlordId: landlordId,
            isListed: true,
            isAssigned: false,
            locationName: "Toronto, ON"
        )
    }

    private func request(
        id: String,
        landlordId: String = "landlord-1",
        status: RequestStatus
    ) -> Request {
        Request(
            id: id,
            propertyId: "p1",
            landlordId: landlordId,
            tenantId: "tenant-1",
            tenantName: "Avery",
            tenantPhone: "555-0100",
            status: status
        )
    }
}
