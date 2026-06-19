//
//  Enums.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import Foundation

enum UserRole: String, Codable {
    case guest
    case tenant
    case landlord
}

enum RentalCategory: String, Codable, CaseIterable, Identifiable {
    case personalLiving = "personal_living"
    case commercial
    case temporaryRentals = "temporary_rentals"
    case couchSurfing = "couch_surfing"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .personalLiving:
            return "Personal Living"
        case .commercial:
            return "Commercial"
        case .temporaryRentals:
            return "Temporary Rentals"
        case .couchSurfing:
            return "Couch Surfing"
        }
    }

    var description: String {
        switch self {
        case .personalLiving:
            return "Homes and long-term residential spaces for everyday living."
        case .commercial:
            return "Workspaces, storefronts, studios, and small business leases."
        case .temporaryRentals:
            return "Short stays for travel, relocation, or flexible visits."
        case .couchSurfing:
            return "Host-led stays with simple sleeping arrangements and shared space."
        }
    }

    var defaultPricingCadence: PricingCadence {
        switch self {
        case .personalLiving, .commercial:
            return .monthly
        case .temporaryRentals:
            return .nightly
        case .couchSurfing:
            return .perStay
        }
    }

    var allowedPricingCadences: [PricingCadence] {
        switch self {
        case .personalLiving:
            return [.monthly]
        case .commercial:
            return [.monthly, .weekly]
        case .temporaryRentals:
            return [.nightly, .weekly]
        case .couchSurfing:
            return [.nightly, .perStay]
        }
    }

    var supportsGuestCount: Bool {
        switch self {
        case .temporaryRentals, .couchSurfing:
            return true
        case .personalLiving, .commercial:
            return false
        }
    }

    var pricingFieldLabel: String {
        switch self {
        case .personalLiving:
            return "Rent"
        case .commercial:
            return "Lease rate"
        case .temporaryRentals:
            return "Stay rate"
        case .couchSurfing:
            return "Host fee"
        }
    }
}

enum PricingCadence: String, Codable, CaseIterable, Identifiable {
    case monthly
    case weekly
    case nightly
    case perStay = "per_stay"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .monthly:
            return "Per month"
        case .weekly:
            return "Per week"
        case .nightly:
            return "Per night"
        case .perStay:
            return "Per stay"
        }
    }

    var shortLabel: String {
        switch self {
        case .monthly:
            return "/ month"
        case .weekly:
            return "/ week"
        case .nightly:
            return "/ night"
        case .perStay:
            return "/ stay"
        }
    }
}

enum AppError: LocalizedError {
    case emptyFields
    case invalidEmail
    case passwordMismatch
    case weakPassword
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .emptyFields:
            return "Please fill all fields."
        case .invalidEmail:
            return "Invalid email format."
        case .passwordMismatch:
            return "Passwords do not match."
        case .weakPassword:
            return "Password must be at least 6 characters."
        case .unknown:
            return "Something went wrong."
        }
    }
}
