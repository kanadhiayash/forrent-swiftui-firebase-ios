//
//  RequestViewModel.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-21.
//

import Foundation
import Combine
import FirebaseFirestore

@MainActor
class RequestViewModel: ObservableObject {
    private let environment: AppEnvironment
    
    @Published var requests: [Request] = []
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var isLoading = false
    
    private var listener: ListenerRegistration?
    private var listeningUserId: String?

    init(environment: AppEnvironment? = nil) {
        self.environment = environment ?? .firebase
    }
    
    // MARK: REAL-TIME LISTENER
    func startListening(for user: AppUser?) {
        if let demoSession = environment.demoSession {
            listener?.remove()
            listener = nil
            listeningUserId = user?.id
            requests = demoSession.requests(for: user)
            return
        }

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
            status: .submitted
        )
        
        isLoading = true
        errorMessage = nil
        requests.append(newRequest)
        
        do {
            if let demoSession = environment.demoSession {
                _ = try demoSession.createRequest(property: property, user: user)
                requests = demoSession.requests(for: user)
                successMessage = "Request sent."
                isLoading = false
                return
            }

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
        guard let currentUser else {
            errorMessage = "Sign in to update this inquiry."
            return
        }

        let landlordCanUpdate = currentUser.role == .landlord &&
            currentUser.id == request.landlordId &&
            status != .cancelled
        let renterCanCancel = currentUser.role == .tenant &&
            currentUser.id == request.tenantId &&
            status == .cancelled

        guard landlordCanUpdate || renterCanCancel else {
            errorMessage = "This account cannot make that inquiry change."
            return
        }

        guard request.status.canTransition(to: status) else {
            errorMessage = "That inquiry change is no longer available."
            return
        }
        
        guard let index = requests.firstIndex(where: { $0.id == request.id }) else { return }
        let oldStatus = requests[index].status
        
        requests[index].status = status
        isLoading = true
        errorMessage = nil
        
        do {
            if let demoSession = environment.demoSession {
                demoSession.updateRequestStatus(requestId: request.id, status: status)
                requests = demoSession.requests(for: currentUser)
                successMessage = "Inquiry marked \(status.title.lowercased())."
                isLoading = false
                return
            }

            try await FirestoreService.shared.updateRequestStatus(request, status: status)
            successMessage = "Inquiry marked \(status.title.lowercased())."
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

    func acknowledge(_ request: Request, currentUser: AppUser?) async {
        await update(request, status: .acknowledged, currentUser: currentUser)
    }

    func scheduleViewing(_ request: Request, currentUser: AppUser?) async {
        await update(request, status: .viewingScheduled, currentUser: currentUser)
    }

    func cancel(_ request: Request, currentUser: AppUser?) async {
        await update(request, status: .cancelled, currentUser: currentUser)
    }
}
