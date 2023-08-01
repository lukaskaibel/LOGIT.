//
//  CreateTemplateMenu.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 31.07.23.
//

import OSLog
import PhotosUI
import SwiftUI

struct CreateTemplateMenu: View {
    
    @EnvironmentObject private var database: Database
    
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var workoutImage: UIImage?
    @State private var isShowingPhotosPicker = false
    @State private var isShowingTemplateEditor = false
    
    var body: some View {
        Menu {
            Button {
                isShowingTemplateEditor = true
            } label: {
                Label("Create from Scratch", systemImage: "plus")
            }
            Button {
                isShowingPhotosPicker = true
            } label: {
                Label("Create from Photo", systemImage: "photo")
            }
        } label: {
            Image(systemName: "plus")
        }
        .onChange(of: photoPickerItem) { _ in
            Task {
                if let data = try? await     photoPickerItem?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        workoutImage = uiImage
                        return
                    }
                }
                
                Logger().warning("CreateTemplateMenu: Loading image failed")
            }
        }
        .onChange(of: workoutImage) { image in
            guard let image = image else { return }
            TemplateExtractor().createTemplate(from: image)
        }
        .photosPicker(isPresented: $isShowingPhotosPicker, selection: $photoPickerItem, photoLibrary: .shared())
        .sheet(isPresented: $isShowingTemplateEditor) {
            TemplateEditorScreen(
                template: database.newTemplate(),
                isEditingExistingTemplate: false
            )
        }
    }
}

struct CreateTemplateMenu_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CreateTemplateMenu()
        }
        .environmentObject(Database.preview)
    }
}
