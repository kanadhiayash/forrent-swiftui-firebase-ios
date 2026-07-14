//
//  Request.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import Foundation

struct Request: Identifiable, Codable {
    
    var id: String
    var propertyId: String
    
    var landlordId: String
    
    var tenantId: String
    var tenantName: String
    var tenantPhone: String
    
    var status: RequestStatus

    var intent: RequestIntent?
    var tenantEmail: String?
    var partySize: Int?
    var message: String?
    var preferredViewingDate: Date?
    var startDate: Date?
    var endDate: Date?
    var createdAt: Date?
    var updatedAt: Date?
    var decisionAt: Date?

    var resolvedIntent: RequestIntent {
        intent ?? .booking
    }

    var resolvedPartySize: Int {
        max(partySize ?? 1, 1)
    }

    var hasStayRange: Bool {
        guard let startDate, let endDate else { return false }
        return endDate > startDate
    }

    func overlaps(start: Date, end: Date) -> Bool {
        guard let startDate, let endDate else { return false }
        return startDate < end && start < endDate
    }
}
