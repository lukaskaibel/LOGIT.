//
//  WorkoutRecorderStartScreen.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 06.04.22.
//

import SwiftUI

struct StartWorkoutView: View {
    
    // MARK: - Environment
    
    @EnvironmentObject var database: Database

    // MARK: - State
    
    private struct TemplateSelection: Identifiable {
        let id = UUID()
        let value: Template?
    }
    
    @State private var selectedTemplate: TemplateSelection? = nil
    
    // MARK: - Body
    
    var body: some View {
        List {
            Section {
                chooseTemplateText
            }.listRowBackground(Color.clear)
            Section {
                withoutTemplateButton
            }.listRowInsets(EdgeInsets())
            Section {
                templateList
            } header: {
                Text(NSLocalizedString("myTemplates", comment: ""))
                    .sectionHeaderStyle()
                    .listRowInsets(EdgeInsets())
            }
        }.listStyle(.insetGrouped)
            .navigationTitle(NSLocalizedString("startWorkout", comment: ""))
            .fullScreenCover(item: $selectedTemplate) { templateSelection in
                WorkoutRecorderView(workout: database.newWorkout(), template: templateSelection.value)
            }
    }
    
    // MARK: - Supporting Views
    
    private var chooseTemplateText: some View {
        Text(NSLocalizedString("chooseTemplateText", comment: ""))
            .foregroundColor(.secondaryLabel)
            .font(.subheadline)
            .padding(.top)
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private var withoutTemplateButton: some View {
        Button(action: { selectedTemplate = TemplateSelection(value: nil) }) {
            HStack(spacing: 15) {
                Image(systemName: "square.dashed")
                    .resizable()
                    .font(.body.weight(.thin))
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: "plus")
                    }
                Text(NSLocalizedString("startEmpty", comment: ""))
                    .font(.body.weight(.semibold))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.body.weight(.medium))
            }.font(.body.weight(.semibold))
                .foregroundColor(.accentColor)
                .frame(height: 60)
        }.padding(CELL_PADDING)
    }
    
    private var templateList: some View {
        ForEach(database.getTemplates(), id:\.objectID) { template in
            Button(action: {
                selectedTemplate = TemplateSelection(value: template)
            }) {
                TemplateCell(template: template)
                    .foregroundColor(.label)
            }.padding(CELL_PADDING)
        }.listRowInsets(EdgeInsets())
    }
    
}

struct WorkoutRecorderStartScreen_Previews: PreviewProvider {
    static var previews: some View {
        StartWorkoutView()
            .environmentObject(Database.preview)
    }
}
