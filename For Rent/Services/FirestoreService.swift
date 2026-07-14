//
//  FirestoreService.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import FirebaseFirestore
import FirebaseFunctions

enum FirestoreServiceError: LocalizedError {
    case duplicateRequest
    case invalidRole
    
    var errorDescription: String? {
        switch self {
        case .duplicateRequest:
            return "You already sent a request for this property."
        case .invalidRole:
            return "This account does not have permission to perform that action."
        }
    }
}

class FirestoreService {
    
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    private let functions = Functions.functions()
    
    static func requestId(tenantId: String, propertyId: String) -> String {
        "\(tenantId)_\(propertyId)".replacingOccurrences(of: "/", with: "_")
    }
    
    func listenToRequests(
        for user: AppUser,
        completion: @escaping (Result<[Request], Error>) -> Void
    ) -> ListenerRegistration? {
        
        let query: Query
        
        switch user.role {
        case .tenant:
            query = db.collection("requests")
                .whereField("tenantId", isEqualTo: user.id)
        case .landlord:
            query = db.collection("requests")
                .whereField("landlordId", isEqualTo: user.id)
        case .guest:
            completion(.success([]))
            return nil
        }
        
        return query
            .addSnapshotListener { snapshot, error in
                if let error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                let requests = documents.compactMap {
                    try? $0.data(as: Request.self)
                }
                
                completion(.success(requests))
            }
    }
    
    // MARK: USER
    
    func createUser(_ user: AppUser) async throws {
        try db.collection("users").document(user.id).setData(from: user)
    }
    
    func fetchUser(uid: String) async throws -> AppUser {
        let doc = try await db.collection("users").document(uid).getDocument()
        return try doc.data(as: AppUser.self)
    }
    
    func updateProfile(
        userId: String,
        firstName: String,
        lastName: String,
        phone: String
    ) async throws {
        try await db.collection("users").document(userId).updateData([
            "firstName": firstName,
            "lastName": lastName,
            "phone": phone
        ])
    }
    
    // MARK: PROPERTY 
    
    func fetchListedProperties() async throws -> [Property] {
        let snapshot = try await db.collection("properties")
            .whereField("isListed", isEqualTo: true)
            .whereField("isAssigned", isEqualTo: false)
            .getDocuments()
        
        return try snapshot.documents.compactMap {
            try $0.data(as: Property.self)
        }
    }
    
    func fetchLandlordProperties(landlordId: String) async throws -> [Property] {
        let snapshot = try await db.collection("properties")
            .whereField("landlordId", isEqualTo: landlordId)
            .getDocuments()
        
        return try snapshot.documents.compactMap {
            try $0.data(as: Property.self)
        }
    }
    
    func addProperty(_ property: Property) async throws {
        try db.collection("properties").document(property.id).setData(from: property)
    }
    
    func updateProperty(_ property: Property) async throws {
        try db.collection("properties").document(property.id).setData(from: property)
    }
    
    func deleteProperty(propertyId: String) async throws {
        try await db.collection("properties").document(propertyId).delete()
    }
    
    func updatePropertyListing(propertyId: String, isListed: Bool) async throws {
        if isListed {
            _ = try await functions.httpsCallable("publishListing").call([
                "listingId": propertyId
            ])
        } else {
            try await db.collection("properties").document(propertyId).updateData([
                "isListed": false
            ])
        }
    }
    
    // MARK: REQUEST
    
    func createRequest(_ request: Request) async throws {
        let requestId = Self.requestId(tenantId: request.tenantId, propertyId: request.propertyId)
        let requestRef = db.collection("requests").document(requestId)
        let existingDocument = try await requestRef.getDocument()
        
        guard !existingDocument.exists else {
            throw FirestoreServiceError.duplicateRequest
        }
        
        var requestToCreate = request
        requestToCreate.id = requestId
        try requestRef.setData(from: requestToCreate)
    }
    
    func updateRequestStatus(_ request: Request, status: RequestStatus) async throws {
        _ = try await functions.httpsCallable("transitionInquiry").call([
            "requestId": request.id,
            "status": status.rawValue
        ])
    }
    
    // MARK: SHORTLIST
    
    func updateShortlist(userId: String, propertyId: String) async throws {
        try await db.collection("users")
            .document(userId)
            .collection("savedListings")
            .document(propertyId)
            .setData([
                "listingId": propertyId,
                "savedAt": FieldValue.serverTimestamp()
            ])
    }
    
    func removeFromShortlist(userId: String, propertyId: String) async throws {
        try await db.collection("users")
            .document(userId)
            .collection("savedListings")
            .document(propertyId)
            .delete()
    }

    func fetchShortlistedPropertyIds(userId: String) async throws -> [String] {
        let snapshot = try await db.collection("users")
            .document(userId)
            .collection("savedListings")
            .getDocuments()

        return snapshot.documents.map(\.documentID)
    }
}
