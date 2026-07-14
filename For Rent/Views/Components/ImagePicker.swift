//
//  ImagePicker.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI
import PhotosUI

struct ImagePicker: View {
    
    @Binding var selectedImages: [UIImage]
    @State private var pickerItems: [PhotosPickerItem] = []
    
    var body: some View {
        
        PhotosPicker(
            selection: $pickerItems,
            maxSelectionCount: 5,
            matching: .images
        ) {
            Label("Select Images", systemImage: "photo")
                .font(.body)
        }
        .onChange(of: pickerItems) { _, newItems in
            Task {
                selectedImages.removeAll()
                
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImages.append(image)
                    }
                }
            }
        }
    }
}
