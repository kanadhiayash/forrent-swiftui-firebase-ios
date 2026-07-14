import Foundation
import FirebaseStorage
import UIKit

final class ListingMediaService {
    static let shared = ListingMediaService()

    private let storage = Storage.storage()

    private init() {}

    func upload(
        images: [UIImage],
        landlordId: String,
        listingId: String
    ) async throws -> [String] {
        var references: [String] = []

        for (index, image) in images.enumerated() {
            guard let data = image.jpegData(compressionQuality: 0.82) else { continue }

            let path = "listing-media/\(landlordId)/\(listingId)/\(index)-\(UUID().uuidString).jpg"
            let reference = storage.reference(withPath: path)
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"

            _ = try await reference.putDataAsync(data, metadata: metadata)
            references.append(path)
        }

        return references
    }

    func delete(paths: [String]) async {
        for path in paths {
            try? await storage.reference(withPath: path).delete()
        }
    }

    func downloadURL(for path: String) async throws -> URL {
        try await storage.reference(withPath: path).downloadURL()
    }
}
