//
//  MapView.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    var latitude: Double
    var longitude: Double
    
    var body: some View {
        
        Map {
            Marker("Property", coordinate: CLLocationCoordinate2D(
                latitude: latitude,
                longitude: longitude
            ))
        }
        .frame(height: 200)
        .cornerRadius(12)
    }
}
