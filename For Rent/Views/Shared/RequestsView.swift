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
        
        let user = authVM.user
            
        let filteredRequests = requestVM.requests.filter { request in
            if user?.role == .landlord {
                return request.landlordId == user?.id
            } else {
                return request.tenantId == user?.id
            }
        }
            
        Group {
            if requestVM.isLoading {
                LoadingView()
            } else if filteredRequests.isEmpty {
                ContentUnavailableView {
                    Label("No inquiries yet", systemImage: "bubble.left.and.bubble.right")
                } description: {
                    Text(user?.role == .landlord
                         ? "Renter inquiries will appear here."
                         : "Request a viewing from a listing to track it here.")
                }
            } else {
                
                List(filteredRequests) { request in
                    
                    VStack(alignment: .leading, spacing: 10) {
                        
                        if let property = propertyVM.properties.first(where: {
                            $0.id == request.propertyId
                        }) {
                            Text(property.title)
                                .font(.headline)
                        }
                        
                        if user?.role == .landlord {
                            Text("Renter: \(request.tenantName)")
                            Text("Phone: \(request.tenantPhone)")
                        }
                        
                        StatusChip(
                            title: request.status.title,
                            systemImage: statusIcon(for: request.status),
                            tone: statusTone(for: request.status)
                        )

                        if user?.role == .landlord, !landlordNextStatuses(for: request).isEmpty {
                            Menu("Update inquiry") {
                                ForEach(landlordNextStatuses(for: request), id: \.self) { status in
                                    Button(status.title) {
                                        Task {
                                            await requestVM.update(
                                                request,
                                                status: status,
                                                currentUser: authVM.user
                                            )
                                            if status == .accepted {
                                                await propertyVM.fetchProperties(for: authVM.user)
                                            }
                                        }
                                    }
                                }
                            }
                            .buttonStyle(.bordered)
                        } else if user?.role == .tenant,
                                  request.status.canTransition(to: .cancelled) {
                            Button("Cancel inquiry", role: .destructive) {
                                Task {
                                    await requestVM.cancel(request, currentUser: authVM.user)
                                }
                            }
                            .buttonStyle(.borderless)
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

    private func landlordNextStatuses(for request: Request) -> [RequestStatus] {
        let landlordManaged: [RequestStatus] = [
            .acknowledged,
            .viewingScheduled,
            .accepted,
            .rejected
        ]
        return landlordManaged.filter { request.status.canTransition(to: $0) }
    }

    private func statusIcon(for status: RequestStatus) -> String {
        switch status {
        case .submitted: "paperplane.fill"
        case .acknowledged: "checkmark.message.fill"
        case .viewingScheduled: "calendar.badge.clock"
        case .accepted: "checkmark.circle.fill"
        case .rejected: "xmark.circle.fill"
        case .cancelled: "slash.circle.fill"
        case .expired: "clock.badge.xmark.fill"
        }
    }

    private func statusTone(for status: RequestStatus) -> StatusChipTone {
        switch status {
        case .submitted, .acknowledged, .viewingScheduled: .info
        case .accepted: .success
        case .rejected: .danger
        case .cancelled, .expired: .neutral
        }
    }
}
