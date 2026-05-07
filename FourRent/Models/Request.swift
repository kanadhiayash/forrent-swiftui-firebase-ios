//
//  Request.swift
//  FourRent
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
}
