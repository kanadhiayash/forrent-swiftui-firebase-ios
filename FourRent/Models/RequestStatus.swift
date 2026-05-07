//
//  RequestStatus.swift
//  FourRent
//
//  Created by Yash Kanadhia on 2026-03-21.
//

import Foundation

enum RequestStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case accepted = "accepted"
    case rejected = "rejected"
}
