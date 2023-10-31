//
//  TemplateGenerationModifier.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 26.10.23.
//

import Combine
import OSLog
import SwiftUI

struct TemplateGenerationModifier: ViewModifier {
    
    @EnvironmentObject private var templateService: TemplateService
    
    @State private var isShowingTemplateGenerationScreen = false
    @State private var isShowingCreationFailedAlert = false

    @State private var templateExtraction: AnyCancellable?
    
    @Binding var uiImage: UIImage?
    @Binding var newTemplate: Template?
    
    func body(content: Content) -> some View {
        content
            .onChange(of: uiImage) { image in
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
            .alert(NSLocalizedString("creatingTemplateFailed", comment: ""), isPresented: $isShowingCreationFailedAlert) {
                Button(NSLocalizedString("ok", comment: ""), role: .cancel) {
                    isShowingCreationFailedAlert = false
                }
                Text(NSLocalizedString("creatingTemplateFailedText", comment: ""))
            }
            .sheet(isPresented: $isShowingTemplateGenerationScreen) {
                GenerationScreen(templateExtration: $templateExtraction)
            }
    }
}

extension View {
    func templateGeneration(from uiImage: Binding<UIImage?>, to template: Binding<Template?>) -> some View {
        modifier(TemplateGenerationModifier(uiImage: uiImage, newTemplate: template))
    }
}
