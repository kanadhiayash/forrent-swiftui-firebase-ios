//
//  RequestsView.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI

struct RequestsView: View {
    
    @EnvironmentObject var requestVM: RequestViewModel
    @EnvironmentObject var propertyVM: PropertyViewModel
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        
        NavigationStack {
            
            let user = authVM.user
            
            let filteredRequests = requestVM.requests.filter { request in
                if user?.role == .landlord {
                    return request.landlordId == user?.id
                } else {
                    return request.tenantId == user?.id
                }
            }
            
            if requestVM.isLoading {
                LoadingView()
            } else if filteredRequests.isEmpty {
                Text("No requests yet")
                    .foregroundColor(.gray)
            } else {
                
                List(filteredRequests) { request in
                    
                    VStack(alignment: .leading, spacing: 10) {
                        
                        if let property = propertyVM.properties.first(where: {
                            $0.id == request.propertyId
                        }) {
                            Text(property.title)
                                .font(.headline)
                        }
                        
                        Text("Tenant: \(request.tenantName)")
                        Text("Phone: \(request.tenantPhone)")
                        
                        Text("Status: \(request.status.rawValue.capitalized)")
                            .foregroundColor(.gray)
                        
                        if user?.role == .landlord, request.status == .pending {
                            HStack {
                                
                                Button("Accept") {
                                    Task {
                                        await requestVM.accept(request, currentUser: authVM.user)
                                        await propertyVM.fetchProperties(for: authVM.user)
                                    }
                                }
                                
                                Button("Reject") {
                                    Task {
                                        await requestVM.reject(request, currentUser: authVM.user)
                                    }
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.vertical, 6)
                    .accessibilityElement(children: .combine)
                }
            }
        }
        .navigationTitle("Requests")
        .task {
            requestVM.startListening(for: authVM.user)
            await propertyVM.fetchProperties(for: authVM.user)
        }
        .showError($requestVM.errorMessage)
    }
}
