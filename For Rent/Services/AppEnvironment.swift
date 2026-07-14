import Foundation

struct AppEnvironment {
    enum Mode {
        case firebase
        case demo
    }

    let mode: Mode
    let demoSession: DemoSession?

    static let firebase = AppEnvironment(mode: .firebase, demoSession: nil)

    static func demo(seed: DemoSeed) -> AppEnvironment {
        AppEnvironment(mode: .demo, demoSession: DemoSession(seed: seed))
    }

    static func detect(bundle: Bundle = .main) throws -> AppEnvironment {
        try detect {
            try DemoSeed.data(from: bundle)
        }
    }

    static func detect(seedData: () throws -> Data?) throws -> AppEnvironment {
        guard let data = try seedData() else {
            return .firebase
        }

        return .demo(seed: try DemoSeed.decode(data: data))
    }

    var isDemo: Bool {
        mode == .demo
    }

    var isFirebase: Bool {
        mode == .firebase
    }
}

struct DemoSeed: Decodable {
    struct Personas: Decodable {
        let guest: AppUser
        let tenant: AppUser
        let landlord: AppUser

        var allUsers: [AppUser] {
            [guest, tenant, landlord]
        }
    }

    static let fileName = "DemoSeed"

    let personas: Personas
    let properties: [Property]
    let requests: [Request]

    static func decode(data: Data) throws -> DemoSeed {
        try JSONDecoder().decode(DemoSeed.self, from: data)
    }

    static func data(from bundle: Bundle) throws -> Data? {
        let candidateURLs = [
            bundle.url(forResource: fileName, withExtension: "json"),
            bundle.url(forResource: fileName, withExtension: "json", subdirectory: "Resources"),
            bundle.bundleURL.appendingPathComponent("\(fileName).json"),
            bundle.bundleURL.appendingPathComponent("Resources").appendingPathComponent("\(fileName).json")
        ]

        guard let fixtureURL = candidateURLs
            .compactMap({ $0 })
            .first(where: { FileManager.default.fileExists(atPath: $0.path) }) else {
            return nil
        }

        return try Data(contentsOf: fixtureURL)
    }
}

final class DemoSession {
    private let seed: DemoSeed

    private var personas: DemoSeed.Personas
    private(set) var properties: [Property]
    private(set) var requests: [Request]
    private(set) var currentUser: AppUser?

    init(seed: DemoSeed) {
        self.seed = seed
        self.personas = seed.personas
        self.properties = seed.properties
        self.requests = seed.requests
    }

    var demoUsers: [AppUser] {
        personas.allUsers
    }

    func selectUser(id: String) -> AppUser? {
        currentUser = user(id: id)
        return currentUser
    }

    func continueAsGuest() -> AppUser {
        selectUser(id: personas.guest.id) ?? personas.guest
    }

    func clearSelectedUser() {
        currentUser = nil
    }

    func reset() {
        let selectedUserId = currentUser?.id

        personas = seed.personas
        properties = seed.properties
        requests = seed.requests

        if let selectedUserId {
            currentUser = user(id: selectedUserId)
        } else {
            currentUser = nil
        }
    }

    func user(id: String) -> AppUser? {
        demoUsers.first(where: { $0.id == id })
    }

    func updateProfile(
        userId: String,
        firstName: String,
        lastName: String,
        phone: String
    ) -> AppUser? {
        guard var user = user(id: userId) else { return nil }

        user.firstName = firstName
        user.lastName = lastName
        user.phone = phone

        replace(user: user)
        return user
    }

    func shortlistedIds(for userId: String) -> Set<String> {
        Set(user(id: userId)?.shortlisted ?? [])
    }

    func toggleShortlist(propertyId: String, userId: String) -> Set<String> {
        guard var user = user(id: userId) else { return [] }

        if let existingIndex = user.shortlisted.firstIndex(of: propertyId) {
            user.shortlisted.remove(at: existingIndex)
        } else {
            user.shortlisted.append(propertyId)
        }

        replace(user: user)
        return Set(user.shortlisted)
    }

    func properties(for user: AppUser?) -> [Property] {
        guard let user else {
            return properties
        }

        switch user.role {
        case .landlord:
            return properties.filter { $0.landlordId == user.id }
        case .tenant, .guest:
            return properties
        }
    }

    func addProperty(_ property: Property) {
        properties.append(property)
    }

    func updateProperty(_ property: Property) {
        guard let index = properties.firstIndex(where: { $0.id == property.id }) else { return }
        properties[index] = property
    }

    func deleteProperty(propertyId: String) {
        properties.removeAll { $0.id == propertyId }
        requests.removeAll { $0.propertyId == propertyId }
    }

    func updatePropertyListing(propertyId: String, isListed: Bool) {
        guard let index = properties.firstIndex(where: { $0.id == propertyId }) else { return }
        properties[index].isListed = isListed
    }

    func requests(for user: AppUser?) -> [Request] {
        guard let user else { return [] }

        switch user.role {
        case .tenant:
            return requests.filter { $0.tenantId == user.id }
        case .landlord:
            return requests.filter { $0.landlordId == user.id }
        case .guest:
            return []
        }
    }

    func createRequest(property: Property, user: AppUser) throws -> Request {
        let requestId = FirestoreService.requestId(tenantId: user.id, propertyId: property.id)

        guard !requests.contains(where: {
            $0.id == requestId || ($0.propertyId == property.id && $0.tenantId == user.id)
        }) else {
            throw FirestoreServiceError.duplicateRequest
        }

        let request = Request(
            id: requestId,
            propertyId: property.id,
            landlordId: property.landlordId,
            tenantId: user.id,
            tenantName: user.firstName,
            tenantPhone: user.phone,
            status: .submitted
        )

        requests.append(request)
        return request
    }

    func updateRequestStatus(requestId: String, status: RequestStatus) {
        guard let requestIndex = requests.firstIndex(where: { $0.id == requestId }) else { return }

        requests[requestIndex].status = status

        guard status == .accepted,
              let propertyIndex = properties.firstIndex(where: { $0.id == requests[requestIndex].propertyId }) else {
            return
        }

        properties[propertyIndex].isAssigned = true
        properties[propertyIndex].isListed = false
    }

    private func replace(user: AppUser) {
        switch user.role {
        case .guest:
            personas = .init(guest: user, tenant: personas.tenant, landlord: personas.landlord)
        case .tenant:
            personas = .init(guest: personas.guest, tenant: user, landlord: personas.landlord)
        case .landlord:
            personas = .init(guest: personas.guest, tenant: personas.tenant, landlord: user)
        }

        if currentUser?.id == user.id {
            currentUser = user
        }
    }
}
