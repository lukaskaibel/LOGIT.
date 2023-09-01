//
//  TemplateGenerationScreen.swift
//  LOGIT
//
//  Created by Lukas Kaibel on 04.08.23.
//

import Combine
import SwiftUI

struct TemplateGenerationScreen: View {
    
    // MARK: - Environment
    
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Parameters
    
    @Binding var templateExtration: AnyCancellable?
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Generating Template")
                    .font(.largeTitle.weight(.bold))
                Text("From Image")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .padding(.top, 20)
            
            Spacer()
            VStack(spacing: 30) {
                ProgressView()
                    .progressViewStyle(.circular)
                Text("This will only take a few seconds.")
                    .frame(maxWidth: 200)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            Button {
                templateExtration?.cancel()
                dismiss()
            } label: {
                Text("Cancel")
                    .padding()
            }
            .buttonStyle(BigButtonStyle())
            .padding(.bottom, 50)
        }
    }
}

struct TemplateGenerationScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TemplateGenerationScreen(templateExtration: .constant(nil))
        }
    }
}
