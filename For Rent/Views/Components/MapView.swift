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
        
        Map(coordinateRegion: .constant(region))
        .frame(height: 200)
        .cornerRadius(12)
    }

    private var region: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: latitude,
                longitude: longitude
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    }
}
