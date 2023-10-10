//
//  CreateTemplateMenu.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 31.07.23.
//

import Combine
import OSLog
import PhotosUI
import SwiftUI

struct CreateTemplateMenu: View {

    @EnvironmentObject private var database: Database
    @EnvironmentObject private var templateService: TemplateService

    @State private var photoPickerItem: PhotosPickerItem?
    @State private var workoutImage: UIImage?

    @State private var isShowingPhotosPicker = false
    @State private var isShowingTemplateGenerationScreen = false
    @State private var isShowingCreationFailedAlert = false

    @State private var newTemplate: Template?
    @State private var templateExtraction: AnyCancellable?

    var body: some View {
        Menu {
            Button {
                newTemplate = database.newTemplate()
                database.flagAsTemporary(newTemplate!)
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
        .alert("Creating Template Failed", isPresented: $isShowingCreationFailedAlert) {
            Button(NSLocalizedString("ok", comment: ""), role: .cancel) {
                isShowingCreationFailedAlert = false
            }
            Text("Make sure the selected image contains a workout.")
        }
        .onChange(of: photoPickerItem) { _ in
            Task {
                if let data = try? await photoPickerItem?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        Logger().info("CreateTemplateMenu: Image picked")
                        workoutImage = uiImage
                        return
                    }
                }

                Logger().warning("CreateTemplateMenu: Loading image failed")
            }
        }
        .onChange(of: workoutImage) { image in
            guard let image = image else {
                isShowingCreationFailedAlert = true
                return
            }
            isShowingTemplateGenerationScreen = true
            templateExtraction = templateService.createTemplate(from: image)
                .sink(
                    receiveCompletion: { completion in
                        isShowingTemplateGenerationScreen = false
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            isShowingCreationFailedAlert = true
                            Logger()
                                .error(
                                    "CreateTemplateMenu: Creating template from image failed: \(error.localizedDescription)"
                                )
                        }
                    },
                    receiveValue: { template in
                        Logger().info("CreateTemplateMenu: Extracted template: \(template)")
                        newTemplate = template
                    }
                )
        }
        .photosPicker(
            isPresented: $isShowingPhotosPicker,
            selection: $photoPickerItem,
            photoLibrary: .shared()
        )
        .sheet(item: $newTemplate) { template in
            TemplateEditorScreen(
                template: template,
                isEditingExistingTemplate: false
            )
        }
        .sheet(isPresented: $isShowingTemplateGenerationScreen) {
            TemplateGenerationScreen(templateExtration: $templateExtraction)
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
