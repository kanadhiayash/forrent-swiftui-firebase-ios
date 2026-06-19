//
//  PropertyDetailView.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI

struct PropertyDetailView: View {
    
    let property: Property
    let user: AppUser
    
    @EnvironmentObject var requestVM: RequestViewModel
    @EnvironmentObject var shortlistVM: ShortlistViewModel
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var protectedActionMessage: String?
    
    var body: some View {
        
        ScrollView {
            
            VStack(spacing: 16) {
                
                // IMAGE CAROUSEL
                TabView {
                    ForEach(property.imageNames, id: \.self) { imageName in
                        if let image = ImageManager.shared.loadImage(name: imageName) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 250)
                                .clipped()
                        }
                    }
                }
                .frame(height: 250)
                .tabViewStyle(.page)
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    Text(property.title)
                        .font(.title.bold())
                    
                    Text("$\(property.rent, specifier: "%.0f") / month")
                        .bold()
                    
                    HStack {
                        Label("\(property.bedrooms)", systemImage: "bed.double")
                        Label("\(property.bathrooms)", systemImage: "bathtub")
                    }
                    
                    // SHORTLIST BUTTON
                    Button {
                        guard authVM.user?.role == .tenant else {
                            protectedActionMessage = "Please sign in as a tenant to save properties."
                            return
                        }
                        
                        Task {
                            await shortlistVM.toggle(propertyId: property.id, userId: authVM.user?.id)
                        }
                    } label: {
                        Label(
                            shortlistVM.isSaved(property.id) ? "Saved" : "Save",
                            systemImage: shortlistVM.isSaved(property.id) ? "heart.fill" : "heart"
                        )
                    }
                    .accessibilityLabel(shortlistVM.isSaved(property.id) ? "Remove from saved properties" : "Save property")
                    
                    // REQUEST BUTTON (LIVE STATE)
                    if user.role == .tenant {
                        
                        let myRequest = requestVM.requests.first {
                            $0.propertyId == property.id &&
                            $0.tenantId == user.id
                        }
                        
                        if let request = myRequest {
                            
                            Text("Status: \(request.status.rawValue.capitalized)")
                                .foregroundColor(.gray)
                            
                        } else {
                            
                            Button("Request to Connect") {
                                Task {
                                    await requestVM.sendRequest(property: property, user: user)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(requestVM.isLoading)
                        }
                    } else if user.role == .guest {
                        Button("Sign in to request") {
                            authVM.logout()
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    // SHARE (Guest allowed)
                    Button("Share Property") {
                        share()
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Details")
        .task {
            requestVM.startListening(for: authVM.user ?? user)
        }
        .alert("Action requires sign in", isPresented: Binding(
            get: { protectedActionMessage != nil },
            set: { if !$0 { protectedActionMessage = nil } }
        )) {
            Button("Sign In") {
                authVM.logout()
            }
            Button("Cancel", role: .cancel) {
                protectedActionMessage = nil
            }
        } message: {
            Text(protectedActionMessage ?? "")
        }
        .showError($requestVM.errorMessage)
        .showError($shortlistVM.errorMessage)
    }
    
    private func share() {
        let text = "\(property.title) - $\(property.rent)"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return
        }
        
        root.present(activityVC, animated: true)
    }
}
