//
//  WorkoutRecorderStartScreen.swift
//  LOGIT.
//
//  Created by Lukas Kaibel on 06.04.22.
//

import SwiftUI

struct StartWorkoutView: View {
    
    enum FullScreenCoverType: Identifiable {
        case workoutRecorder(template: Template?)
        var id: UUID { UUID() }
    }
    
    enum SheetType: Identifiable {
        case templateDetail(template: Template)
        var id: UUID { UUID() }
    }
    
    // MARK: - Environment
    
    @EnvironmentObject var database: Database

    // MARK: - State
    
    private struct TemplateSelection: Identifiable {
        let id = UUID()
        let value: Template?
    }
    
    @State private var sheetType: SheetType? = nil
    @State private var fullScreenCoverType: FullScreenCoverType? = nil
    
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
            .fullScreenCover(item: $fullScreenCoverType) { type in
                switch type {
                case let .workoutRecorder(template): WorkoutRecorderView(workout: database.newWorkout(), template: template)
                }
            }
            .sheet(item: $sheetType) { type in
                switch type {
                case let .templateDetail(template):
                    NavigationStack {
                        TemplateDetailView(template: template)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button(NSLocalizedString("back", comment: "")) {
                                        sheetType = nil
                                    }
                                }
                            }
                    }
                }
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
        Button {
            fullScreenCoverType = .workoutRecorder(template: nil)
        } label: {
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
                NavigationChevron()
            }.font(.body.weight(.semibold))
                .foregroundColor(.accentColor)
                .frame(height: 60)
        }.padding(CELL_PADDING)
    }
    
    private var templateList: some View {
        ForEach(database.getTemplates(), id:\.objectID) { template in
            Button {
                fullScreenCoverType = .workoutRecorder(template: template)
            } label: {
                HStack {
                    TemplateCell(template: template)
                        .foregroundColor(.label)
                    Spacer()
                    Button {
                        sheetType = .templateDetail(template: template)
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.title3)
                    }
                    NavigationChevron()
                }
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
