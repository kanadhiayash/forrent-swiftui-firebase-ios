//
//  RequestStatus.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-21.
//

import Foundation

enum RequestStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case accepted = "accepted"
    case rejected = "rejected"
    case cancelled = "cancelled"
    case completed = "completed"
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
