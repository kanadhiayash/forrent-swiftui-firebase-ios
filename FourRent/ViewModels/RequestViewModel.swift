//
//  RequestViewModel.swift
//  FourRent
//
//  Created by Yash Kanadhia on 2026-03-21.
//

import Foundation
import Combine
import FirebaseFirestore

@MainActor
class RequestViewModel: ObservableObject {
    
    @Published var requests: [Request] = []
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var isLoading = false
    
    private var listener: ListenerRegistration?
    private var listeningUserId: String?
    
    // MARK: REAL-TIME LISTENER
    func startListening(for user: AppUser?) {
        guard let user, user.role != .guest else {
            listener?.remove()
            listener = nil
            listeningUserId = nil
            requests = []
            return
        }
        
        guard listeningUserId != user.id else { return }
        
        listener?.remove()
        listener = nil
        listeningUserId = user.id
        
        listener = FirestoreService.shared.listenToRequests(for: user) { [weak self] result in
            Task { @MainActor in
                guard let self else { return }
                
                switch result {
                case .success(let requests):
                    self.errorMessage = nil
                    self.requests = requests
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.requests = []
                }
            }
        }
    }
    
    // MARK: SEND REQUEST
    func sendRequest(property: Property, user: AppUser) async {
        guard user.role == .tenant else {
            errorMessage = "Please sign in as a tenant to send rental requests."
            return
        }
        
        guard property.isListed, !property.isAssigned else {
            errorMessage = "This property is not currently available."
            return
        }
        
        let requestId = FirestoreService.requestId(tenantId: user.id, propertyId: property.id)
        
        guard requests.first(where: { $0.id == requestId || ($0.propertyId == property.id && $0.tenantId == user.id) }) == nil else {
            errorMessage = "You already sent a request for this property."
            return
        }
        
        let newRequest = Request(
            id: requestId,
            propertyId: property.id,
            landlordId: property.landlordId,
            tenantId: user.id,
            tenantName: user.firstName,
            tenantPhone: user.phone,
            status: .pending
        )
        
        isLoading = true
        errorMessage = nil
        requests.append(newRequest)
        
        do {
            try await FirestoreService.shared.createRequest(newRequest)
            successMessage = "Request sent."
        } catch {
            requests.removeAll { $0.id == newRequest.id }
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: UPDATE STATUS
    func update(_ request: Request, status: RequestStatus, currentUser: AppUser?) async {
        guard currentUser?.role == .landlord, currentUser?.id == request.landlordId else {
            errorMessage = "Only the receiving landlord can update this request."
            return
        }
        
        guard let index = requests.firstIndex(where: { $0.id == request.id }) else { return }
        let oldStatus = requests[index].status
        
        requests[index].status = status
        isLoading = true
        errorMessage = nil
        
        do {
            try await FirestoreService.shared.updateRequestStatus(request, status: status)
            successMessage = status == .accepted ? "Request accepted." : "Request denied."
        } catch {
            requests[index].status = oldStatus
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func accept(_ request: Request, currentUser: AppUser?) async {
        await update(request, status: .accepted, currentUser: currentUser)
    }
    
    func reject(_ request: Request, currentUser: AppUser?) async {
        await update(request, status: .rejected, currentUser: currentUser)
    }
}
