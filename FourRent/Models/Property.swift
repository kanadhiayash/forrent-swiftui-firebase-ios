//
//  Property.swift
//  FourRent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import Foundation

struct Property: Identifiable, Codable {
    
    var id: String
    
    var title: String
    var details: String
    
    var rent: Double
    
    var bedrooms: Int
    var bathrooms: Int
    
    var latitude: Double
    var longitude: Double
    
    var imageNames: [String]
    
    var landlordId: String
    
    var isListed: Bool
    var isAssigned: Bool
}
