//
//  ImageManager.swift
//  FourRent
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
        let url = getDocumentsDirectory().appendingPathComponent(name)
        return UIImage(contentsOfFile: url.path)
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
