import SwiftUI

struct ListingImageView<Placeholder: View>: View {
    let name: String
    let contentMode: ContentMode
    @ViewBuilder let placeholder: () -> Placeholder

    @State private var remoteURL: URL?
    @State private var didFail = false

    init(
        name: String,
        contentMode: ContentMode = .fill,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.name = name
        self.contentMode = contentMode
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let image = ImageManager.shared.loadImage(name: name) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if let remoteURL {
                AsyncImage(url: remoteURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: contentMode)
                    case .failure:
                        placeholder()
                    case .empty:
                        ProgressView()
                    @unknown default:
                        placeholder()
                    }
                }
            } else if didFail {
                placeholder()
            } else {
                ProgressView()
                    .task(id: name) {
                        guard name.hasPrefix("listing-media/") else {
                            didFail = true
                            return
                        }

                        do {
                            remoteURL = try await ListingMediaService.shared.downloadURL(for: name)
                        } catch {
                            didFail = true
                        }
                    }
            }
        }
    }
}
