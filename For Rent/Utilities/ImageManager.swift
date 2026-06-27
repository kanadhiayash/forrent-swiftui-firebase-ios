//
//  ImageManager.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import UIKit

class ImageManager {
    
    static let shared = ImageManager()
    
    private init() {}
    
    func saveImages(_ images: [UIImage]) -> [String] {
        images.map { saveImage($0) }
    }
    
    private func saveImage(_ image: UIImage) -> String {
        let name = UUID().uuidString + ".jpg"
        let url = getDocumentsDirectory().appendingPathComponent(name)
        
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: url)
        }
        
        return name
    }
    
    func loadImage(name: String) -> UIImage? {
        if let bundledImage = bundledImage(named: name) {
            return bundledImage
        }

        let url = getDocumentsDirectory().appendingPathComponent(name)
        return UIImage(contentsOfFile: url.path)
    }

    private func bundledImage(named name: String) -> UIImage? {
        let filename = (name as NSString).deletingPathExtension
        let fileExtension = (name as NSString).pathExtension
        let subdirectories = ["DemoImages", "Resources/DemoImages", nil]

        for subdirectory in subdirectories {
            if let url = Bundle.main.url(
                forResource: filename,
                withExtension: fileExtension.isEmpty ? nil : fileExtension,
                subdirectory: subdirectory
            ), let image = UIImage(contentsOfFile: url.path) {
                return image
            }
        }

        return UIImage(named: name)
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
