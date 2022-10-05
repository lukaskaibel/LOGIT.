//
//  WorkoutRecorderStartScreen.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 06.04.22.
//

import SwiftUI

struct StartWorkoutView: View {

    // MARK: - Database Fetch
    
    @FetchRequest(entity: TemplateWorkout.entity(),
                  sortDescriptors: [NSSortDescriptor(key: "creationDate",
                                                     ascending: false)])
    var workoutTemplates: FetchedResults<TemplateWorkout>
    
    // MARK: - State
    
    private struct TemplateSelection: Identifiable {
        let id = UUID()
        let value: TemplateWorkout?
    }
    
    @State private var selectedTemplate: TemplateSelection? = nil
    
    // MARK: - Body
    
    var body: some View {
        List {
            Section {
                chooseTemplateText
            }.listRowSeparator(.hidden)
                .padding(.bottom)
            Section {
                withoutTemplateButton
            }.listRowSeparator(.hidden)
            Section {
                templateList
            } header: {
                Text(NSLocalizedString("myTemplates", comment: ""))
                    .sectionHeaderStyle()
            }.listRowSeparator(.hidden)
        }.listStyle(.plain)
            .navigationTitle(NSLocalizedString("startWorkout", comment: ""))
            .fullScreenCover(item: $selectedTemplate) { templateSelection in
                WorkoutRecorderView(template: templateSelection.value)
            }
    }
    
    // MARK: - Supporting Views
    
    private var chooseTemplateText: some View {
        Text(NSLocalizedString("chooseTemplateText", comment: ""))
            .foregroundColor(.secondaryLabel)
            .font(.subheadline)
            .padding(.top)
            .frame(maxWidth: .infinity, alignment: .center)
            .listRowBackground(Color.clear)
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
                    .foregroundColor(.secondaryLabel)
            }.font(.body.weight(.medium))
                .foregroundColor(.accentColor)
                .frame(height: 60)
        }.padding(10)
            .background(Color.secondaryBackground)
            .cornerRadius(12)
    }
    
    private var templateList: some View {
        ForEach(workoutTemplates, id:\.objectID) { template in
            Button(action: {
                selectedTemplate = TemplateSelection(value: template)
            }) {
                WorkoutTemplateCell(workoutTemplate: template)
                    .foregroundColor(.label)
            }
        }
    }
    
}

struct WorkoutRecorderStartScreen_Previews: PreviewProvider {
    static var previews: some View {
        StartWorkoutView()
    }
}
