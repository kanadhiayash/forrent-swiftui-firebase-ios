//
//  RequestStatus.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-21.
//

import Foundation

enum RequestStatus: String, Codable, CaseIterable {
    case submitted
    case acknowledged
    case viewingScheduled = "viewing_scheduled"
    case accepted = "accepted"
    case rejected = "rejected"
    case cancelled = "cancelled"
    case expired

    var title: String {
        switch self {
        case .submitted: "Submitted"
        case .acknowledged: "Acknowledged"
        case .viewingScheduled: "Viewing scheduled"
        case .accepted: "Accepted"
        case .rejected: "Rejected"
        case .cancelled: "Cancelled"
        case .expired: "Expired"
        }
    }

    func canTransition(to next: RequestStatus) -> Bool {
        switch (self, next) {
        case (.submitted, .acknowledged),
             (.submitted, .rejected),
             (.submitted, .cancelled),
             (.submitted, .expired),
             (.acknowledged, .viewingScheduled),
             (.acknowledged, .accepted),
             (.acknowledged, .rejected),
             (.acknowledged, .cancelled),
             (.acknowledged, .expired),
             (.viewingScheduled, .accepted),
             (.viewingScheduled, .rejected),
             (.viewingScheduled, .cancelled),
             (.viewingScheduled, .expired):
            true
        default:
            false
        }
    }
}

enum RequestIntent: String, Codable, CaseIterable, Identifiable {
    case viewing
    case booking

    var id: String { rawValue }

    var title: String {
        switch self {
        case .viewing:
            return "Schedule a viewing"
        case .booking:
            return "Request to rent"
        }
    }
}
