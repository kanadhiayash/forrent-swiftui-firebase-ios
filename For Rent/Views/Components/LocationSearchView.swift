//
//  LocationSearchView.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI
import MapKit

struct LocationSearchView: View {
    
    @Binding var query: String
    @Binding var latitude: Double
    @Binding var longitude: Double
    
    @State private var results: [MKMapItem] = []
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            TextField("Search location", text: $query)
                .textFieldStyle(.roundedBorder)
                .onChange(of: query) { _, newValue in
                    searchLocation(newValue)
                }
            
            ForEach(results, id: \.self) { item in
                Button {
                    selectLocation(item)
                } label: {
                    Text(item.name ?? "Unknown")
                        .font(.subheadline)
                }
            }
        }
    }
    
    // SEARCH
    private func searchLocation(_ text: String) {
        
        guard !text.isEmpty else {
            results = []
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = text
        
        MKLocalSearch(request: request).start { response, _ in
            results = response?.mapItems ?? []
        }
    }
    
    // SELECT
    private func selectLocation(_ item: MKMapItem) {
        let coordinate = coordinate(for: item)
        latitude = coordinate.latitude
        longitude = coordinate.longitude
        query = item.name ?? ""
        results = []
    }
    
    private func coordinate(for item: MKMapItem) -> CLLocationCoordinate2D {
        if #available(iOS 26.0, *) {
            return item.location.coordinate
        } else {
            return legacyCoordinate(for: item)
        }
    }
    
    @available(iOS, introduced: 2.0, deprecated: 26.0)
    private func legacyCoordinate(for item: MKMapItem) -> CLLocationCoordinate2D {
        item.placemark.coordinate
    }
}
